
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

﻿var fs    = require('fs')
var util  = require('util')
var path  = require('path')

var packager = module.exports

//------------------------------------------------------------------------------
packager.generate = function(platform, productJsPath) {
    var time = new Date().valueOf()
    
    var libraryRelease = packager.bundle(platform, false, productJsPath)
    
    checkModuleDependency(libraryRelease)
    
    time = new Date().valueOf() - time
    
    var outFile
    
    outFile = path.join('pkg', 'xface.' + platform + '.js')
    fs.writeFileSync(outFile, libraryRelease, 'utf8')
    
    console.log('generated platform: ' + platform + ' in ' + time + 'ms')
}

//------------------------------------------------------------------------------
packager.bundle = function(platform, debug, productJsPath ) {
    var modules = collectFiles('lib/common')
    var scripts = collectFiles('lib/scripts')
    
    modules[''] = 'lib/xFace.js'
    
    copyProps(modules, collectFiles(path.join('lib', platform)))
    
    if(productJsPath != null && fs.existsSync(productJsPath)) {
        var commonDirPath = path.join(productJsPath, 'common');
        var platformDirPath = path.join(productJsPath, platform);
        if(fs.existsSync(commonDirPath)) {
            copyProps(modules, collectFiles(commonDirPath))
            var commonJsPath = path.join(commonDirPath, 'common.js')
            if(fs.existsSync(commonJsPath)) {
                var mergeFilePath = mergeModuleJs('lib/common/common.js', commonJsPath);
                modules['common'] = mergeFilePath;
            }
        }
        
        if(fs.existsSync(platformDirPath)) {
            copyProps(modules, collectFiles(platformDirPath))
            var platformJsPath = path.join(platformDirPath, 'platform.js')
            if(fs.existsSync(platformJsPath)) {
                var mergeFilePath = mergeModuleJs(path.join('lib', platform, 'platform.js'), platformJsPath);
                modules['platform'] = mergeFilePath;
            }
        }
    }

    var output = [];
	
	output.push("// File generated at :: "  + new Date() + "\n");

    // write header    
    output.push('\n;(function() {\n')
    
    // write initial scripts
    if (!scripts['require']) {
        throw new Error("didn't find a script for 'require'")
    }
    
    writeScript(output, scripts['require'], debug)

    // write modules
    var moduleIds = Object.keys(modules)
    moduleIds.sort()
    
    for (var i=0; i<moduleIds.length; i++) {
        var moduleId = moduleIds[i]
        
        writeModule(output, modules[moduleId], moduleId, debug)
    }

    output.push("\nwindow.xFace = require('xFace');\n")

    // write final scripts
    if (!scripts['bootstrap']) {
        throw new Error("didn't find a script for 'bootstrap'")
    }
    
    writeScript(output, scripts['bootstrap'], debug)
    
    var bootstrapPlatform = 'bootstrap-' + platform
    if (scripts[bootstrapPlatform]) {
        writeScript(output, scripts[bootstrapPlatform], debug)
    }

    // write trailer
    output.push('\n})();')

    return output.join('\n')
}

//------------------------------------------------------------------------------

function unique(data){
    data = data || [];
    var a = {};
    for (var i=0; i<data.length; i++) {
        var v = data[i];
        if (typeof(a[v]) == 'undefined'){
            a[v] = 1;
        }
    }
    data.length=0;
    for (var i in a){
        data[data.length] = i;
    }
    return data;
}

/**
 * 查询满足正则表达式条件的数据
 * 返回数据的每一项数据为匹配正则表达式第一个组的数据
 */
function getAllMatchedData(content, reg) {
    var result = null;
    var data = [];
    while((result = reg.exec(content)) != null) {
        data.push(result[1]);
    }
    return data;
}

/**
 * 检查最终生成的js文件中模块的依赖关系
 */
function checkModuleDependency(content) {
    var reg = new RegExp('require\\s*\\(\\s*[\'"]([\\w\\/]+)[\'"]\\s*\\)', 'g');
    var requires = [];
    var defines = [];
    var result = null;
    requires = getAllMatchedData(content, reg);
    
    reg = new RegExp('[\'"]?path[\'"]?\\s*:\\s*[\'"]([\\w\\/]+)[\'"]', 'g');
    requires = requires.concat(getAllMatchedData(content, reg));
    requires = unique(requires);
    requires.sort();
    
    reg = new RegExp('define\\s*\\(\\s*[\'"]([\\w\\/]+)[\'"]', 'g');
    defines = getAllMatchedData(content, reg);
    defines = unique(defines);
    defines.sort();
    
    var result = [];
    for(var i in requires) {
        var moduleId = requires[i];
        var index = defines.indexOf(moduleId);
        if(index == -1) {
            result.push(moduleId);
        } else {
            for(var j = 0; j <= index; j++) {
                defines.shift();
            }
        }
    }
    
    console.log("\n");
    for(var i in result) {
        console.log("=======Warning: Module [" + result[i] + "] maybe is not defined! \n");
    }
}

/**
 * 获取与起始大括号配对的结束大括号位置
 * @return 结束大括号位置
 */
function getEndBracketPair(content, startBracketIndex) {
    var depth = 0;
    var len = content.length;
    for(var i = startBracketIndex; i < len; i++) {
        if('{' == content[i])  depth += 1;
        else if('}' == content[i])  depth -= 1;
        
        if(depth == 0) return i;
    }
    return -1;
}

/**
 * 将js文件存储的结构数据解析成js对象
 * @return 解析完成的js对象
 */
function interpretStructure(content, parentTagExpr) {
    var index = content.search(parentTagExpr);
    if(index === -1) {
        return null;
    }
    var startIndex = index + content.substring(index).indexOf('{');
    var endIndex = getEndBracketPair(content, startIndex);
    var jsStr = "var moduleData = {" + content.substring(index, endIndex + 1) + "}";
    eval(jsStr);
    return moduleData;
}

/**
 * 用新的模块结构数据代替content中老的模块结构数据
 * @return 更新后的数据string对象
 */
function updateModuleStructure(content, newDataObject, parentTagExpr) {
    if(newDataObject == null) {
        return content;
    }
    var str = JSON.stringify(newDataObject);
    var index = content.search(parentTagExpr);
    if(index === -1) {
        console.log("============Merge js content error!==============");
        return content;
    }
    var startIndex = index + content.substring(index).indexOf('{');
    var endIndex = getEndBracketPair(content, startIndex);

    var newContent = content.substring(0, startIndex);
    newContent = newContent + str;
    newContent = newContent + content.substring(endIndex + 1);
    return newContent;
}

/**
 * 将项目模块结构合并到基础模块结构中，如果存在同名数据，当override为true时进行覆盖操作
 *，为false时，将这些数据封装为一个数组并赋值
 * @return 合并后的数据
 */
function mergeModuleStructure(baseObjs, projectObjs, override) {
    if(baseObjs === null) {
        return projectObjs;
    } else if(projectObjs === null) {
        return baseObjs;
    }

    for(var prop in projectObjs) {
        if(projectObjs.hasOwnProperty(prop)) {
            if(baseObjs.hasOwnProperty(prop)) {
                if('path' == prop) {
                    if(override) baseObjs[prop] = projectObjs[prop];
                    else baseObjs[prop] = [baseObjs[prop], projectObjs[prop]];
                }
                else mergeModuleStructure(baseObjs[prop], projectObjs[prop])
            } else {
                baseObjs[prop] = projectObjs[prop];
            }
        }
    }
    return baseObjs;
}

/**
 * 合并两个js文件中的结构数据，项目js文件中的数据会覆盖基础js中的同名数据
 * 主要用于合并common.js和platform.js
 * @return 合并完成后数据的存储文件路径
 */
function mergeModuleJs(baseJsPath, projectJsPath) {
    // merge objects part
    var baseJsContent = fs.readFileSync(baseJsPath, 'utf-8');
    var projectJsContent = fs.readFileSync(projectJsPath, 'utf-8');
    var objectsTagExpression = /objects\s*:/;
    var baseModuleObjs = interpretStructure(baseJsContent, objectsTagExpression);
    var projectModuleObjs = interpretStructure(projectJsContent, objectsTagExpression);
    var resultObjects = mergeModuleStructure(baseModuleObjs, projectModuleObjs, true);

    // merge merges part
    var mergesTagExpression = /merges\s*:/;
    var baseModuleMerges = interpretStructure(baseJsContent, mergesTagExpression);
    var projectModuleMerges = interpretStructure(projectJsContent, mergesTagExpression);
    var resultMerges = mergeModuleStructure(baseModuleMerges, projectModuleMerges, false);

    var newContent = baseJsContent;
    if(resultObjects !== null) {
        newContent = updateModuleStructure(baseJsContent, resultObjects.objects, objectsTagExpression);
    }
    if(resultMerges !== null) {
        newContent = updateModuleStructure(newContent, resultMerges.merges, mergesTagExpression);
    }

    // save to new file
    var dir = "tmp";
    if(!fs.existsSync(dir))  fs.mkdirSync(dir);
    var filePath = path.join(dir, path.basename(baseJsPath));
    fs.writeFileSync(filePath, newContent, 'utf-8');
    return filePath;
}

function collectFile(dir, id, entry) {
    if (!id) id = ''
    var moduleId = path.join(id,  entry)
    var fileName = path.join(dir, entry)
    
    var stat = fs.statSync(fileName)

    var result = {};

    moduleId         = getModuleId(moduleId)
    result[moduleId] = fileName

    return copyProps({}, result)
}

function collectFiles(dir, id) {
    if (!id) id = ''

    var result = {}    
    
    var entries = fs.readdirSync(dir)
    
    entries = entries.filter(function(entry) {
        if (entry.match(/\.js$/)) return true
        
        var stat = fs.statSync(path.join(dir, entry))
        if (stat.isDirectory())  return true
    })

    entries.forEach(function(entry) {
        var moduleId = path.join(id, entry)
        var fileName = path.join(dir, entry)
        
        var stat = fs.statSync(fileName)
        if (stat.isDirectory()) {
            copyProps(result, collectFiles(fileName, moduleId))
        }
        else {
            moduleId         = getModuleId(moduleId)
            result[moduleId] = fileName
        }
    })
    
    return copyProps({}, result)
}

//------------------------------------------------------------------------------
function writeScript(oFile, fileName, debug) {
    var contents = getContents(fileName, 'utf8')

    contents = stripHeader(contents, fileName)
    
    writeContents(oFile, fileName, contents, debug)    
}

//------------------------------------------------------------------------------
function writeModule(oFile, fileName, moduleId, debug) {
    var contents = getContents(fileName, 'utf8')

    contents = '\n' + stripHeader(contents, fileName) + '\n'

	// Windows fix, '\' is an escape, but defining requires '/' -jm
    moduleId = path.join('xFace', moduleId).split("\\").join("/");
    
    var signature = 'function(require, exports, module)';
    
    contents = 'define("' + moduleId + '", ' + signature + ' {' + contents + '});\n'

    writeContents(oFile, fileName, contents, debug)    
}

//------------------------------------------------------------------------------
function getContents(file) {
    var buffer = fs.readFileSync(file);
    var startIndex = 0;
    // remove utf8 bom header
    if(buffer.length > 3 && buffer[0] == 0xef && buffer[1] == 0xbb && buffer[2] == 0xbf) {
        startIndex = 3;
    }
    return buffer.toString('utf8', startIndex);
}

//------------------------------------------------------------------------------
function writeContents(oFile, fileName, contents, debug) {
    
    if (debug) {
        contents += '\n//@ sourceURL=' + fileName
        
        contents = 'eval(' + JSON.stringify(contents) + ')'
        
        // this bit makes it easier to identify modules
        // with syntax errors in them
        var handler = 'console.log("exception: in ' + fileName + ': " + e);'
        handler += 'console.log(e.stack);'
        
        contents = 'try {' + contents + '} catch(e) {' + handler + '}'
    }
    
    else {
        contents = '// file: ' + fileName + '\n' + contents    
    }

    oFile.push(contents)
}

//------------------------------------------------------------------------------
function getModuleId(fileName) {
    return fileName.match(/(.*)\.js$/)[1]
}

//------------------------------------------------------------------------------
function copyProps(target, source) {
    for (var key in source) {
        if (!source.hasOwnProperty(key)) continue
        
        target[key] = source[key]
    }
    
    return target
}
//-----------------------------------------------------------------------------
// Strips the license header. Basically only the first multi-line comment up to to the closing */
function stripHeader(contents, fileName) {
    contents = contents.replace(new RegExp("\r\n","gm"), "\n");
    var ls = contents.split(/[\r\n]/);
    while (ls[0]) {
        if (ls[0].match(/^\s*\/\*/) || ls[0].match(/^\s*\*/)) {
            ls.shift();
        }
        else if (ls[0].match(/^\s*\*\//)) {
            ls.shift();
            break;
        }
        else {
        	// console.log("WARNING: file name " + fileName + " is missing the license header");
        	break;
    	}
    }
    return ls.join('\n');
}
