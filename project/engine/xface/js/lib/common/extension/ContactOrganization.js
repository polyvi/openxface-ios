
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
 * 该类定义了联系人的所属组织属性,Contact对象通过一个数组存储一个或多个ContactOrganization对象（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @class ContactOrganization
 * @constructor
 * @param {Boolean} [pref=false] 首选项
 * @param {String} [type=null] 机构类型
 * @param {String} [name=null] 机构名称
 * @param {String} [dept=null] 部门名称
 * @param {String} [title=null] 职位名称
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var ContactOrganization = function(pref, type, name, dept, title) {
    /**
     * 唯一标识符
     */
    this.id = null;
    /**
     * 首选项
     */
    this.pref = (typeof pref != 'undefined' ? pref : false);
    /**
     * 机构类型（Android, iOS, WP8）
     * @property type
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.type = type || null;
    /**
     * 机构名称（Android, iOS, WP8）
     * @property name
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.name = name || null;
    /**
     * 部门名称（Android, iOS, WP8）
     * @property department
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.department = dept || null;
    /**
     * 职位名称（Android, iOS, WP8）
     * @property title
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.title = title || null;
};

module.exports = ContactOrganization;