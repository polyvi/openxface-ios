
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
 * 用于封装监视指南针时的一些参数信息（Android, iOS）<br/>
 * @class CompassOptions
 * @platform Android, iOS
 * @since 3.0.0
 */

 /**
 * 初始化对象中的属性（Android, iOS）<br/>
 * @constructor
 * @param {Number} frequency 用户设置的用于监视指南针方向信息的时间间隔(Android, iOS)
 * @param {Number} filter 用户设置的阈值(iOS)
 * @platform Android, iOS
 * @since 3.0.0
 */
var CompassOptions = function(frequency,filter) {
    /**
     * 监视指南针方向信息的时间间隔，其默认值为100msec （以毫秒为单位）(Android, iOS)
     * @example
            var options = new CompassOptions(200,0);
            var frequency = options.frequency;
     * @property frequency
     * @type Number
     * @default 100
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.frequency = (frequency !== undefined ? frequency : 100);
    /**
     * 用于指定一个阈值，在监视指南针信息的过程中，只有当方向信息数据变化大于等于该阈值时，方向信息数据才会通过回调更新(iOS)
     * @example
            var options = new CompassOptions(200,0);
            var filter = options.filter;
     * @property filter
     * @default null
     * @type Number
     * @platform iOS
     * @since 3.0.0
     */
    this.filter = (filter !== undefined ? filter : null);
};

module.exports = CompassOptions;