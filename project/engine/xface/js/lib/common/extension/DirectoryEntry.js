
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

/**
 * @module file
 */
var argscheck = require('xFace/argscheck'),
    utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    Entry = require('xFace/extension/Entry');

/**
 * 该对象表示一个文件系统的目录（Android, iOS, WP8）<br/>
 * @example
        var name = "test";
        var fullPath = "/test";
        var entry = new DirectoryEntry(name, fullPath);
 * @class DirectoryEntry
 * @constructor
 * @extends Entry
 * @param {String} [name] 目录名称
 * @param {String} [fullPath] 目录的完整路径
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var DirectoryEntry = function(name, fullPath) {
    argscheck.checkArgs('SS', 'DirectoryEntry.DirectoryEntry', arguments);
    DirectoryEntry.__super__.constructor.apply(this, [false, true, name, fullPath]);
};

utils.extend(DirectoryEntry, Entry);

/**
 * 根据当前目录的绝对路径创建一个{{#crossLink "DirectoryReader"}}{{/crossLink}}对象（Android，iOS, WP8）<br/>
 * @example
        var directoryReader = DirectoryEntry.createReader();
 * @method createReader
 * @return {DirectoryReader} directoryReader
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DirectoryEntry.prototype.createReader = function() {
    return new DirectoryReader(this.fullPath);
};

/**
 * 在当前目录下创建或者查找目录（Android，iOS, WP8）<br/>
 * 注意：如果要创建目录的父目录不存在，会报错
 * @example
        function success(parent) {
            console.log("Parent Name: " + parent.name);
        }
        function error(error) {
            alert("Unable to create new directory: " + error.code);
        }
        // 获取一个已存在的目录，如果该目录不存在的时候创建它
        entry.getDirectory("newDir", {create: true, exclusive: false}, success, error);
 * @method getDirectory
 * @param {String} path 需要创建或查找的目录路径（绝对路径或相对路径）
 * @param {Flags} options 该参数用于决定在目录不存在的时候是否创建该目录
 * @param {Function} successCallback 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 创建的或查找到的目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DirectoryEntry.prototype.getDirectory = function(path, options, successCallback, errorCallback) {
    argscheck.checkArgs('sofF', 'DirectoryEntry.getDirectory', arguments);
    var win = function(result) {
        var entry = new DirectoryEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getDirectory", [this.fullPath, path, options]);
};

/**
 * 从文件系统中递归删除当前目录（包含所有的子文件和子目录）（Android，iOS, WP8）<br/>
 * 如果有子文件（夹）无法删除时，部分子文件（夹）可能会被删掉，同时会回调报错<br/>
 * 注意：当删除一个文件系统的根目录时，会报错
 * @example
        function success() {
            console.log("Remove Recursively Succeeded");
        }
        function error(error) {
            alert("Failed to remove directory: " + error.code);
        }
        // 删除该目录下的所有内容
        entry.removeRecursively(success, error);
 * @method removeRecursively
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DirectoryEntry.prototype.removeRecursively = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'DirectoryEntry.removeRecursively', arguments);
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(successCallback, fail, null, "File", "removeRecursively", [this.fullPath]);
};

/**
 * 在当前目录下创建或者查找一个文件（Android，iOS, WP8）<br/>
 * 注意：如果要创建文件的父目录不存在，会报错
 * @example
        function success(entry) {
            console.log("Parent Name: " + entry.name);
        }
        function error(error) {
            alert("Failed to retrieve file: " + error.code);
        }
        // 获取一个已存在的文件，如果该文件不存在则创建它
        entry.getFile("test.txt", {create: true, exclusive: false}, success, error);
 * @method getFile
 * @param {String} path 需要创建或查找的文件路径（绝对路径或相对路径）
 * @param {Flags=null} options 该参数用于决定在文件不存在的时候是否创建该文件(传null等同于{create: false})
 * @param {Function} successCallback 成功回调函数
 * @param {FileEntry} successCallback.entry 创建的或查找到的文件对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
DirectoryEntry.prototype.getFile = function(path, options, successCallback, errorCallback) {
    argscheck.checkArgs('s*fF', 'DirectoryEntry.getFile', arguments);
    var win = function(result) {
        var FileEntry = require('xFace/extension/FileEntry');
        var entry = new FileEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getFile", [this.fullPath, path, options]);
};
//复写基类Entry属性注释
/**
 * 用于标识是否是一个文件（固定为false）(Android, iOS, WP8)
 * @example
       entry.isFile
 * @property isFile
 * @type Boolean
 * @default false
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 用于标识是否是一个目录（固定为true）(Android, iOS, WP8)
 * @example
       entry.isDirectory
 * @property isDirectory
 * @type Boolean
 * @default true
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 目录的名称，不包含路径(Android, iOS, WP8)
 * @example
       entry.name
 * @property name
 * @type String
 * @default ""
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 目录的绝对路径(Android, iOS, WP8)
 * @example
       entry.fullPath
 * @property fullPath
 * @type String
 * @default ""
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 目录所在的文件系统(Android, iOS, WP8)
 * @example
       entry.filesystem
 * @property filesystem
 * @type FileSystem
 * @default null
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

//复写基类Entry的方法注释
/**
 * 移动目录（Android, iOS, WP8）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.移动一个目录到它自身目录，或者它的任意子目录下<br/>
 * 例如：目录结构如下/a/b/c，若要移动目录a到目录a，b或c下都会报错<br/>
 * 2.移动一个目录到它的父目录下，且该目录名称未修改<br/>
 * 例如：目录结构如下/b/a，若目录a要直接移动到目录b下，且目录a未修改名称会报错<br/>
 * 3.移动目录的目标路径已经被一个文件占用<br/>
 * 例如：在目录a下面有一个文件b，现将另外一个目录c移动a下面，并且目录c的新名称为b，这时会报错<br/>
 * 4.移动目录的目标路径已经被一个非空目录（包含文件或子文件）占用<br/>
 * 例如：文件目录结构为/a/b/c.txt，若将另一个目录d移动到a下面，并且目录d的新名称为b，这时会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function moveDir(entry) {
            var parent = document.getElementById('parent').value,
                parentName = parent.substring(parent.lastIndexOf('/')+1),
                newName = document.getElementById('newName').value,
                parentEntry = new DirectoryEntry(parentName, parent);
            //移动一个目录到新目录下并重命名
            entry.moveTo(parentEntry, newName, success, error);
        }
 * @method moveTo
 * @param {DirectoryEntry} parent  将要移动到的父目录对象
 * @param {String} [newName=this.name] 目录的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 移动后的目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 复制目录（Android, iOS, WP8）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.复制一个目录到它的自身目录，或者它的任意子目录下<br/>
 * 例如：目录结构如下/a/b/c，若要复制目录a到目录a，b或c下都会报错<br/>
 * 2.复制一个目录到它的父目录下，且该目录名称未修改<br/>
 * 例如：目录结构如下/b/a，若目录a要直接复制到目录b下，且目录a未修改名称会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function copyDir(entry) {
            var parent = document.getElementById('parent').value,
                parentName = parent.substring(parent.lastIndexOf('/')+1),
                newName = document.getElementById('newName').value,
                parentEntry = new DirectoryEntry(parentName, parent);
            //复制一个目录到新目录下
            entry.copyTo(parentEntry, newName, success, error);
        }
 * @method copyTo
 * @param {DirectoryEntry} parent  将要复制到的父目录对象
 * @param {String} [newName=this.name] 目录的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 复制后的目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 删除一个目录（Android, iOS, WP8）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.删除一个非空目录（即包含子文件）<br/>
 * 例如：目录结构如下/b/a/c.txt，要删除目录a时，会报错<br/>
 * 2.删除文件系统的根目录<br/>
 * 例如：如果文件系统的根目录是/root时，删除root会报错<br/>
 * @example
        function success(entry) {
            console.log("Removal succeeded");
        }
        function error(error) {
            alert('Error info: ' + error.code);
        }
        //删除目录
        entry.remove(success, error);
 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 返回当前目录的URL地址（Android, iOS, WP8）<br/>
 * @example
        var dirURL = entry.toURL();
 * @method toURL
 * @return {String} URL地址
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 获取当前目录的父目录（Android, iOS, WP8）<br/>
 * @example
        function success(parent) {
            console.log("Parent Name: " + parent.name);
        }
        function error(error) {
            alert('Failed to get parent directory: ' + error.code);
        }
        // 获取父目录
        entry.getParent(success, error);
 * @method getParent
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 当前目录的父目录
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 获取当前目录的元数据（Android, iOS, WP8）<br/>
 * @example
        function success(metadata) {
            console.log("Last Modified: " + metadata.modificationTime);
        }
        function error(error) {
            alert(error.code);
        }
        // 获取该entry对象的元数据
        entry.getMetadata(success, error);
 * @method getMetadata
 * @param {Function} [successCallback] 成功回调函数
 * @param {Metadata} successCallback.metadata 当前目录的元数据
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
module.exports = DirectoryEntry;