
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
 * @module file
 */

/**
 * 该对象提供了获取根文件系统的方法（Android, iOS, WP8）<br/>
 * @class LocalFileSystem
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var LocalFileSystem = function() {

};

/**
 * 表示用于不需要保证持久化的存储类型（Android，iOS, WP8）
 * @example
        LocalFileSystem.TEMPORARY;
 * @property TEMPORARY
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
LocalFileSystem.TEMPORARY = 0;  //临时文件

/**
 * 表示用于不经过应用程序或者用户许可，就无法通过用户代理去移除的存储类型（Android，iOS, WP8）
 * @example
        LocalFileSystem.PERSISTENT;
 * @property PERSISTENT
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
LocalFileSystem.PERSISTENT = 1; //持久文件

module.exports = LocalFileSystem;