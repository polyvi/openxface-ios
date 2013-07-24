
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

var xFace = require('xFace') ,
    exec = require('xFace/exec');

function handlers() {
  return battery.channels.batterystatus.numHandlers +
         battery.channels.batterylow.numHandlers +
         battery.channels.batterycritical.numHandlers;
}

/**
 * @module event
 */
var Battery = function() {
    this._level = null;
    this._isPlugged = null;
    // Create new event handlers on the window (returns a channel instance)
    this.channels = {
      /**
       * 当xFace应用监测到电池电量改变了至少1%的时候或者充电器插拔的时候会触发该事件（Android, iOS, WP8）<br/>
       * @example
              function onBatteryStatus(info) {
                 alert("battery level is " + info.level + "% isPlugged : " + info.isPlugged);
              }
              window.addEventListener("batterystatus", onBatteryStatus, false);
       * @event batterystatus
       * @for BaseEvent
       * @param {Object} info 电池电量信息
       * @param {Number} info.level 电池电量的百分比（0~100）
       * @param {Boolean} info.isPlugged 手机是否在充电
       * @platform Android, iOS, WP8
       * @since 3.0.0
       */
      batterystatus:xFace.addWindowEventHandler("batterystatus"),
      /**
       * 当xFace应用监测到手机的电池达到低电量值(20%)的时候会触发该事件（Android, iOS, WP8）<br/>
       * @example
              function onBatteryLow(info) {
                  alert("battery low level is " + info.level + "%");
              }
              window.addEventListener("batterylow", onBatteryLow, false);
        * @event batterylow
        * @for BaseEvent
        * @param {Object} info 电池电量信息
        * @param {Number} info.level 电池电量的百分比（0~100）
        * @param {Boolean} info.isPlugged 手机是否在充电
        * @platform Android, iOS, WP8
        * @since 3.0.0
       */
      batterylow:xFace.addWindowEventHandler("batterylow"),
      /**
       * 当xFace应用监测到手机的电池达到临界值(5%)的时候会触发该事件（Android, iOS, WP8）<br/>
       * @example
              function onBatteryCritical(info) {
                  alert("battery level is " + info.level + "%，please recharge soon!");
              }
              window.addEventListener("batterycritical", onBatteryCritical, false);
       * @event batterycritical
       * @for BaseEvent
       * @param {Object} info 电池电量信息
       * @param {Number} info.level 电池电量的百分比（0~100）
       * @param {Boolean} info.isPlugged 手机是否在充电
       * @platform Android, iOS, WP8
       * @since 3.0.0
       */
      batterycritical:xFace.addWindowEventHandler("batterycritical")
    };
    for (var key in this.channels) {
        this.channels[key].onHasSubscribersChange = Battery.onHasSubscribersChange;
    }
};
/**
 * Event handlers for when callbacks get registered for the battery.
 * Keep track of how many handlers we have so we can start and stop the native battery listener
 * appropriately (and hopefully save on battery life!).
 */
Battery.onHasSubscribersChange = function() {
  // If we just registered the first handler, make sure native listener is started.
  if (this.numHandlers === 1 && handlers() === 1) {
      exec(battery._status, battery._error, null, "Battery", "start", []);
  } else if (handlers() === 0) {
      exec(null, null, null, "Battery", "stop", []);
  }
};

/**
 * 电池状态成功回调函数
 *
 * @param {Object} info         keys: level, isPlugged
 */
Battery.prototype._status = function(info) {
    if (info) {
        var me = battery;
        var level = info.level;
        if (me._level !== level || me._isPlugged !== info.isPlugged) {
            // Fire batterystatus event
            xFace.fireWindowEvent("batterystatus", info);

            // Fire low battery event
            if (level === 20 || level === 5) {
                if (level === 20) {
                    xFace.fireWindowEvent("batterylow", info);
                }
                else {
                    xFace.fireWindowEvent("batterycritical", info);
                }
            }
        }
        me._level = level;
        me._isPlugged = info.isPlugged;
    }
};

/**
 * 电池状态的错误回调函数
 */
Battery.prototype._error = function(e) {
    console.log("Error initializing Battery: " + e);
};

var battery = new Battery();

module.exports = battery;
