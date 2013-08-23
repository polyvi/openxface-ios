
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
* 该模块提供向手机推送消息的功能
* @module push
* @main push
*/

/**
* 该类提供向手机推送消息的功能(Android, iOS, WP8)<br/>
* 该类不能通过new来创建相应的对象,只能通过xFace.PushNotification对象来直接使用该类定义的方法
* @class PushNotification
* @static
* @platform Android,iOS,WP8
* @since 3.0.0
*/
var exec = require('xFace/exec');
var argscheck = require('xFace/argscheck');
var PushNotification = function() {
    this.onReceived = null;
};

/**
* 当收到推送通知的回调函数
*/
PushNotification.prototype.fire = function(pushString) {
    if (this.onReceived) {
        this.onReceived(pushString);
    }
};

/**
* 注册一个监听器, 当手机收到推送消息时，该监听器会被回调(Android, iOS, WP8)<br/>
* @example
        xFace.PushNotification.registerOnReceivedListener(printPushData);
        function printPushData(info){
                alert(info);
            }
*@method registerOnReceivedListener
*@param {Function} listener 收到通知的监听
*@param {String} listener.message 收到通知的内容
*@platform Android, iOS, WP8
*@since 3.0.0
*/
PushNotification.prototype.registerOnReceivedListener = function(listener) {

    argscheck.checkArgs('f', 'PushNotification.registerOnReceivedListener', arguments);
    this.onReceived = listener;
    exec(null, null, null, "PushNotification", "registerOnReceivedListener", []);

};

/**
* 获取手机设备的唯一标识符(以UUID作为唯一标识符)(Android, iOS, WP8)<br/>
* @example
        xFace.PushNotification.getDeviceToken(success, error);
        function success(deviceToken){
                alert(deviceToken);
            };
        function error(err){
                alert(err);
            };
*@method getDeviceToken
*@param {Function} [successCallback] 成功回调函数
*@param {String} successCallback.deviceToken 手机的唯一标识符
*@param {Function} [errorCallback] 失败回调函数
*@param {String} errorCallback.err 失败的描述信息
*@platform Android, iOS, WP8
*@since 3.0.0
*/
PushNotification.prototype.getDeviceToken = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'PushNotification.getDeviceToken', arguments);
    exec(successCallback, errorCallback, null, "PushNotification", "getDeviceToken", []);
};

/**
* 通过服务器地址,端口号打开Push(Android)<br/>
* @example
        xFace.PushNotification.open(host,port,success, error);
        function success(deviceToken){
                alert(deviceToken);
            };
        function error(err){
                alert(err);
            };
*@method openPush
*@param {String} host 服务器的地址
*@param {String} port 服务器的端口号
*@param {Function} [successCallback] 成功回调函数
*@param {Function} [errorCallback] 失败回调函数
*@param {String} errorCallback.err 失败的描述信息
*@platform Android
*@since 3.0.0
*/
PushNotification.prototype.open = function(host,port,successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'PushNotification.open', arguments);
    exec(successCallback, errorCallback, null, "PushNotification", "open", [host,port]);
	};

module.exports = new PushNotification();