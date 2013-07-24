
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
 * @module contacts
 */

 /**
 * 该类定义联系人的普通属性域，用于支持通用方式的联系人字段。（Android, iOS, WP8）<br/>
 * Contact对象的属性phoneNumbers、emails、ims、photos、categories、urls使用此类<br/>
 * 每个ContactField对象都包含一个值属性、一个类型属性和一个首选项属性信息的一系列属性.<br/>
 *  一个Contact对象将多个属性分别存储到多个ContactField[]数组中，例如电话号码与邮件地址等。<br/>
 * 在大多数情况下，ContactField对象中的type属性并没有事先确定值。例如，一个电话号码的type属性值可以是：“home”、“work”、“mobile”或其他相应特定设备平台的联系人数据库所支持的值。<br/>
 * 然而对于Contact对象的photos字段，xFace使用type字段来表示返回的图像格式。如果value属性包含的是一个指向照片图像的URL，xFace对于type会返回“url”；如果value属性包含的是图像的Base64编码字符串，xFace对于type会返回“base64”。<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @example
        // create a new contact
        var contact = navigator.contacts.create();

        // store contact phone numbers in ContactField[]
        var phoneNumbers = [];
        phoneNumbers[0] = new ContactField('work', '212-555-1234', false);
        phoneNumbers[1] = new ContactField('mobile', '917-555-5432', true); // preferred number
        phoneNumbers[2] = new ContactField('home', '203-555-7890', false);
        contact.phoneNumbers = phoneNumbers;

 * @class ContactField
 * @constructor
 * @param {String} [type=null] 字段类型
 * @param {String} [value=null] 字段的值
 * @param {Boolean} [pref=false] 首选项
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var ContactField = function(type, value, pref) {
    /**
     * 唯一标识符
     */
    this.id = null;
    /**
     * 字段类型, PhoneNumber、Email、IM、URL的type包括："home"、"mobile"、"work"、"other"、"custom" （Android, iOS, WP8）
     * @property type
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.type = (type && type.toString()) || null;
    /**
     * 字段的值（Android, iOS, WP8）
     * @property value
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.value = (value && value.toString()) || null;
    /**
     * 首选项
     */
    this.pref = (typeof pref != 'undefined' ? pref : false);
};

module.exports = ContactField;