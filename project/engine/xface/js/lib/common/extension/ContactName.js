
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
 * 该类定义了联系人姓名的一系列子属性（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @class ContactName
 * @constructor
 * @param {String} [formatted=null] 联系人的全名
 * @param {String} [familyName=null] 联系人的姓氏
 * @param {String} [givenName=null] 联系人的名字
 * @param {String} [middle=null] 联系人的中间名
 * @param {String} [prefix=null] 尊称的前缀，比如 “尊敬的”、“敬爱的”等
 * @param {String} [suffix=null] 尊称的后缀，比如 “先生”、“女士”等
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var ContactName = function(formatted, familyName, givenName, middle, prefix, suffix) {
    /**
     * 联系人的全名（Android, iOS, WP8）
     * @property formatted
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.formatted = formatted || null;
    /**
     * 联系人的姓氏（Android, iOS, WP8）
     * @property familyName
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.familyName = familyName || null;
    /**
     * 联系人的名字（Android, iOS, WP8）
     * @property givenName
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.givenName = givenName || null;
    /**
     * 联系人的中间名（Android, iOS, WP8）
     * @property middleName
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.middleName = middle || null;
    /**
     * 尊称的前缀，比如 “尊敬的”、“敬爱的”等（Android, iOS, WP8）
     * @property honorificPrefix
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.honorificPrefix = prefix || null;
    /**
     * 尊称的后缀，比如 “先生”、“女士”等（Android, iOS, WP8）
     * @property honorificSuffix
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.honorificSuffix = suffix || null;
};

module.exports = ContactName;