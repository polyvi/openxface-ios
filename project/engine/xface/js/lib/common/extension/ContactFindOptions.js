
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
var ContactAccountType = require("xFace/extension/ContactAccountType");

 /**
 * 该类定义查询联系人时的一些选项（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Contacts"}}{{/crossLink}}，{{#crossLink "ContactAccountType"}}{{/crossLink}}
 * @class ContactFindOptions
 * @example
        // specify contact search criteria
        var options = new ContactFindOptions();
        options.filter="";          // empty search string returns all contacts
        options.multiple=true;      // return multiple results
        options.accountType = ContactAccountType.SIM;  // find in sim card
        var fields = ["displayName", "name"];      // return contact.name and displayName field

        // find contacts
        navigator.contacts.find(fields, onSuccess, onError, options);

 * @constructor
 * @param {String} [filter=''] 查找联系人的搜索字符串,持通配符"*"
 * @param {Boolean} [multiple=false] 查找操作是否可以返回多条联系人记录
 * @param {String} [accountType=ContactAccountType.All] 联系人账户类型
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var ContactFindOptions = function(filter, multiple, accountType) {
    /**
     * 查找联系人的搜索字符串，支持通配符"*"；为空时，返回所有联系人（Android, iOS, WP8）
     * @property filter
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.filter = filter || '';
    /**
     * 决定查找操作是否可以返回多条联系人记录（Android, iOS, WP8）
     * @property multiple
     * @type Boolean
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.multiple = (typeof multiple != 'undefined' ? multiple : false);
    /**
     * 联系人账户类型，取值范围见{{#crossLink "ContactAccountType"}}{{/crossLink}}（Android）
     * @property accountType
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.accountType = accountType || ContactAccountType.All;
};

module.exports = ContactFindOptions;