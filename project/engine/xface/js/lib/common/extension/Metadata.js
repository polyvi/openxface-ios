
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
 * 该接口提供了文件或目录的状态信息（Android, iOS, WP8）<br/>
 * 可以通过{{#crossLink "DirectoryEntry"}}{{/crossLink}}对象或者
 * {{#crossLink "FileEntry"}}{{/crossLink}}对象的getMetadata方法获取Metadata的实例
 * @class Metadata
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var Metadata = function(time) {
    /**
     * 文件或目录的最后修改时间(Android, iOS, WP8)<br/>
     * @example
        function success(metadata) {
            console.log("Last Modified Time: " + metadata.modificationTime);
        }
        //请求此目录的metadata对象
        dirEntry.getMetadata(success, null);
     * @property modificationTime
     * @type Date
     * @default null
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.modificationTime = (typeof time != 'undefined'?new Date(time):null);
};

module.exports = Metadata;