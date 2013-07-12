
/*
 Copyright 2012-2013, Polyvi Inc. (http://www.xface3.com)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
 */
/**
 * 该模块定义普通文件传输和高级文件传输（断点下载与上传）相关的一些功能。
 * @module fileTransfer
 * @main   fileTransfer
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

/**
 * 提供高级文件传输（断点下载与上传），暂停，取消等功能（Android，iOS）<br/>
 * @example
        var uploadUrl = "http://polyvi.net:8091/mi/UploadServer";
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer1 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe");//构造下载对象
        var fileTransfer2 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);//构造下载对象
        var fileTransfer3 = new xFace.AdvancedFileTransfer("test_upload2.rar", uploadUrl, true); //构造上传对象
 * @param {String} source 文件传输的源文件地址（下载时为服务器地址，上传时为本地地址（只能在workspace目录下））
 * @param {String} target 文件传输的目标地址（下载时为本地地址（可以为工作目录也可以指定其他路径，其他路径用file://头标示），上传时为服务器地址）
 * @param {boolean} [isUpload=false] 标识是上传还是下载（默认为false，即默认为下载，iOS目前还不支持上传）
 * @class AdvancedFileTransfer
 * @namespace xFace
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS
 */
var AdvancedFileTransfer = function(source, target, isUpload) {
    argscheck.checkArgs('ssB', 'AdvancedFileTransfer.AdvancedFileTransfer', arguments);
    this.source = source;
    this.target = target;
    this.isUpload = isUpload || false;
    /**
    * 用于接收文件传输的进度通知，该回调函数包含一个类型为Object的参数，该参数包含以下属性：（Android，iOS）<br/>
    * loaded: 已经传输的文件块大小<br/>
    * total: 要传输的文件总大小
    * @property onprogress
    * @type Function
    * @platform Android, iOS
    * @since 3.0.0
    */
    this.onprogress = null;     // While download the file, and reporting partial download data
};

/**
 * 下载一个文件到指定的路径(Android, iOS)<br/>
 * 下载过程中会通过onprogress属性更新文件传输进度。
 * @example
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);
        fileTransfer.download(success, fail);
        fileTransfer.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        function success(entry) {
            alert("success");
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert(error.code);
            alert(error.source);
            alert(error.target);
        }
 * @method download
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry} successCallback.fileEntry 成功回调返回下载得到的文件的{{#crossLink "FileEntry"}}{{/crossLink}}对象
 * @param {Function} [errorCallback]   失败回调函数
 * @param {Object} errorCallback.errorInfo 失败回调返回的参数
 * @param {Number} errorCallback.errorInfo.code 错误码（在<a href="FileTransferError.html">FileTransferError</a>中定义）
 * @param {String} errorCallback.errorInfo.source 下载源地址
 * @param {String} errorCallback.errorInfo.target 下载目标地址
 * @platform Android, iOS
 * @since 3.0.0
 */
AdvancedFileTransfer.prototype.download = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'AdvancedFileTransfer.download', arguments);
    var win = function(result) {
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
        successCallback(entry);
    };
    var me = this;
    var s = function(result) {
        if (typeof me.onprogress === "function") {
                me.onprogress(new ProgressEvent("progress", {loaded:result.loaded, total:result.total}));
            }
    };

    exec(win, errorCallback, s, 'AdvancedFileTransfer', 'download', [this.source, this.target]);
};

/**
*  暂停文件传输操作（上传/下载）（Android, iOS）<br/>
*  @example
        //构造下载对象，先调用下载接口，然后调用暂停接口暂停下载
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer1 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);
        fileTransfer1.download(success, fail);
        fileTransfer1.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer1.pause();
        //构造上传对象，先调用上传接口，然后调用暂停接口暂停上传。
        var uploadUrl = "http://polyvi.net:8091/mi/UploadServer";
        var fileTransfer2 = new xFace.AdvancedFileTransfer("test_upload2.rar",uploadUrl,true);
        fileTransfer2.upload(success, fail);
        fileTransfer2.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer2.pause();
        function success() {
            alert("success");
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert(error.code);
            alert(error.source);
            alert(error.target);
        }
*  @method pause
*  @platform Android, iOS
*  @since 3.0.0
*/
AdvancedFileTransfer.prototype.pause = function() {
    exec(null, null, null, 'AdvancedFileTransfer', 'pause', [this.source]);
};

/**
*  取消文件的传输操作（上传/下载），相应的临时文件也会被删除（Android, iOS）<br/>
*  @example
        //构造下载对象，先调用下载接口，然后调用取消接口取消下载。
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer1 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);
        fileTransfer1.download(success, fail);
        fileTransfer1.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer1.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer1.cancel();
        //构造上传对象，先调用上传接口，然后调用取消接口取消上传。
        var uploadUrl = "http://polyvi.net:8091/mi/UploadServer";
        var fileTransfer2 = new xFace.AdvancedFileTransfer("test_upload2.rar",uploadUrl,true);
        fileTransfer2.upload(success, fail)
        fileTransfer2.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer2.cancel();
        function success() {
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert(error.code);
            alert(error.source);
            alert(error.target);
        }
*  @method cancel
*  @platform Android, iOS
*  @since 3.0.0
*/
AdvancedFileTransfer.prototype.cancel = function() {
    exec(null, null, null, 'AdvancedFileTransfer', 'cancel', [this.source, this.target, this.isUpload]);
};

module.exports = AdvancedFileTransfer;
