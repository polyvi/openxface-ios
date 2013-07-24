
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
 * 用于描述获取的指南针信息（Android, iOS, WP8）<br/>
 * 由于磁场北极和地理北极有差别，就产生了磁差，地面和地图上是以真正的北极南极为基准的，而真航向指的是从地理北极顺时针转到当前位置的夹角，
 * 磁航向指的是从磁场北极顺时针转到当前位置的夹角，磁差就是真航向和磁航向之间的偏差<br/>
 * 在IOS系统版本高于4.0的设备上，如果设备旋转且应用支持该方向，则将返回相对于该方向的指南针朝向值
 * @class CompassHeading
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var CompassHeading = function(magneticHeading, trueHeading, headingAccuracy, timestamp) {
  /**
   * 指南针的磁航向信息（从磁场北极顺时针转的夹角），单位度，取值范围0~359.99度(Android, iOS, WP8)
   * @example
          var success = function(heading){
              console.log("The heading in degree is: " + heading.magneticHeading);
          };
   * @property magneticHeading
   * @default null
   * @type Number
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  this.magneticHeading = (magneticHeading !== undefined ? magneticHeading : null);
  /**
   * 指南针的真航向信息（从地理北极顺时针转的夹角），单位度，取值范围0~359.99度，如为负值则表明该参数不确定 (iOS, WP8)<br/>
   * 在iOS下，仅在位置定位服务开启的情况下才有效
   * @example
          var success = function(heading){
              console.log("The heading relative to the geographic North Pole is: " + heading.magneticHeading);
          };
   * @property trueHeading
   * @default null
   * @type Number
   * @platform iOS, WP8
   * @since 3.0.0
   */
  this.trueHeading = (trueHeading !== undefined ? trueHeading : null);
  /**
   * 真航向和磁航向之间的偏差，单位度，取值范围是0-359.99度(Android, iOS, WP8)<br/>
   * 在Android下，headingAccuracy的值始终为0
   * @example
          var success = function(heading){
             console.log("The deviation in degrees between the reported heading and the true heading is: "
                    + heading.headingAccuracy);
          };
   * @property headingAccuracy
   * @default null
   * @type Number
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  this.headingAccuracy = (headingAccuracy !== undefined ? headingAccuracy : null);
  /**
   * 获取指南针方向信息时的时间（距1970年1月1日之间的毫秒数） (Android, iOS, WP8)
   * @example
          var success = function(heading){
              console.log("The time at which this heading was determined is: "
                    + heading.timestamp);
          };
   * @property timestamp
   * @default 1970年1月1日至今的毫秒数
   * @type Number
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  this.timestamp = (timestamp !== undefined ? timestamp : new Date().getTime());
};

module.exports = CompassHeading;