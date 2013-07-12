
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

﻿var util         = require('util'),
    fs           = require('fs'),
    childProcess = require('child_process'),
    path         = require("path"),
    os  = require('os'),
    rexp_minified = new RegExp("\\.min\\.js$"),
    rexp_src = new RegExp('\\.js$');

// HELPERS
// Iterates over a directory
function forEachFile(root, cbFile, cbDone) {
    var count = 0;

    function scan(name) {
        ++count;

        fs.stat(name, function (err, stats) {
            if (err) cbFile(err);

            if (stats.isDirectory()) {
                fs.readdir(name, function (err, files) {
                    if (err) cbFile(err);

                    files.forEach(function (file) {
                        scan(path.join(name, file));
                    });
                    done();
                });
            } else if (stats.isFile()) {
                cbFile(null, name, stats, done);
            } else {
                done();
            }
        });
    }

    function done() {
        --count;
        if (count === 0 && cbDone) cbDone();
    }

    scan(root);
}


desc("runs build");
task('default', ['build'], function () {});

desc("clean");
task('clean', ['set-cwd'], function () {
    var deployDir = "pkg";
    var deployPath = path.join(__dirname, deployDir);
    var osType = os.type().toLowerCase();
    fs.exists(deployPath, function(exists) {
        var cmd = null;
        if(exists) {
            if(osType.indexOf('windows') != -1) {
                cmd = "rmdir /S /Q " + deployDir;
            } else {
                cmd = "rm -rf " + deployDir;
            }
            cmd += " && mkdir " + deployDir;
        } else {
            cmd = "mkdir " + deployDir;
        }
        childProcess.exec(cmd,callback);
    });
    
    function callback(error) {
        if(error != null) {
            console.log(error);
        } else {
            complete();
        }
    }
}, true);

desc("compiles the source files for all extensions");
task('build', ['clean', 'hint'], function (platform) {
    platform = platform || process.env.platform;
    var supportedPlatform = [
        'android',
        'ios',
        'wp8'
    ];
    var packager = require("./build/packager");
    console.log("building xface.js");
    console.log("platform=" + platform);

    var buildAll = true;
    if(typeof platform == 'string') {
        platform = platform.toLowerCase();
        if(supportedPlatform.indexOf(platform) != -1) {
            buildAll = false;
        }
    }
    
    if(buildAll) {
        for(var i in supportedPlatform) {
            platform = supportedPlatform[i];
            console.log("Build js file for platform: " + platform);
            packager.generate(platform);
        }
    } else {
        console.log("Build js file for platform: " + platform);
        var productJsPath = null;
        if(process.env.destPath) {
            var destPath = process.env.destPath;
            destPath = destPath.replace(new RegExp('\\\\', 'gm'), '/');
            baseProductPath = path.dirname(__dirname).replace(new RegExp('\\\\', 'gm'), '/');
            if(destPath.indexOf(baseProductPath) != 0) {
                var reg = new RegExp('.*\\/project\\/engine\\/.+?\\/', '');
                productJsPath = path.join(reg.exec(destPath)[0], 'js');
                console.log("Product js dir path: " + productJsPath);
            }
        }
        packager.generate(platform, productJsPath);
    }
    
    complete();
}, true);

desc("copy generated js library file to specific platform project");
/**
 * 构建xface.js，并拷贝到指定路径
 */
task('package-js', ['build'], function(platform, destPath) {
    platform = platform || process.env.platform.toLowerCase();
    destPath = destPath || process.env.destPath;
    destPath = destPath.replace(new RegExp('\\\\', 'gm'), '/');
    srcJsPath = path.join('pkg', 'xface.' + platform + '.js');
    if(!fs.existsSync(srcJsPath)) {
        complete();
    }
    
    destDir = path.dirname(destPath)
    if(!fs.existsSync(destDir)) {
        mkdirs(destDir);
    }
    // copy generated js file
    console.log('Copy generated js file from: ' + srcJsPath + ' to: ' + destPath);
    copyFile(srcJsPath, destPath);
});

desc("make sure we're in the right directory");
task('set-cwd', [], function() {
    if (__dirname != process.cwd()) {
        process.chdir(__dirname);
    }
});

desc('check sources with JSHint');
task('hint', ['complainwhitespace'], function () {
    var knownWarnings = [
        "Redefinition of 'FileReader'", 
        "Redefinition of 'require'", 
        "Read only",
        "Redefinition of 'console'"
    ];
    var filterKnownWarnings = function(el, index, array) {
        var wut = true;
        // filter out the known warnings listed out above
        knownWarnings.forEach(function(e) {
            wut = wut && (el.indexOf(e) == -1);
        });
        wut = wut && (!el.match(/\d+ errors/));
        return wut;
    };

    childProcess.exec("jshint lib",function(err,stdout,stderr) {
        var exs = stdout.split('\n');
        console.log(exs.filter(filterKnownWarnings).join('\n')); 
        complete();
    });
}, true);

var complainedAboutWhitespace = false

desc('complain about what fixwhitespace would fix');
task('complainwhitespace', function() {
    processWhiteSpace(function(file, newSource) {
        if (!complainedAboutWhitespace) {
            console.log("files with whitespace issues: (to fix: `jake fixwhitespace`)")
            complainedAboutWhitespace = true
        }
        
        console.log("   " + file)
    })
}, true);

desc('converts tabs to four spaces, eliminates trailing white space, converts newlines to proper form - enforcing style guide ftw!');
task('fixwhitespace', function() {
    processWhiteSpace(function(file, newSource) {
        if (!complainedAboutWhitespace) {
            console.log("fixed whitespace issues in:")
            complainedAboutWhitespace = true
        }
        
        fs.writeFileSync(file, newSource, 'utf8');
        console.log("   " + file)
    })
}, true);

function mkdirs(dirPath) {
    var parent = path.dirname(dirPath);
    if(!fs.existsSync(parent)) {
        mkdirs(parent);
    }
    fs.mkdirSync(dirPath);
}

function copyFile(srcPath, destPath) {
    var content = fs.readFileSync(srcPath, 'utf8');
    fs.writeFileSync(destPath, content, 'utf8');
}

function processWhiteSpace(processor) {
    forEachFile('lib', function(err, file, stats, cbDone) {
        //if (err) throw err;
        if (rexp_minified.test(file) || !rexp_src.test(file)) {
            cbDone();
        } else {
            var origsrc = src = fs.readFileSync(file, 'utf8');

            // tabs -> four spaces
            if (src.indexOf('\t') >= 0) {
                src = src.split('\t').join('    ');
            }

            // eliminate trailing white space
            src = src.replace(/ +\n/g, '\n');

            if (origsrc !== src) {
                // write it out yo
                processor(file, src);
            }
            cbDone();
        }
    }, complete);
}

desc('Generate js api reference documents according js source files!');
task('doc', function(proj, destDir) {
    destDir = destDir || "jsdoc"
    var baseProjName = path.basename(path.resolve('..'));
    var targetProjPath = null;

    if(proj != null) {
        targetProjPath = path.join('../..', proj);
        // check the target project, it may be not existed
        if(!fs.existsSync(targetProjPath)) {
            console.log("The target project [" + proj + "] path [" + path.resolve(targetProjPath) + "] is not existed! ");
            complete();
            return;
        }
    }

    var command = "yuidoc -C -c yuidoc.json lib";
    if(proj != null && proj != baseProjName) {
        command += (" " + path.join(targetProjPath, 'js'));
    }
    command += " -o " + destDir;

    childProcess.exec(command,function(err,stdout,stderr) {
        console.log(stdout);
        console.log(stderr);
        normalizeCrossLink(destDir);
        console.log("The doc is generated in dir: '" +path.resolve(destDir) +  "'! ");
        complete();
    });
}, true);

// Normalize the cross link path of js api doc, replace character '\' with '/'
function normalizeCrossLink(dir) {
    var entries = fs.readdirSync(dir);
    var expression = /<a\shref="(.*)\sclass="crosslink">/gm;

    entries.forEach(function(entry) {
        var filePath = path.join(dir, entry);
        var stat = fs.statSync(filePath);
        if(stat.isDirectory()) {
            normalizeCrossLink(filePath);
        } else if(entry.match(/\.html$/)) {
            var content = fs.readFileSync(filePath, 'utf-8');
            content = content.replace(expression, function(href) {
                return  href.replace(/\\/gm, '/');
            });
            fs.writeFileSync(filePath, content, 'utf-8');
        }
    });
}