
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
 * 该模块定义拨打电话和操作通话记录相关的功能
 * @module telephony
 * @main telephony
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 提供拨打电话和操作通话记录相关的功能（Android, iOS, WP8）<br/>
 * 该类不能通过new来创建相应的对象，只能通过xFace.Telephony对象来直接使用该类中定义的方法
 * @class Telephony
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var Telephony = function(){
};

/**
 * 拨打电话 (Android, iOS, WP8)
 * @example
        function call() {
            xFace.Telephony.initiateVoiceCall("114",callSuccess, callFail);
        }
        function success() {
            alert("success");
        }
        function fail() {
            alert("fail to scanner barcode" );
        }
 * @method initiateVoiceCall
 * @param {String} phoneNumber 电话号码
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Telephony.prototype.initiateVoiceCall = function(phoneNumber,successCallback,errorCallback){
    argscheck.checkArgs('sFF', 'xFace.Telephony.initiateVoiceCall', arguments);
    exec(successCallback, errorCallback, null, "Telephony", "initiateVoiceCall", [phoneNumber]);
};
module.exports = new Telephony();
