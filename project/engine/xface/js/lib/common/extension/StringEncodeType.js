
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
 * @module StringEncodeType
 */

/**
 * 该类定义一些常量，用于标识String的编码格式（Android, iOS）<br/>
 * 该类的用法参考{{#crossLink "Security"}}{{/crossLink}}
 * @class StringEncodeType
 * @platform Android, iOS
 * @since 3.0.0
 */
function StringEncodeType() {
}

/**
* String为普通的string编码
* @property STRING
* @type Number
* @final
* @platform Android
* @since 3.0.0
*/
StringEncodeType.STRING = 0;
/**
* String为Base64编码
* @property Base64
* @type Number
* @final
* @platform Android
* @since 3.0.0
*/
StringEncodeType.Base64 = 1;
/**
* String为16进制格式编码
* @property HEX
* @type Number
* @final
* @platform Android
* @since 3.0.0
*/
StringEncodeType.HEX = 2

module.exports = StringEncodeType;