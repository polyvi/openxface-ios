
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
 * 该模块定义一些系统相关的通知信息和提示框。
 * @module notification
 * @main   notification
 */

  /**
  * 该类提供一系列基础api，用于发出系统通知信息和弹出系统提示框（Android, iOS, WP8）<br/>
  * 该类不能通过new来创建相应的对象，只能通过navigator.notification对象来直接使用该类中定义的方法
  * @class Notification
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
    var notification = function() {};

/**
 * 弹出一个本地的alert对话框，开发者可以设定对话框的标题（Android, iOS, WP8）<br/>
 * @example
        function alertCallback(){
            console.log("Alert dismissed.");
        }
        var message = "You pressed alert.";
        var title = "Alert Dialog";
        var button = "Continue";
        navigator.notification.alert(message, alertCallback, title, button);
 * @method alert
 * @param {String} [message] 对话框要显示的消息
 * @param {Function} [alertCallback] 用户点击按钮后的回调函数
 * @param {String} [title="Alert"] 对话框的标题
 * @param {String} [buttonLabel="OK"] 对话框的按钮名
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
notification.prototype.alert = function(message, alertCallback, title, buttonLabel){
    argscheck.checkArgs('SFSS', 'navigator.notification.alert', arguments);
    var _title = (title || "Alert");
    var _buttonLabel = (buttonLabel || "OK");
    exec(alertCallback, null, null, "Notification", "alert", [message, _title, _buttonLabel]);
};

 /**
 * 弹出一个本地的confirm对话框，开发者可以设定对话框的标题和按钮，用户点击结果会返回给回调函数（Android, iOS, WP8）<br/>
 * @example
        var message = "You pressed confirm.";
        var title = "Confirm Dialog";
        var buttons = "Yes,No,Maybe";
        function alertCallback(r) {
            console.log("You selected " + r);
            alert("You selected " + (buttons.split(","))[r-1]);
        }
        navigator.notification.confirm(message, alertCallback, title, buttons);
 * @method confirm
 * @param {String} [message] 对话框要显示的消息
 * @param {Function} [alertCallback] 用户点击按钮后的回调函数
 * @param {Number} alertCallback.selectedIndex 用户选择的按钮索引号（从1开始）
 * @param {String} [title="Confirm"] 对话框的标题
 * @param {String} [buttonLabel="OK,Cancel"] 对话框上所有按钮标签，用逗号隔开，与对话框上的按钮名一一对应
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
notification.prototype.confirm = function(message, alertCallback, title, buttonLabels){
    argscheck.checkArgs('SFSS', 'navigator.notification.confirm', arguments);
    var _title = (title || "Confirm");
    var _buttonLabels = (buttonLabels || "OK,Cancel");
    exec(alertCallback, null, null, "Notification", "confirm", [message, _title, _buttonLabels]);
};

 /**
 * 调用系统接口使设备发出震动提示（Android, iOS, WP8）<br/>
 * @example
        navigator.notification.vibrate(1000);
 * @method vibrate
 * @param {Number} millseconds 震动的毫秒数，在iOS上该参数无效
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
notification.prototype.vibrate = function(millseconds) {
    argscheck.checkArgs('n', 'navigator.notification.vibrate', arguments);
    exec(null, null, null, "Notification", "vibrate", [millseconds]);
};

 /**
 * 调用系统接口使设备将发出蜂鸣声.（Android, iOS, WP8）<br/>
 * @example
        navigator.notification.beep(3);
 * @method beep
 * @param {Number} counts 蜂鸣声的重复次数，在iOS上该参数无效
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
notification.prototype.beep = function(counts) {
    argscheck.checkArgs('n', 'navigator.notification.beep', arguments);
    exec(null, null, null, "Notification", "beep", [counts]);
};

module.exports = new notification();
