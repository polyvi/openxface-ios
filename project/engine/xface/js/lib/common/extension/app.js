
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
 * 该模块定义与应用（包含native应用和app应用）相关的一些功能，如app通信，native应用的启动、安装等
 * @module app
 * @main app
 */

 /**
  * 提供引擎的退出，打开url链接，清除历史/缓存，启动/安装本地应用等功能（Android, iOS,Wp8）<br/>
  * 该类不能通过new来创建相应的对象，只能通过navigator.app对象来直接使用该类中定义的方法
  * @class App
  * @platform Android, iOS, Wp8
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var app = function() {
};

/**
 * 调用系统默认程序（浏览器）打开一个url链接，如pdf，word，http地址等（Android, iOS,Wp8）
  @example
        var url = "http://www.baidu.com/index.html";
        function error(msg) {
            console.log("Error info: " + msg);
        }
        navigator.app.openUrl(url, success, error);

        url = "a/b/c/test.pdf";
        navigator.app.openUrl(url, success, error);
 * @method openUrl
 * @param {String} url 要打开文件的路径或链接地址
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @param {String} errorCallback.msg 失败描述信息
 * @platform Android, iOS, Wp8
 * @since 3.0.0
 */
app.prototype.openUrl = function(url, successCallback, errorCallback){
    argscheck.checkArgs('sFF', 'app.openUrl', arguments);
    exec(successCallback, errorCallback, null, "App", "openUrl", [url]);
};

/**
 * 获取渠道信息（Android, iOS, Wp8）
  @example
        function error() {
            console.log("getChannel error”);
        }
        function success(channel) {
            console.log("channel id: " + channel.id);
            console.log("channel name: " + channel.name);
        }
        navigator.app.getChannel(success, error);
 * @method getChannel
 * @param {Function} successCallback 成功回调函数
 * @param {object} successCallback.channel 渠道信息对象
 * @param {String} successCallback.channel.id 渠道唯一标识符
 * @param {String} successCallback.channel.name 渠道名称
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS, Wp8
 * @since 3.1.0
 */
app.prototype.getChannel = function(successCallback, errorCallback){
    argscheck.checkArgs('fF', 'app.getChannel', arguments);
    exec(successCallback, errorCallback, null, "Channel", "getChannel", []);
};

/**
 * 启动本地应用（Android, iOS, Wp8）
 * @example
        var url;
        var parameter;
        if(isAndroid())
        {
            url = "com.polyvi.largeFileTest";
            parameter = "";
        }
        else if(isWindowsPhone())
        {
            url = "tel:13900000000";
            parameter = "";
        }
        else
        {
            url = "mailto:test@polyvi.com";
            parameter = "?subject=openURLtest"
        }
        navigator.app.startNativeApp(url, parameter, win, fail);
 * @method startNativeApp
 * @param {String} packageName 对于android平台，此参数是指程序AndroidManifest.xml配置文件中配置的package属性值，即程序的包名；<br /> 对于iOS平台，此参数是指Info.plist中定义的Custome URL Scheme，请参考<a href="http://developer.apple.com/library/ios/#documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/AdvancedAppTricks/AdvancedAppTricks.html" class="crosslink">Custom URL Schemes</a>, <a class="crosslink" href="http://wiki.akosma.com/IPhone_URL_Schemes">IPhone URL Schemes</a>, <a class="crosslink" href="http://developer.apple.com/library/ios/#featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007899">iPhone URL Scheme Reference</a><br /> 对于WP8平台，此参数是指WMAppManifest.xml中定义的Custome URL Scheme,请参考<a href="http://msdn.microsoft.com/en-us/library/windowsphone/develop/jj206987(v=vs.105).aspx" class="crosslink">Auto-launching apps using file and URI associations for Windows Phone 8</a>
 * @param {String} [parameter] 程序启动的参数
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @for App
 * @platform Android, iOS, Wp8
 * @since 3.0.0
 */
app.prototype.startNativeApp = function(packageName, parameter, successCallback, errorCallback){
    argscheck.checkArgs('sSFF', 'App.startNativeApp', arguments);
    exec(successCallback, errorCallback, null, "App", "startNativeApp", [packageName, parameter]);
};

/**
 * 使当前应用返回到前一个页面，函数功能就和android上的back按钮相同（Android,Wp8）
 * @example
 navigator.app.backHistory(win,fail);
 * @method backHistory
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @for App
 * @platform Android, Wp8
 * @since 3.0.0
 */

/**
 * 退出引擎程序，即关闭引擎（Android,Wp8）
 * @example
 navigator.app.exitApp();
 * @method exitApp
 * @for App
 * @platform Android, Wp8
 * @since 3.0.0
 */

module.exports = new app();