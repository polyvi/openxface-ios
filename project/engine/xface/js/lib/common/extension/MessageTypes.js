
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
 * @module message
 */
/**
 * 该类定义一些常量，用于标识信息的类型（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Messaging"}}{{/crossLink}}
 * @class MessageTypes
 * @namespace xFace
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

var MessageTypes = function() {
};

/**
 * 邮件（Android, iOS, WP8）
 * @property EmailMessage
 * @type String
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MessageTypes.EmailMessage = "Email";
/**
 * 彩信（Android, iOS, WP8）
 * @property MMSMessage
 * @type String
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MessageTypes.MMSMessage = "MMS";
/**
 * 短信（Android, iOS, WP8）
 * @property SMSMessage
 * @type String
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
MessageTypes.SMSMessage = "SMS";

module.exports = MessageTypes;
