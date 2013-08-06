
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
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry'),
    exec = require('xFace/exec');

/**
 * 解析给定的文件系统URI,返回文件entry对象。
 * @example
        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onFileSystemSuccess, fail);
        function onFileSystemSuccess(fileSystem) {
            fileSystem.root.getFile("testDir.txt", {create: true, exclusive: false}, gotFileEntry, fail);
        }
        function gotFileEntry(fileEntry) {
            window.resolveLocalFileSystemURI("file:///testDir.txt",success, fail);
        }
        //解析给定的文件系统URI,返回文件entry对象
        window.resolveLocalFileSystemURI("file:///testDir.txt",success, fail);
        function success(entry) {
            if("testDir.txt" == entry.name && "/testDir.txt" == entry.fullPath)
            {
                console.log("succeeded");
            }
            else {
                console.log("failed");
            }
        }
        function fail(error) {
            console.log(error.code);
        }
 * @method resolveLocalFileSystemURI
 * @param {String}     uri                   要解析的文件系统的URI
 * @param {Function}   successCallback       成功的回调函数
 * @param {Entry}      successCallback.entry 成功回调得到的{{#crossLink "Entry"}}{{/crossLink}}对象
 * @param {Function}   [errorCallback]       失败回调函数
 * @param {Number}     [errorCallback.code]  失败回调函数错误码，参见{{#crossLink "FileError"}}{{/crossLink}}对象
 * @for   resolveLocalFileSystemURI
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var resolveLocalFileSystemURI = function(uri, successCallback, errorCallback) {
    argscheck.checkArgs('sfF', 'resolveLocalFileSystemURI', arguments);
    var fail = function(error) {
        if (typeof errorCallback === 'function') {
            errorCallback(new FileError(error));
        }
    };
    var success = function(entry) {
        var result;

        if (entry) {
            if (typeof successCallback === 'function') {
                result = (entry.isDirectory) ? new DirectoryEntry(entry.name, entry.fullPath) : new FileEntry(entry.name, entry.fullPath);
                try {
                    successCallback(result);
                }
                catch (e) {
                    console.log('Error invoking callback: ' + e);
                }
            }
        }
        else {
            fail(FileError.NOT_FOUND_ERR);
        }
    };

    exec(success, fail, null, "File", "resolveLocalFileSystemURI", [uri]);

};

module.exports = resolveLocalFileSystemURI;