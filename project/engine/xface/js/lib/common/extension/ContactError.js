
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
 * 该类用于表示通讯录操作出现的具体的错误（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Contacts"}}{{/crossLink}}
 * @class ContactError
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

var ContactError = function(err) {
    /**
     * 错误代码，其取值范围参考ContactError中定义的常量（Android, iOS, WP8）
     * @property code
     * @type Number
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.code = (typeof err != 'undefined' ? err : null);
};

/**
 * 未知错误（Android, iOS, WP8）
 * @property UNKNOWN_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.UNKNOWN_ERROR = 0;
/**
 * 无效参数错误（Android, iOS, WP8）
 * @property INVALID_ARGUMENT_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.INVALID_ARGUMENT_ERROR = 1;
/**
 * 请求超时错误（Android, iOS, WP8）
 * @property TIMEOUT_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.TIMEOUT_ERROR = 2;
/**
 * 挂起操作错误（Android, iOS, WP8）
 * @property PENDING_OPERATION_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.PENDING_OPERATION_ERROR = 3;
/**
 * 输入输出错误（Android, iOS, WP8）
 * @property IO_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.IO_ERROR = 4;
/**
 * 平台不支持错误（Android, iOS, WP8）
 * @property NOT_SUPPORTED_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.NOT_SUPPORTED_ERROR = 5;
/**
 * 权限被拒绝错误（Android, iOS, WP8）
 * @property PERMISSION_DENIED_ERROR
 * @type Number
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ContactError.PERMISSION_DENIED_ERROR = 20;

module.exports = ContactError;