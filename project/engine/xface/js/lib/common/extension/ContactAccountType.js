
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
 * 该类定义一些常量，用于标识联系人项的帐号类型，在定义ContactFindOptions对象时会使用（Android）<br/>
 * 相关参考： {{#crossLink "Contacts"}}{{/crossLink}}，{{#crossLink "ContactFindOptions"}}{{/crossLink}}
 * @class ContactAccountType
 * @example
        var options = new ContactFindOptions();
        options.filter = "Jim";
        options.multiple = true;
        options.accountType = ContactAccountType.SIM;

 * @static
 * @platform Android
 * @since 3.0.0
 */
var ContactAccountType = function() {
};

/**
 * 所有的联系人，包括手机和sim卡等上的联系人（Android）
 * @property All
 * @type String
 * @final
 * @platform Android
 * @since 3.0.0
 */
ContactAccountType.All = "All";
/**
 * 手机自身的联系人信息（Android）
 * @property Phone
 * @type String
 * @final
 * @platform Android
 * @since 3.0.0
 */
ContactAccountType.Phone = "Phone";
/**
 * sim卡上的联系人信息（Android）
 * @property SIM
 * @type String
 * @final
 * @platform Android
 * @since 3.0.0
 */
ContactAccountType.SIM = "SIM";

module.exports = ContactAccountType;