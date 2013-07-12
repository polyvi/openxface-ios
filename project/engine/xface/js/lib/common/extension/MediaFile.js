
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
 * @module capture
 */
var utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    File = require('xFace/extension/File'),
    CaptureError = require('xFace/extension/CaptureError'),
    argscheck = require('xFace/argscheck');
 /**
  * 封装了多媒体采集文件的属性（Android, iOS, WP8）<br/>
  * @class MediaFile
  * @constructor
  * @extends File
  * @param {String} name 文件名, 不包含路径信息
  * @param {String} fullPath  文件的绝对路径，包含文件名
  * @param {String} type  MIME类型，应该符合RFC2046规范，例如："video/3gpp"，"video/quicktime"，"image/jpeg"，"audio/amr"，"audio/wav"
  * @param {Date} lastModifiedDate 文件的最新修改时间
  * @param {Number} size 文件大小（以比特为单位）
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var MediaFile = function(name, fullPath, type, lastModifiedDate, size){
    MediaFile.__super__.constructor.apply(this, arguments);
};

utils.extend(MediaFile, File);

/**
 * 请求一个指定路径和类型的文件的格式信息（Android, iOS, WP8）<br/>
 * @example
        function getFormatData() {
            mediaFile.getFormatData(successCallback, errorCallback);
        }
        function successCallback(media) {
            console.log("media.height = " + media.height);
            console.log("media.width = " + media.width);
        }
 * @method getFormatData
 * @param {Function} successCallback 成功回调函数
 * @param {MediaFileData} successCallback.media 多媒体文件的格式信息
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 错误信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MediaFile.prototype.getFormatData = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'mediaFile.getFormatData', arguments);
    if (typeof this.fullPath === "undefined" || this.fullPath === null) {
        errorCallback(new CaptureError(CaptureError.CAPTURE_INVALID_ARGUMENT));
    } else {
        exec(successCallback, errorCallback, null, "Capture", "getFormatData", [this.fullPath, this.type]);
    }
};

module.exports = MediaFile;