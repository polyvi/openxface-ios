
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
 * @module connection
 */

/**
 * 定义网络连接类型常量 (Android, iOS, WP8).<br>
 * 相关参考： {{#crossLink "navigator.network.Connection"}}{{/crossLink}}
 * @class Connection
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
module.exports = {
        /**
        * 当前网络连接类型未知 (Android, iOS, WP8).
        * @example
              Connection.UNKNOWN
        * @property UNKNOWN
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        UNKNOWN: "unknown",
        /**
        * 当前网络连接类型为以太网 (Android, iOS, WP8).
        * @example
              Connection.ETHERNET
        * @property ETHERNET
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        ETHERNET: "ethernet",
        /**
        * 当前网络连接类型为wifi (Android, iOS, WP8).
        * @example
              Connection.WIFI
        * @property WIFI
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        WIFI: "wifi",
        /**
        * 当前网络连接类型为2g (Android, iOS, WP8).
        * @example
              Connection.CELL_2G
        * @property CELL_2G
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        CELL_2G: "2g",
        /**
        * 当前网络连接类型为3g (Android, iOS, WP8).
        * @example
              Connection.CELL_3G
        * @property CELL_3G
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        CELL_3G: "3g",
        /**
        * 当前网络连接类型为4g (Android, iOS, WP8).
        * @example
              Connection.CELL_4G
        * @property CELL_4G
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        CELL_4G: "4g",
        /**
        * 当前无网络连接 (Android, iOS, WP8).
        * @example
              Connection.NONE
        * @property NONE
        * @type String
        * @final
        * @platform Android, iOS, WP8
        * @since 3.0.0
        */
        NONE: "none"
};
