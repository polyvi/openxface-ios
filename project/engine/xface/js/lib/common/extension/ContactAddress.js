
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
 * 该类定义了联系人的单个地址的一系列属性。一个Contact对象可以拥有一个或多个地址，这些地址存储在一个ContactAddress[]数组中（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @class ContactAddress
 * @constructor
 * @param {Boolean} [pref=false] 首选项
 * @param {String} [type=null] 地址类型，类型包括："home"、"work"、"other"、"custom"
 * @param {String} [formatted=null] 完整的地址显示格式
 * @param {String} [streetAddress=null] 完整的街道地址
 * @param {String} [locality=null] 城市或地区
 * @param {String} [region=null] 州或省份
 * @param {String} [postalCode=null] 邮政编码
 * @param {String} [country=null] 国家
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var ContactAddress = function(pref, type, formatted, streetAddress, locality, region, postalCode, country) {
    /**
     * 唯一标识符
     */
    this.id = null;
    /**
     * 首选项
     */
    this.pref = (typeof pref != 'undefined' ? pref : false);
    /**
     * 标示该地址对应的类型,包括："work"、"home"、"other"、"custom"（Android, iOS, WP8）
     * @property type
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.type = type || null;
    /**
     * 完整的地址,综合 streetAddress、locality、region 和 country 后的全称（Android, WP8）
     * @property formatted
     * @type String
     * @platform Android, WP8
     * @since 3.0.0
     */
    this.formatted = formatted || null;
    /**
     * 完整的街道地址（Android, iOS, WP8）
     * @property streetAddress
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.streetAddress = streetAddress || null;
    /**
     * 城市或地区（Android, iOS, WP8）
     * @property locality
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.locality = locality || null;
    /**
     * 州或省份（Android, iOS, WP8）
     * @property region
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
    */
    this.region = region || null;
    /**
     * 邮政编码（Android, iOS, WP8）
     * @property postalCode
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.postalCode = postalCode || null;
    /**
     * 国家（Android, iOS, WP8）
     * @property country
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.country = country || null;
};

module.exports = ContactAddress;