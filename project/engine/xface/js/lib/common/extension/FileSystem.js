
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
    DirectoryEntry = require('xFace/extension/DirectoryEntry');

/**
 * FileSystem对象表示文件系统的信息（Android，iOS, WP8）
 * @example
         function createFileSystem(systemName, fileName, fullPath) {
            var root = new DirectoryEntry(fileName, fullPath);
            var fileSystem = new FileSystem(systemName, root);
         }
 * @param {String} name 标识文件系统的名称
 * @param {DirectoryEntry} root 文件系统的根目录
 * @class FileSystem
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS, WP8
 */
var FileSystem = function(name, root) {
    argscheck.checkArgs('so', 'FileSystem.FileSystem', arguments);
    /**
     * 标识文件系统的名称,并且该名称在文件系统中是唯一的（Android，iOS, WP8）
     * @example
            function onSuccess(fileSystem) {
                console.log(fileSystem.name);
            }
     * @property name
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.name = name || null;
    if (root) {
        /**
         * 文件系统的根目录（Android，iOS, WP8）
         * @example
            function onSuccess(fileSystem) {
                console.log(fileSystem.root.name);
            }
         * @property root
         * @type DirectoryEntry
         * @platform Android, iOS, WP8
         * @since 3.0.0
         */
        this.root = new DirectoryEntry(root.name, root.fullPath);
    }
};

module.exports = FileSystem;