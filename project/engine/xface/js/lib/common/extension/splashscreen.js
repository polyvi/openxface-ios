
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
 * 该模块提供对系统界面的支持
 * @module ui
 * @main ui
 */

 /**
  * 该类提供splash界面的显示和隐藏功能（Android, iOS, WP8）<br/>
  * 该类只能通过navigator.splashscreen来直接使用该类中定义的方法
  * @class SplashSreen
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var SplashScreenExport = {};

/**
 * 显示splash界面（Android, iOS, WP8）
 * @example
        var imageName = "SpalshScreen.jpg";
        navigator.splashscreen.show(
            function() {
                document.getElementById('status').innerHTML = "Success";
            },
            function() {
                console.log("Error show SplashScreen ");
                document.getElementById('status').innerHTML = "Error show splashscreen.";
            },
            imageName);
 * @method show
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @platform Android, iOS, WP8
 * @param {String} [imagePath] 相对于workspace的图片路径，如果该路径无效则显示系统默认图片
 * @since 3.0.0
 */
SplashScreenExport.show = function(successCallback, errorCallback, imagePath) {
    argscheck.checkArgs('FFS', 'navigator.splashscreen.show', arguments);
    exec(successCallback, errorCallback, null, "SplashScreen", "show", [imagePath]);
};

/**
 * 隐藏splash界面（Android, iOS, WP8）
 * @example
        navigator.splashscreen.hide(
            function() {
                document.getElementById('status').innerHTML = "Success";
            },
            function() {
                console.log("Error show SplashScreen ");
                document.getElementById('status').innerHTML = "Error show splashscreen."});
 * @method hide
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
SplashScreenExport.hide = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'navigator.splashscreen.hide', arguments);
    exec(successCallback, errorCallback, null, "SplashScreen", "hide", []);
};
module.exports = SplashScreenExport;