
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
 * @module compass
 */

 /**
 * 用于描述获取指南针信息时产生的错误（Android, iOS, WP8）<br/>
 * @class CompassError
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var CompassError = function(err) {
    /**
      * 错误码，用于标识具体的错误类型 (Android, iOS, WP8).
      * @example
             var fail = function(error){
                console.log("getCompass fail callback with error code " + getErrorMsg(error.code));
             var getErrorMsg = function(code){
                if(code == CompassError.COMPASS_INTERNAL_ERR){
                    return "COMPASS_INTERNAL_ERR";
                } else if(code == CompassError.COMPASS_NOT_SUPPORTED){
                    return "COMPASS_NOT_SUPPORTED";
                }
                return "";
            }
      * @property code
      * @default null
      * @type Number
      * @platform Android, iOS, WP8
      * @since 3.0.0
      */
    this.code = (err !== undefined ? err : null);
};

/**
  * 设备内部错误 (Android, iOS, WP8).
  * @example
         CompassError.COMPASS_INTERNAL_ERR
  * @property COMPASS_INTERNAL_ERR
  * @type Number
  * @final
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
CompassError.COMPASS_INTERNAL_ERR = 0;

/**
  * 不支持compass (Android, iOS, WP8).
  * @example
         CompassError.COMPASS_NOT_SUPPORTED
  * @property COMPASS_NOT_SUPPORTED
  * @type Number
  * @final
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
CompassError.COMPASS_NOT_SUPPORTED = 20;

module.exports = CompassError;