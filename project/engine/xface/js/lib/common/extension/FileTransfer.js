
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
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileTransferError = require('xFace/extension/FileTransferError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

function newProgressEvent(result) {
    var pe = new ProgressEvent();
    pe.lengthAvailable = result.lengthAvailable;
    pe.loaded = result.loaded;
    pe.total = result.total;
    return pe;
}

var idCounter = 0;

/**
 * 提供普通文件传输（非断点的文件传输），终止等功能（Android，iOS, WP8）<br/>
 * 该类通过new来创建相应的对象，然后根据对象来使用该类中定义的方法
 * @example
        var fileTransfer = new FileTransfer();
 * @class FileTransfer
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS, WP8
 */
var FileTransfer = function() {
    /**
     * 文件传输任务的id，只有提供了id，传输任务才会实时更新进度条，_id从0开始计数（Android, iOS, WP8）
     */
    this._id = ++idCounter;
    /**
     * 文件传输的进度回调函数，该回调函数包含一个类型为{{#crossLink "ProgressEvent"}}{{/crossLink}}的参数，该参数要用到以下属性：（Android，iOS）<br/>
     * loaded: 已经传输的文件块大小，单位byte<br/>
     * total: 要传输的文件总大小，单位byte
     * @property onprogress
     * @type Function
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.onprogress = null; // optional callback
};

/**
 * 下载一个文件到指定的路径(Android, iOS, WP8)<br/>
 * 下载过程中会通过onprogress属性更新文件传输进度
 * @example
        var fileTransfer = new FileTransfer();
        var remoteFile = "http://192.168.2.245/develop/test/test.css";
        var localFileName = "test.css";
		fileTransfer.download(remoteFile,localFileName,success,fail);
        fileTransfer.onprogress = function(evt) {
            var progress  = evt.loaded / evt.total;
        };
        function success(entry) {
            alert("download succeeded");
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert("download failed" );
            alert(error.code);
            alert(error.source);
            alert(error.target);
            alert(error.http_status);
        }
 * @method download
 * @param {String} source     文件所在的服务器URL
 * @param {String} target     将要下载到的指定路径
 * @param {Function} successCallback 成功回调函数
 * @param {FileEntry} successCallback.fileEntry 成功回调返回下载得到的文件对象
 * @param {Function} [errorCallback] 失败回调函数
 * @param {Object} errorCallback.errorInfo 失败回调返回的错误信息
 * @param {Number} errorCallback.errorInfo.code 错误码（在<a href="FileTransferError.html">FileTransferError</a>中定义）
 * @param {String} errorCallback.errorInfo.source 下载源地址
 * @param {String} errorCallback.errorInfo.target 下载目标地址
 * @param {Number} errorCallback.errorInfo.http_status 文件传输的HTTP状态码（例如404：页面不存在或链接错误）
 * @param {Boolean} [trustAllHosts=false]  是否信任所有服务器 (仅支持Android平台,例如： 自签名认证服务器)
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileTransfer.prototype.download = function(source, target, successCallback, errorCallback, trustAllHosts) {
    argscheck.checkArgs('ssfFB', 'FileTransfer.download', arguments);
    //预先检查可能的错误
    if (!source || !target) throw new Error("FileTransfer.download requires source URI and target URI parameters at the minimum.");
    var self = this;
    var win = function(result) {
        if (typeof result.lengthAvailable != "undefined") {
            if (self.onprogress) {
                return self.onprogress(newProgressEvent(result));
            }
        }
        else {
            var entry = null;
            if (result.isDirectory) {
                entry = new DirectoryEntry();
            }
            else if (result.isFile) {
                entry = new FileEntry();
            }
            entry.isDirectory = result.isDirectory;
            entry.isFile = result.isFile;
            entry.name = result.name;
            entry.fullPath = result.fullPath;
            entry.start = result.start;
            entry.end = result.end;
            successCallback(entry);
        }
    };

    var fail = function(e) {
        var error = new FileTransferError(e.code, e.source, e.target, e.http_status);
        errorCallback(error);
    };

    exec(win, errorCallback, null, 'FileTransfer', 'download', [source, target, trustAllHosts, this._id]);
};

/**
 * 上传文件到服务器（Android，iOS, WP8）<br/>
 * 上传过程中会通过onprogress属性更新文件传输进度
 * @example
        var localFilePath = "file:///mnt/sdcard/upload.txt";
        var localFileName = "upload.txt";
        var remoteFile = "http://apollo.polyvi.com/index.php";
        var fileTransfer = new FileTransfer();
        var options = new FileUploadOptions();
        options.fileKey = "file";
        options.fileName = localFileName;
        options.mimeType = "text/plain";
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        fileTransfer.onprogress = function(evt) {
            var progress  = evt.loaded / evt.total;
        };
        // removing options cause Android to timeout
        fileTransfer.upload(localFilePath, remoteFile, uploadWin, uploadFail, options);
        function uploadWin(result) {
            alert("success");
            alert("Code = " + result.responseCode);
            alert("Response = " + result.response);
            alert("Sent = " + result.bytesSent);
        }
        function uploadFail(error) {
            alert("failed");
            alert("An error has occurred: Code = " + error.code);
            alert("upload error source " + error.source);
            alert("upload error target " + error.target);
        }
 * @method upload
 * @param {String} filePath 要上传的本地文件路径
 * @param {String} server 接收文件的服务器地址
 * @param {Function} successCallback 成功回调函数
 * @param {Number} successCallback.responseCode 服务器端返回的HTTP响应代码
 * @param {String} successCallback.response 服务器端返回的HTTP响应
 * @param {Number} successCallback.bytesSent 向服务器所发送的字节数
 * @param {Function} [errorCallback] 失败回调函数
 * @param {Object} errorCallback.errorInfo 失败回调返回的错误信息
 * @param {Number} errorCallback.errorInfo.code 错误码（在<a href="FileTransferError.html">FileTransferError</a>中定义）
 * @param {String} errorCallback.errorInfo.source 上传源地址
 * @param {String} errorCallback.errorInfo.target 上传目标地址
 * @param {FileUploadOptions} [options] 文件上传选项，参见{{#crossLink "FileUploadOptions"}}{{/crossLink}}。
 * @param {Boolean} [trustAllHosts=false]  是否信任所有服务器 (仅支持Android平台,例如： 自签名认证服务器)。
 * @platform Android, iOS, WP8
 * @since 3.0.0
*/
FileTransfer.prototype.upload = function(filePath, server, successCallback, errorCallback, options, trustAllHosts) {
    argscheck.checkArgs('ssfFOB', 'FileTransfer.upload', arguments);
    // 参数检查
    if (!filePath || !server) throw new Error("FileTransfer.upload requires filePath and server URL parameters at the minimum.");
    // 检查options
    var fileKey = null;
    var fileName = null;
    var mimeType = null;
    var params = null;
    var chunkedMode = true;
    var headers = null;
    if (options) {
        fileKey = options.fileKey;
        fileName = options.fileName;
        mimeType = options.mimeType;
        headers = options.headers;
        if (options.chunkedMode !== null || typeof options.chunkedMode != "undefined") {
            chunkedMode = options.chunkedMode;
        }
        if (options.params) {
            params = options.params;
        }
        else {
            params = {};
        }
    }

    var fail = function(e) {
        var error = new FileTransferError(e.code, e.source, e.target, e.http_status);
        errorCallback(error);
    };
    var self = this;
    var win = function(result) {
        if (typeof result.lengthAvailable != "undefined") {
            if (self.onprogress) {
                return self.onprogress(newProgressEvent(result));
            }
        } else {
            return successCallback(result);
        }
    };
    exec(win, fail, null, 'FileTransfer', 'upload', [filePath, server, fileKey, fileName, mimeType, params, trustAllHosts, chunkedMode, headers, this._id]);
};

/**
 * 取消该对象正在进行的文件传输任务（Android，iOS, WP8）<br/>
 * @example
        var localFilePath = "file:///mnt/sdcard/upload.txt";
        var localFileName = "upload.txt";
        var remoteFile = "http://apollo.polyvi.com/index.php";
        var fileTransfer = new FileTransfer();
        var options = new FileUploadOptions();
        options.fileKey = "file";
        options.fileName = localFileName;
        options.mimeType = "text/plain";
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        fileTransfer.onprogress = function(evt) {
            var progress  = evt.loaded / evt.total;
        };
        // removing options cause Android to timeout
        fileTransfer.upload(localFilePath, remoteFile, uploadWin, uploadFail, options);
        fileTransfer.abort();
        function uploadWin(result) {
            alert("success");
            alert("Code = " + result.responseCode);
            alert("Response = " + result.response);
            alert("Sent = " + result.bytesSent);
        }
        function uploadFail(error) {
            alert("failed");
            alert("An error has occurred: Code = " + error.code);
            alert("upload error source " + error.source);
            alert("upload error target " + error.target);
        }
        function abortWin() {
            alert("abort success");
        }
        function abortFail(errorMessage) {
            alert("abort failed");
            alert(errorMessage);
        }
 * @method abort
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @param {String} errorCallback.errorMessage 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
FileTransfer.prototype.abort = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'FileTransfer.abort', arguments);
    exec(successCallback, errorCallback, null, 'FileTransfer', 'abort', [this._id]);
};

module.exports = FileTransfer;