
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
 * 该类主要封装文件传输中错误信息，同时定义了一些错误码常量（Android, iOS, WP8）<br/>
 * 该类的应用场景参考{{#crossLink "xFace.AdvancedFileTransfer"}}{{/crossLink}}和
 * {{#crossLink "FileTransfer"}}{{/crossLink}}
 * @class FileTransferError
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

 /**
 * 本构造方法用于构造文件传输错误信息类<br/>
 * 应用场景参考{{#crossLink "xFace.AdvancedFileTransfer"}}{{/crossLink}}和
 * {{#crossLink "FileTransfer"}}{{/crossLink}}
 * @example
        var error = new FileTransferError(1, "test.exe", "http://apollo.polyvi.com/404", 404);
 * @param {Number} code 文件传输的错误码
 * @param {String} source 文件传输的源文件地址（下载时为服务器地址，上传时为本地地址）
 * @param {String} target 文件传输的目标地址（下载时为本地地址，上传时为服务器地址）
 * @param {Number} status 文件传输的HTTP状态码（例如404：页面不存在或链接错误）
 * @since 3.0.0
 * @platform Android, iOS, WP8
 * @class FileTransferError
 * @private
 * @constructor
 */
var FileTransferError = function(code, source, target, status) {
    /**
     * 用于标识文件传输的错误码（Android, iOS, WP8）
     * @property code
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.code = code || null;
     /**
     * 用于标识文件传输的源文件地址（下载时为服务器地址，上传时为本地地址）（Android, iOS, WP8）
     * @property source
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.source = source || null;
     /**
     * 用于标识文件传输的目标地址（下载时为本地地址，上传时为服务器地址）（Android, iOS, WP8）
     * @property target
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.target = target || null;
     /**
     * 用于标识文件传输的HTTP状态码（例如404：页面不存在或链接错误）（Android, iOS, WP8）
     * @property status
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.http_status = status || null;
};

/**
 * 用于标识文件传输过程中文件找不到错误,对应错误码1（Android, iOS, WP8）
 * @property FILE_NOT_FOUND_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileTransferError.FILE_NOT_FOUND_ERR = 1;

/**
 * 用于标识文件传输过程中url地址无效错误,对应错误码2（Android, iOS, WP8）
 * @property INVALID_URL_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileTransferError.INVALID_URL_ERR = 2;

/**
 * 用于标识文件传输过程中连网错误,对应错误码3（Android, iOS, WP8）
 * @property CONNECTION_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileTransferError.CONNECTION_ERR = 3;

/**
 * 用于标识文件传输过程中文件传输被终止错误,对应错误码4（Android, iOS, WP8）
 * @property ABORT_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileTransferError.ABORT_ERR = 4;

module.exports = FileTransferError;

