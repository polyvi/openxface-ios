
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
 * 该模块提供对设备音频、图像和视频采集功能的访问
 * @module capture
 * @main capture
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    MediaFile = require('xFace/extension/MediaFile');

/**
 * 根据不同类型启动一个capture
 * @param (String} type 媒体文件格式类型，类型包括:captureImage、captureAudio和captureVideo
 * @param {Function} successCallback 成功回调函数
 * @param {Function} errorCallback 失败回调函数
 * @param {CaptureImageOptions | CaptureAudioOptions | CaptureVideoOptions} options
 */
function captureMedia(type, successCallback, errorCallback, options) {
    var win = function(result) {
        var mediaFiles = [];
        for (var i = 0; i < result.length; i++) {
            var mediaFile = new MediaFile();
            mediaFile.name = result[i].name;
            mediaFile.fullPath = result[i].fullPath;
            mediaFile.type = result[i].type;
            mediaFile.lastModifiedDate = result[i].lastModifiedDate;
            mediaFile.size = result[i].size;
            mediaFiles.push(mediaFile);
        }
        successCallback(mediaFiles);
    };
    exec(win, errorCallback, null, "Capture", type, [options]);
}
  /**
  * 该类提供对设备音频、图像和视频采集功能的访问（Android, iOS, WP8）<br/>
  * 只能通过navigator.device.capture来使用该类中定义的方法
  * @class Capture
  * @static
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
function Capture() {
    this.supportedAudioModes = [];
    this.supportedImageModes = [];
    this.supportedVideoModes = [];
}

/**
 * 启动照相机应用进行拍照操作（Android, iOS, WP8）<br/>
 * @example
        function captureImage() {
            navigator.device.capture.captureImage(successCallback , errorCallback, {limit: 1});
        }
        function successCallback (mediaFiles) {
            console.log("The name of media file is " + mediaFiles[0].name);
            console.log("The full path of media file is " + mediaFiles[0].fullPath);
            console.log("The size of media file is " + mediaFiles[0].size);
        }
        function errorCallback(error) {
            var msg = 'An error occurred during capture: ' + error.code;
            console.log(msg);
        }
 * @method captureImage
 * @param {Function} [successCallback] 成功回调函数
 * @param {MediaFile[]} successCallback.mediaFiles 返回采集到的图像文件集合
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 返回错误信息
 * @param {CaptureImageOptions} [options] 封装图像采集的配置选项
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Capture.prototype.captureImage = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureImage', arguments);
    captureMedia("captureImage", successCallback, errorCallback, options);
};

/**
 * 启动照相机应用进行录音操作（Android, iOS, WP8）<br/>
 * @example
        function captureAudio() {
            navigator.device.capture.captureAudio(successCallback , errorCallback, {limit: 1});
        }
        function successCallback (mediaFiles) {
            console.log("The name of media file is " + mediaFiles[0].name);
            console.log("The full path of media file is " + mediaFiles[0].fullPath);
            console.log("The size of media file is " + mediaFiles[0].size);
        }
        function errorCallback(error) {
            var msg = 'An error occurred during capture: ' + error.code;
            console.log(msg);
        }
 * @method captureAudio
 * @param {Function} [successCallback] 成功回调函数
 * @param {MediaFile[]} successCallback.mediaFiles 返回采集到的音频文件集合
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 返回错误信息
 * @param {CaptureAudioOptions} [options] 封装音频采集的配置选项
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Capture.prototype.captureAudio = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureAudio', arguments);
    captureMedia("captureAudio", successCallback, errorCallback, options);
};

/**
 * 启动照相机应用进行摄像操作（Android, iOS, WP8）<br/>
 * @example
        function captureVideo() {
            navigator.device.capture.captureVideo(successCallback , errorCallback, {limit: 1});
        }
        function successCallback (mediaFiles) {
            console.log("The name of media file is " + mediaFiles[0].name);
            console.log("The full path of media file is " + mediaFiles[0].fullPath);
            console.log("The size of media file is " + mediaFiles[0].size);
        }
        function errorCallback(error) {
            var msg = 'An error occurred during capture: ' + error.code;
            console.log(msg);
        }
 * @method captureVideo
 * @param {Function} [successCallback] 成功回调函数
 * @param {MediaFile[]} successCallback.mediaFiles 返回采集到的视频文件集合
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 返回错误信息
 * @param {CaptureVideoOptions} [options] 封装视频采集的配置选项
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Capture.prototype.captureVideo = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureVideo', arguments);
    captureMedia("captureVideo", successCallback, errorCallback, options);
};

/**
 * 对屏幕进行截屏操作（Android, iOS）<br/>
 * @example
        function save_defaultWorkspace(){
            document.getElementById('status').innerText = "save_defaultWorkspace";
            document.getElementById('result').innerText = "";
            var options = getOptions();
            options.destinationType = CaptureScreenOptions.DestinationType.FILE_URI;
            navigator.device.capture.captureScreen(success, error, options);
        }

        function success(result) {
            console.log("success: " + result.result);
        }

        function error(result) {
            var msg = "unkown error";
            if(result.code == CaptureScreenResult.ARGUMENT_ERROR) {
                msg = "invalid argument";
            } else if(result.code == CaptureScreenResult.IO_ERROR) {
                msg = "io exception";
            } 
            console.log("error:" + msg);
        }
 * @method captureScreen
 * @param {Function} [successCallback] 成功回调函数
 * @param {CaptureScreenResult} successCallback.captureScreenResult 截屏成功结果,返回一个{{#crossLink "CaptureScreenResult"}}{{/crossLink}}对象
 * @param {Number} successCallback.captureScreenResult.code       截屏结果码（在<a href="CaptureScreenResult.html">CaptureScreenResult</a>中定义）
 * @param {String} successCallback.captureScreenResult.result  截屏结果,当options.destinationType为DATAURL时:返回base64编码的截图数据,为FILEURI时返回文件url
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureScreenResult} errorCallback.captureScreenResult 截屏失败结果，截屏结果,返回一个{{#crossLink "CaptureScreenResult"}}{{/crossLink}}对象
 * @param {Number} errorCallback.captureScreenResult.code 截屏结果码（在<a href="CaptureScreenResult.html">CaptureScreenResult</a>中定义）
 * @param {String} errorCallback.captureScreenResult.result  截屏错误信息
 * @param {CaptureScreenOptions} [options] 封装屏幕截图的配置选项,如果不传则默认返回图片的base64编码。
 * @platform Android, iOS
 * @since 3.0.0
 */
Capture.prototype.captureScreen = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureScreen', arguments);
    exec(successCallback, errorCallback, null, "Capture", "captureScreen", [options]);
};

module.exports = new Capture();