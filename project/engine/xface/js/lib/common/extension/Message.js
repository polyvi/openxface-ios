
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
 * 该类定义了信息的一系列属性（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @class Message
 * @namespace xFace
 * @constructor
 * @param {String} [messageId=null] 唯一标识符，仅在 Native端设置
 * @param {String} [subject=null] 信息的标题
 * @param {String} [body=null] 信息的内容
 * @param {String} [destinationAddresses=null] 目的地址
 * @param {String} [messageType=null] 信息的类型（短信，彩信，Email），取值范围见{{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @param {Date} [date=null] 信息的日期
 * @param {Boolean} [isRead=null] 信息是否已读
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var Message = function(messageId, subject, body, destinationAddresses, messageType, date, isRead) {

/**
 * 唯一标识符，仅在 Native 端设置（Android, iOS, WP8）
 * @property messageId
 * @type String
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.messageId = messageId || null;
/**
 * 信息的标题（Android, iOS, WP8）
 * @property subject
 * @type String
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.subject = subject || null;
/**
 * 信息的内容（Android, iOS, WP8）
 * @property body
 * @type String
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.body = body || null;
/**
 * 目的地址（Android, iOS, WP8）
 * @property destinationAddresses
 * @type String
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.destinationAddresses = destinationAddresses || null;
/**
 * 信息的类型（短信，彩信，Email），目前支持短信和Email（Android, iOS, WP8），取值范围见 {{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @property messageType
 * @type String
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.messageType = messageType || null;
/**
 * 信息的日期（Android, iOS, WP8）
 * @property date
 * @type Date
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.date = date || null;
/**
 * 信息是否已读标志（Android, iOS, WP8）
 * @property isRead
 * @type Boolean
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
    this.isRead = isRead || null;
};

module.exports = Message;
