
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
 * @module fileTransfer
 */
var argscheck = require('xFace/argscheck');
 /**
 * 文件上传选项设置（Android，iOS, WP8）<br/>
 * 应用场景参考{{#crossLink "FileTransfer/upload"}}{{/crossLink}}
 * @example
        var options = new FileUploadOptions();
        options.fileKey = "file";
        options.fileName = localFileName;
        options.mimeType = "text/plain";
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        var headers = new Object();
        headers.name = "Content-Length";
        headers.value = "10000";
 * @param {String} [fileKey="file"] 表单元素的name值。
 * @param {String} [fileName="image.jpg"] 希望文件存储到服务器所用的文件名。
 * @param {String} [mimeType="image/jpeg"] 正在上传数据所使用的mime类型。
 * @param {Object} [params]  通过HTTP请求发送到服务器的一系列可选键/值对。
 * @param {Object} [headers] 文件上传时的头部信息，如果一个头部有多个值，需要把这些值放在数组里面。
 * @class FileUploadOptions
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS, WP8
 */
var FileUploadOptions = function(fileKey, fileName, mimeType, params, headers) {
    argscheck.checkArgs('SSSOO', 'FileUploadOptions.FileUploadOptions', arguments);
    /**
     * 表单元素的name值（Android, iOS, WP8）
     * @property fileKey
     * @default "file"
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.fileKey = fileKey || null;
    /**
     * 文件存储到服务器所用的文件名（Android, iOS, WP8）
     * @property fileName
     * @default "image.jpg"
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.fileName = fileName || null;
    /**
     * 正在上传数据所使用的mime类型（Android, iOS, WP8）
     * @property mimeType
     * @default "image/jpeg"
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.mimeType = mimeType || null;
    /**
     * 通过HTTP请求发送到服务器的一系列可选键/值对（Android, iOS, WP8）
     * @property params
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.params = params || null;
    /**
     * 请求头键/值对,头的名字是请求头的键，头的值是请求头的值，多个请求头不能有相同的头名字（Android, iOS, WP8）
     * @property headers
     * @default null
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.headers = headers || null;
};

module.exports = FileUploadOptions;