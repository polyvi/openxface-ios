
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
 * @module accelerometer
 */

 /**
 * 该类对象包含特定时间点采集到的加速计数据，并作为{{#crossLink "Accelerometer"}}{{/crossLink}}的参数返回(Andriod,iOS,WP8) </br>
 * @class Acceleration
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
var Acceleration = function(x, y, z, timestamp) {
/**
 * x轴方向的加速度(Andriod,iOS,WP8)
 * @property x
 * @type Number
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
  this.x = x;
/**
 * y轴方向的加速度(Andriod,iOS,WP8)
 * @property y
 * @type Number
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
  this.y = y;
/**
 * z轴方向的加速度(Andriod,iOS,WP8)
 * @property z
 * @type Number
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
  this.z = z;
/**
 * 获取加速度信息获取时的时间（距1970年1月1日之间的毫秒数）(Andriod,iOS,WP8)
 * @property timestamp
 * @type Number
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
  this.timestamp = timestamp || (new Date()).getTime();
};

module.exports = Acceleration;