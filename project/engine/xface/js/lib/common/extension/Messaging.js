
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
 * 该模块定义发送，获取和查找短信相关的一些功能.
 * @module message
 * @main message
 */

/**
 * 该类实现了对短信的一系列操作，包括新建短信，发送短信，查找短信等（Android, iOS, WP8）<br/>
 * 该类不能通过new来创建相应的对象，只能通过xFace.Messaging对象来直接使用该类中定义的方法<br/>
 * 相关参考： {{#crossLink "xFace.Message"}}{{/crossLink}}, {{#crossLink "xFace.MessageTypes"}}{{/crossLink}}, {{#crossLink "xFace.MessageFolderTypes"}}{{/crossLink}}
 * @class Messaging
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    Message = require('xFace/extension/Message');

var Messaging = function() {
};

/**
 * 新建信息，根据messageType新建信息，目前支持短息和Email类型（Android, iOS, WP8）<br/>
 * @example
        xFace.Messaging.createMessage(xFace.MessageTypes.SMSMessage, successCallback, errorCallback);
        function successCallback(message){alert(message.type);}
        function errorCallback(){alert("failed");}
 * @method createMessage
 * @param {String} messageType 信息类型（如MMS,SMS,Email），取值范围见{{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @param {Function} successCallback 成功回调函数
 * @param {Message} successCallback.message 生成的信息对象，参见 {{#crossLink "xFace.Message"}}{{/crossLink}}
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Messaging.prototype.createMessage = function(messageType, successCallback, errorCallback) {
    argscheck.checkArgs('sfF', 'xFace.Messaging.createMessage', arguments);
    //TODO:根据messageType创建不同类型的信息，目前只处理了短消息
    var MessageTypes = require('xFace/extension/MessageTypes');
    if((messageType != MessageTypes.EmailMessage&&
       messageType != MessageTypes.MMSMessage&&
       messageType != MessageTypes.SMSMessage)){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    var result = new Message();
    result.messageType = messageType;
    successCallback(result);
};

/**
 * 发送信息，目前支持发送短信和Email（Android, iOS, WP8）<br/>
 * @example
        xFace.Messaging.sendMessage (message, success, errorCallback);
        function success(statusCode) {alert("success : " + statusCode);}
        function errorCallback(errorCode){alert("fail : " + errorCode);

 * @method sendMessage
 * @param {Message} message 要发送的信息对象，参见{{#crossLink "xFace.Message"}}{{/crossLink}}
 * @param {Function} [successCallback] 成功回调函数
 * @param {Number} successCallback.code   状态码: 0：发送成功；
 * @param {Function} [errorCallback]   失败回调函数
 * @param {Number} errorCallback.code   状态码: 1：通用错误；2：无服务；3：没有PDU提供；4：天线关闭；
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Messaging.prototype.sendMessage = function(message, successCallback, errorCallback){
    argscheck.checkArgs('oFF', 'xFace.Messaging.sendMessage', arguments);
    exec(successCallback, errorCallback, null, "Messaging", "sendMessage", [message.messageType, message.destinationAddresses, message.body, message.subject]);
};

module.exports = new Messaging();
