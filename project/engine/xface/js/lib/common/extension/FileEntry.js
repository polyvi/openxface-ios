
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
    exec = require('xFace/exec');
    Entry = require('xFace/extension/Entry'),
    File = require('xFace/extension/File'),
    FileWriter = require('xFace/extension/FileWriter'),
    FileError = require('xFace/extension/FileError');

/**
 * 表示文件系统中的一个文件（Android, iOS, WP8）<br/>
 * @example
        var name = "test.txt";
        var fullPath = "/test.txt";
        var entry = new FileEntry(name, fullPath);
 * @class FileEntry
 * @constructor
 * @extends Entry
 * @param {String} [name] 文件名称
 * @param {String} [fullPath] 文件的完整路径
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var FileEntry = function(name, fullPath) {
    argscheck.checkArgs('SS', 'FileEntry.FileEntry', arguments);
    FileEntry.__super__.constructor.apply(this, [true, false, name, fullPath]);
};

utils.extend(FileEntry, Entry);

/**
 * 根据当前文件信息创建{{#crossLink "FileWriter"}}{{/crossLink}}对象，用于对该文件进行写操作（Android, iOS, WP8）<br/>
 * @example
        fileEntry.createWriter (success, error);
        function success(writer) {
            writer.write("some text");
            writer.truncate(11);
        }
        function error(error) {
            alert(error.code);
        }
 * @method createWriter
 * @param {Function} successCallback 成功回调函数
 * @param {FileWriter} successCallback.writer 创建成功的{{#crossLink "FileWriter"}}{{/crossLink}}对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileEntry.prototype.createWriter = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'FileEntry.createWriter', arguments);
    this.file(function(filePointer) {
        var writer = new FileWriter(filePointer);

        if (writer.fileName === null || writer.fileName === "") {
            if (typeof errorCallback === "function") {
                errorCallback(new FileError(FileError.INVALID_STATE_ERR));
            }
        } else {
            successCallback(writer);
        }
    }, errorCallback);
};

/**
 * 获取一个{{#crossLink "File"}}{{/crossLink}}对象，用于描述当前文件的状态信息（Android, iOS, WP8）<br/>
 * @example
        fileEntry.file(success, error);
        function success(file) {
            alert(file.size);
            alert(file.name);
            alert(file.fullPath);
            alert(file.type);
            alert(file.lastModifiedDate);
        }
        function error(error) {
            alert(error.code);
        }
 * @method file
 * @param {Function} successCallback 成功回调函数
 * @param {File} successCallback.file 创建成功的{{#crossLink "File"}}{{/crossLink}}对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileEntry.prototype.file = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'FileEntry.file', arguments);
    var win = function(f) {
        var file = new File(f.name, f.fullPath, f.type, f.lastModifiedDate, f.size);
        successCallback(file);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getFileMetadata", [this.fullPath]);
};

//复写基类Entry属性注释
/**
 * 用于标识是否是一个文件（固定为true）(Android, iOS, WP8)
 * @example
       entry.isFile
 * @property isFile
 * @type Boolean
 * @default true
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 用于标识是否是一个目录（固定为false）(Android, iOS, WP8)
 * @example
       entry.isDirectory
 * @property isDirectory
 * @type Boolean
 * @default false
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 文件的名称，不包含路径(Android, iOS, WP8)
 * @example
       entry.name
 * @property name
 * @type String
 * @default ""
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 文件的绝对路径(Android, iOS, WP8)
 * @example
       entry.fullPath
 * @property fullPath
 * @type String
 * @default ""
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 文件所在的文件系统(Android, iOS, WP8)
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
 * 移动文件（Android, iOS, WP8）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.移动一个文件到它的父目录，且该文件未修改文件名<br/>
 * 例如：目录结构如下/a/b.txt，若要移动b.txt文件到目录a下，并且b.txt未修改文件名会报错<br/>
 * 2.移动文件的目标路径已经被一个目录占用<br/>
 * 例如：在目录a下面有一个目录b，现将另外一个文件c移动到a下面，并且文件c的新名称为b，这时会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function moveFile(entry) {
            var parent = document.getElementById('parent').value,
                parentName = parent.substring(parent.lastIndexOf('/')+1),
                parentEntry = new DirectoryEntry(parentName, parent);
            //移动一个文件到一个新目录，并且重命名该文件
            entry.moveTo(parentEntry, "test.txt", success, error);
        }
 * @method moveTo
 * @param {DirectoryEntry} parent  将要移动到的父目录
 * @param {String} [newName=this.name] 文件的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry} successCallback.entry 移动后的文件对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 复制文件（Android, iOS, WP8）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.复制一个文件到它的父目录，且该文件未修改名称<br/>
 * 例如：目录结构如下/a/b.txt，若要复制b.txt文件到目录a下，并且b.txt未修改文件名会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function copyFile(entry) {
            var parent = document.getElementById('parent').value,
            parentName = parent.substring(parent.lastIndexOf('/')+1),
            parentEntry = new DirectoryEntry(parentName, parent);
            //复制一个文件到新目录下
            entry.copyTo(parentEntry, newName, success, error);
        }
 * @method copyTo
 * @param {DirectoryEntry} parent 将要复制到的父目录
 * @param {String} [newName=this.name] 文件的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry} successCallback.entry 复制后的文件对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 删除一个文件（Android, iOS, WP8）<br/>
 * @example
        function success(entry) {
            console.log("Removal succeeded");
        }
        function error(error) {
            alert('Error info: ' + error.code);
        }
        //删除一个文件
        entry.remove(success, error);
 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 返回当前文件的URL地址（Android, iOS, WP8）<br/>
 * @example
        var dirURL = entry.toURL();
 * @method toURL
 * @return {String} URL地址
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 获取当前文件的父目录（Android, iOS, WP8）<br/>
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
 * @param {DirectoryEntry} successCallback.entry 当前文件的父目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
/**
 * 获取当前文件的元数据（Android, iOS, WP8）<br/>
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
 * @param {Metadata} successCallback.metadata 当前文件的元数据
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
module.exports = FileEntry;