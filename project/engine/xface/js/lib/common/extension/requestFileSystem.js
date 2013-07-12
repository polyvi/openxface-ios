
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

var argscheck = require('xFace/argscheck'),
    FileError = require('xFace/extension/FileError'),
    FileSystem = require('xFace/extension/FileSystem'),
    exec = require('xFace/exec');

/**
 * 请求一个文件系统来存储应用数据
 * @param type  文件系统的类型
 * @param size  指示应用期望的存储大小（bytes）
 * @param successCallback  成功的回调函数
 * @param [errorCallback]    失败的回调函数
 */
var requestFileSystem = function(type, size, successCallback, errorCallback) {
    argscheck.checkArgs('nnfF', 'requestFileSystem', arguments);
    var fail = function(code) {
        if (typeof errorCallback === 'function') {
            errorCallback(new FileError(code));
        }
    };

    //TODO:目前只支持两个文件类型，以后可能会增加如APPLICATION这样的类型
    var LocalFileSystem_TEMPORARY = 0;  //临时文件
    var LocalFileSystem_PERSISTENT = 1; //持久文件
    if (type < LocalFileSystem_TEMPORARY || type > LocalFileSystem_PERSISTENT) {
        fail(FileError.SYNTAX_ERR);
    } else {
        // 如果成功，返回FileSystem对象
        var success = function(fileSystem) {
            if (fileSystem) {
                if (typeof successCallback === 'function') {

                    var result = new FileSystem(fileSystem.name, fileSystem.root);
                    successCallback(result);
                }
            }
            else {
                fail(FileError.NOT_FOUND_ERR);
            }
        };
        exec(success, fail, null, "File", "requestFileSystem", [type, size]);
    }
};

module.exports = requestFileSystem;