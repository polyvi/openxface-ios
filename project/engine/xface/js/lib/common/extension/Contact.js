
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
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    ContactError = require('xFace/extension/ContactError'),
    utils = require('xFace/utils');

/**
 * 将原始数据转换为复杂对象.
 * 当前仅应用于 Data 域
 * @param  contact  需要进行转换的 contact 信息
 */
function convertIn(contact) {
    var value = contact.birthday;
    try {
      contact.birthday = new Date(parseFloat(value));
    } catch (exception){
      console.log("xFace Contact convertIn error: exception creating date.");
    }
    return contact;
}

/**
 * 将复杂对象转换为原始数据，与 convertIn 对应
 * 当前仅应用于 Data 域
 * @param  contact  需要进行转换的 contact 信息
 */
function convertOut(contact) {
    var value = contact.birthday;
    if (value !== null) {
        // 如果 birthday 还不是一个 Data 对象，则将其生成
        if (!(value instanceof Date)){
            try {
                value = new Date(value);
            } catch(exception){
                value = null;
            }
        }

        if (value instanceof Date){
            value = value.valueOf(); // 转换为 milliseconds
        }

        contact.birthday = value;
    }
    return contact;
}

/**
 * 该类定义了单个联系人的一系列属性及方法（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "ContactField"}}{{/crossLink}},{{#crossLink "ContactAddress"}}{{/crossLink}},{{#crossLink "ContactName"}}{{/crossLink}},{{#crossLink "ContactOrganization"}}{{/crossLink}}
 * @class Contact
 * @constructor
 * @param {String} [id=null] 唯一标识符，仅在 Native端设置
 * @param {String} [displayName=null] 联系人显示名称
 * @param {ContactName} [name=null] 联系人全名
 * @param {String} [nickname=null] 昵称
 * @param {ContactField[]} [phoneNumbers=null] 电话号码
 * @param {ContactField[]} [emails=null] email地址
 * @param {ContactAddress[]} [addresses=null] 联系地址
 * @param {ContactField[]} [ims=null] 即时通讯id号
 * @param {ContactOrganization[]} [organizations=null] 所属组织
 * @param {String} [birthday=null] 生日
 * @param {String} [note=null] 用户对此联系人的备注
 * @param {ContactField[]} [photos=null] 照片
 * @param {ContactField[]} [categories=null]  用户自定义类别
 * @param {ContactField[]} [urls=null] 联系人的网站
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var Contact = function (id, displayName, name, nickname, phoneNumbers, emails, addresses,
    ims, organizations, birthday, note, photos, categories, urls) {
    /**
     * 唯一标识符
     */
    this.id = id || null;

    this.rawId = null;
    /**
     * 联系人显示名称，适合向最终用户展示的联系人名称（Android, iOS, WP8）
     * @property displayName
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.displayName = displayName || null;
    /**
     * 联系人全名（Android, iOS, WP8）
     * @property name
     * @type ContactName
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.name = name || null; // ContactName
    /**
     * 昵称（Android, iOS, WP8）
     * @property nickname
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.nickname = nickname || null;
    /**
     * 电话号码（Android, iOS, WP8）
     * @property phoneNumbers
     * @type ContactField[]
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.phoneNumbers = phoneNumbers || null; // ContactField[]
    /**
     * email地址（Android, iOS, WP8）
     * @property emails
     * @type ContactField[]
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.emails = emails || null; // ContactField[]
    /**
     * 联系地址（Android, iOS, WP8）
     * @property addresses
     * @type ContactAddress[]
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.addresses = addresses || null; // ContactAddress[]
    /**
     * IM地址（Android, iOS）
     * @property ims
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.ims = ims || null; // ContactField[]
    /**
     * 所有所属组织（Android, iOS）
     * @property organizations
     * @type ContactOrganization[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.organizations = organizations || null; // ContactOrganization[]
    /**
     * 生日（Android, iOS）
     * @property birthday
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.birthday = birthday || null;
    /**
     * 用户对此联系人的备注（Android, iOS）
     * @property note
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.note = note || null;
    /**
     * 照片（Android, iOS, WP8）
     * @property photos
     * @type ContactField[]
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.photos = photos || null; // ContactField[]
    /**
     * 用户自定义类别（Android, iOS）
     * @property categories
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.categories = categories || null; // ContactField[]
    /**
     * 相关网页（Android, iOS, WP8）
     * @property urls
     * @type ContactField[]
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.urls = urls || null; // ContactField[]
};

/**
 * 从设备存储中清除联系人（Android, iOS）<br/>
 * @example
        function onSuccess() {
            alert("Removal Success");   };

        function onError(contactError) {
            alert("Error = " + contactError.code);   };

        // remove the contact from the device
        contact.remove(onSuccess,onError);

 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @param {ContactError} errorCallback.error   错误码
 * @platform Android, iOS
 * @since 3.0.0
 */
Contact.prototype.remove = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'Contact.remove', arguments);
    
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new ContactError(code));
    };

    if (this.id === null) {
        fail(ContactError.UNKNOWN_ERROR);
    }
    else {
        exec(successCallback, fail, null, "Contacts", "remove", [this.id]);
    }
};

/**
 * 创建一个联系人的深拷贝.域中的 Id 均设置为 null.（Android, iOS）<br/>
 * @example
        var contact = navigator.contacts.create();
        var name = new ContactName();
        name.givenName = "Jane";
        name.familyName = "Doe";
        contact.name = name;

        var clone = contact.clone();
        clone.name.givenName = "John";
        console.log("Original contact name = " + contact.name.givenName);
        console.log("Cloned contact name = " + clone.name.givenName);

 * @method clone
 * @return {Contact}  拷贝成功后的一个新的Contact对象.
 * @platform Android, iOS
 * @since 3.0.0
 */
Contact.prototype.clone = function() {
    var clonedContact = utils.clone(this);
    var i;
    clonedContact.id = null;
    clonedContact.rawId = null;
    // 遍历并清空所有域中的 id
    if (clonedContact.phoneNumbers) {
        for (i = 0; i < clonedContact.phoneNumbers.length; i++) {
            clonedContact.phoneNumbers[i].id = null;
        }
    }
    if (clonedContact.emails) {
        for (i = 0; i < clonedContact.emails.length; i++) {
            clonedContact.emails[i].id = null;
        }
    }
    if (clonedContact.addresses) {
        for (i = 0; i < clonedContact.addresses.length; i++) {
            clonedContact.addresses[i].id = null;
        }
    }
    if (clonedContact.ims) {
        for (i = 0; i < clonedContact.ims.length; i++) {
            clonedContact.ims[i].id = null;
        }
    }
    if (clonedContact.organizations) {
        for (i = 0; i < clonedContact.organizations.length; i++) {
            clonedContact.organizations[i].id = null;
        }
    }
    if (clonedContact.categories) {
        for (i = 0; i < clonedContact.categories.length; i++) {
            clonedContact.categories[i].id = null;
        }
    }
    if (clonedContact.photos) {
        for (i = 0; i < clonedContact.photos.length; i++) {
            clonedContact.photos[i].id = null;
        }
    }
    if (clonedContact.urls) {
        for (i = 0; i < clonedContact.urls.length; i++) {
            clonedContact.urls[i].id = null;
        }
    }
    return clonedContact;
};

/**
 * 保存联系人信息到设备存储中（Android, iOS, WP8）<br/>
 * @example
        function onSuccess(contact) {
            alert("Save Success");   };

        function onError(contactError) {
            alert("Error = " + contactError.code);   };

        // create a new contact object
        var contact = navigator.contacts.create();
        contact.displayName = "Plumber";
        contact.nickname = "Plumber";

        // populate some fields
        var name = new ContactName();
        name.givenName = "Jane";
        name.familyName = "Doe";
        contact.name = name;

        // save to device
        contact.save(onSuccess,onError);

 * @method save
 * @param {Function} [successCallback] 成功回调函数
 * @param {Contact} successCallback.contact 保存成功的Contact对象
 * @param {Function} [errorCallback]   失败回调函数
 * @param {ContactError} errorCallback.error   错误码
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Contact.prototype.save = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'Contact.save', arguments);
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new ContactError(code));
    };

    var success = function(result) {
      if (result) {
          if (typeof successCallback === 'function') {
              var fullContact = require('xFace/extension/contacts').create(result);
              successCallback(convertIn(fullContact));
          }
      }
      else {
          fail(ContactError.UNKNOWN_ERROR);
      }
  };
    var dupContact = convertOut(utils.clone(this));
    exec(success, fail, null, "Contacts", "save", [dupContact]);
};

module.exports = Contact;