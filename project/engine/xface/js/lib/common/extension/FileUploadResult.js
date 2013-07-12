
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
 
 /**
 * 文件上传成功时成功回调返回的相关信息（Android，iOS, WP8）<br/>
 * 应用场景参考{{#crossLink "FileTransfer/upload"}}{{/crossLink}}
 * @class FileUploadResult
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS, WP8
 */
var FileUploadResult = function() {
    /**
     * 已经向服务器所上传的字节数（Android, iOS, WP8）
     * @property bytesSent
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.bytesSent = 0;
    /**
     * 服务器端返回的HTTP响应代码（Android, iOS, WP8）
     * @property responseCode
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.responseCode = null;
    /**
     * 服务器端返回的HTTP响应数据（Android, iOS, WP8）
     * @property response
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.response = null;
};

module.exports = FileUploadResult;