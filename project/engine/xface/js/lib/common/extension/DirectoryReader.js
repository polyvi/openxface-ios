
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

 /**
  * 该类返回一个目录中的所有文件实体（Android, iOS, WP8）<br/>
  * 该类不能通过new来创建相应的对象，只能通过{{#crossLink "DirectoryEntry/createReader"}}{{/crossLink}}方法创建该类的对象
  * @class DirectoryReader
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */

var exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry');

function DirectoryReader(path) {
    this.path = path || null;
}

/**
 * 返回一个目录中的所有文件实体（Android，iOS, WP8）<br/>
 * @example
        var directoryReader = DirectoryEntry.createReader();
        directoryReader.readEntries(success,fail);
        function success(entries) {
            var i;
            var s = "success，文件夹中所有文件的名字如下：<p/>";
            for (i=0; i<entries.length; i++) {
                s += entries[i].name + "<br />";
            }
            document.querySelector("#content").innerHTML = s;
        }
        function fail(error) {
            alert(error.code);
        }
 * @method readEntries
 * @param {Function} [successCallback] 成功回调函数
 * @param {File[]} successCallback.files 返回File对象数组
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 该参数接收FileError的对象，该对象表示函数调用中产生的错误信息，参考{{#crossLink "FileError"}}{{/crossLink}}
 * @platform Android, iOS, WP8
 */
DirectoryReader.prototype.readEntries = function(successCallback, errorCallback) {
    var win = typeof successCallback !== 'function' ? null : function(result) {
        var retVal = [];
        for (var i = 0; i < result.length; i++) {
            var entry = null;
            if (result[i].isDirectory) {
                entry = new DirectoryEntry();
            }
            else if (result[i].isFile) {
                entry = new FileEntry();
            }
            entry.isDirectory = result[i].isDirectory;
            entry.isFile = result[i].isFile;
            entry.name = result[i].name;
            entry.fullPath = result[i].fullPath;
            retVal.push(entry);
        }
        successCallback(retVal);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "readEntries", [this.path]);
};

module.exports = DirectoryReader;
