
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

var exec = require('xFace/exec'),
    argscheck = require('xFace/argscheck'),
    ContactError = require('xFace/extension/ContactError'),
    Contact = require('xFace/extension/Contact');
/**
 * 该模块提供对设备通讯录数据库的访问.
 * @module contacts
 * @main contacts
 */

/**
 * 该类定义了设备通讯录数据库的访问相关接口（Android, iOS, WP8）<br/>
 * 该类不能通过new来创建相应的对象，只能通过navigator.contacts对象来直接使用该类中定义的方法<br/>
 * 相关参考： {{#crossLink "ContactError"}}{{/crossLink}}，{{#crossLink "Contact"}}{{/crossLink}},{{#crossLink "ContactField"}}{{/crossLink}},{{#crossLink "ContactFindOptions"}}{{/crossLink}}
 * @class Contacts
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

var contacts = {
    /**
     * 查询设备通讯录（Android, iOS, WP8）<br/>
     * @example
            function onSuccess(contacts) {
                alert('Found ' + contacts.length + ' contacts.'); };

            function onError(contactError) {
                alert('onError!')+ contactError.code;  };

            // find all contacts with 'Bob' in any name field
            var options = new ContactFindOptions();
            options.filter="Bob";
            options.multiple=true;
            var fields = ["displayName", "name"];
            navigator.contacts.find(fields, onSuccess, onError, options);

     * @method find
     * @param {String[]} fields 需要查询的域。在返回的Contact对象中只有这些字段有值，支持的项参见 {{#crossLink "Contact"}}{{/crossLink}}的属性
     * @param {Function} successCallback 成功回调函数
     * @param {Contact[]} successCallback.contacts 满足查询条件的Contact对象数组
     * @param {Function} [errorCallback]   失败回调函数
     * @param {ContactError} errorCallback.error   错误码
     * @param {ContactFindOptions} [options] 过滤通讯录的搜索选项
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    find:function(fields, successCallback, errorCallback, options) {
        argscheck.checkArgs('afFO', 'contacts.find', arguments);
        if (!fields.length) {
            if (typeof errorCallback === "function") {
                errorCallback(new ContactError(ContactError.INVALID_ARGUMENT_ERROR));
            }
        } else {
            var win = function(result) {
                var cs = [];
                for (var i = 0, l = result.length; i < l; i++) {
                    cs.push(contacts.create(result[i]));
                }
                successCallback(cs);
            };
            var fail = function(errorCode) {
                errorCallback(new ContactError(errorCode));
            };
            exec(win, fail, null, "Contacts", "search", [fields, options]);
        }
    },


    /**
     * 创建一个新的联系人，但此函数不将其保存在设备存储上（Android, iOS, WP8）<br/>
     * 要持久保存在设备存储上，可调用Contact.save()。
     * @example
            var myContact = navigator.contacts.create({"displayName": "Test User"});

     * @method create
     * @param {Object} [properties] 创建新对象所包含的属性，支持的属性项参见 {{#crossLink "Contact"}}{{/crossLink}}的属性
     * @return {Contact} 包含了指定的properties的一个新Contact对象，如果未指定properties，则该Contact对象中所有属性均为null.
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    create:function(properties) {
        argscheck.checkArgs('O', 'contacts.create', arguments);
        var contact = new Contact();
        for (var i in properties) {
            if (typeof contact[i] !== 'undefined' && properties.hasOwnProperty(i)) {
                contact[i] = properties[i];
            }
        }
        return contact;
    },

     /**
     * 启动系统ui界面选择需要的联系人，并可以根据options参数来决定是否可以修改选择的记录（Android, iOS）<br/>
     * @example
            navigator.contacts.chooseContact(onSuccess,{allowsEditing:"true",fields:["name", "phoneNumbers", "emails"]});
            function onSuccess(id, results) {
                var name = "name:";
                var phone = "phoneNumbers:";
                var email = "email:";
                if(null != results.name) {
                    name +=  results.name.formatted + "\n";
                }
                if(null != results.phoneNumbers) {
                    for(var i = 0; i < results.phoneNumbers.length; i++) {
                        phone +=  results.phoneNumbers[i].value + "\n";
                    }
                }
                if(null != results.emails) {
                    for(var i = 0; i < results.emails.length; i++) {
                        email +=  results.emails[i].value + "\n";
                    }
                }
                console.log("success:" + name + phone + email);
            }
     * @method chooseContact
     * @for Contacts
     * @param {Function} [successCallback]   成功回调函数
     * @param {String} successCallback.contactId 选择的联系人的contactId
     * @param {Object} successCallback.contact   返回的{{#crossLink "Contact"}}{{/crossLink}}对象
     * @param {object} [options] 可选参数，用于控制要显示的信息
     * @param {Boolean} [options.allowsEditing=false]  表示是否可以修改显示的联系人(Android忽略该参数)
     * @param {Object}  [options.contact="*"]   表示要返回的属性，形如：fields:["name", "phoneNumbers", "emails"]，支持的属性项参见 {{#crossLink "Contact"}}{{/crossLink}}
     * @platform Android, iOS
     * @since 3.0.0
     */
    chooseContact : function(successCallback, options) {
        argscheck.checkArgs('fO', 'contacts.chooseContact', arguments);
        var win = function(result) {
            var fullContact = require('xFace/extension/contacts').create(result);
            successCallback(fullContact.id, fullContact);
        };
        exec(win, null, null, "Contacts","chooseContact", [options]);
    }
};

module.exports = contacts;
