
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
 * 该模块获取指南针的方向信息
 * @module compass
 * @main compass
 */

var argscheck = require('xFace/argscheck'),
exec = require('xFace/exec'),
utils = require('xFace/utils'),
CompassHeading = require('xFace/extension/CompassHeading'),
CompassError = require('xFace/extension/CompassError'),
CompassOptions = require('xFace/extension/CompassOptions'),
timers = {},
/**
 * 该类用于获取指南针的方向信息（Android, iOS, WP8）<br/>
 * 只能通过navigator.compass对象来使用该类中定义的方法
 * @class Compass
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

compass = {
    /**
     * 获取指南针当前的方向信息，指南针可以测量的角度为0到359.99（Android, iOS, WP8）<br/>
     * @example
            var getCompass = function() {
                var success = function(heading){
                    console.log("compassHeading success: " + heading.magneticHeading);
                };
                var fail = function(error){
                    console.log("getCompass fail callback with error code " + getErrorMsg(error.code));
                };
                var opt = {};
                navigator.compass.getCurrentHeading(success, fail, opt);
            };
            var getErrorMsg = function(code){
                if(code == CompassError.COMPASS_INTERNAL_ERR){
                    return "COMPASS_INTERNAL_ERR";
                } else if(code == CompassError.COMPASS_NOT_SUPPORTED){
                    return "COMPASS_NOT_SUPPORTED";
                }
                return "";
            }
     * @method getCurrentHeading
     * @param {Function} successCallback 成功回调函数
     * @param {CompassHeading} successCallback.heading 返回指南针当前的方向信息，具体请参考{{#crossLink "CompassHeading"}}{{/crossLink}}
     * @param {Function} [errorCallback] 失败回调函数
     * @param {CompassError} errorCallback.error 返回错误信息，具体请参考{{#crossLink "CompassError"}}{{/crossLink}}
     * @param {CompassOptions} [options] 用于监视指南针的选项(未使用)，具体请参考{{#crossLink "CompassOptions"}}{{/crossLink}}
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    getCurrentHeading:function(successCallback, errorCallback, options) {
        argscheck.checkArgs('fFO', 'compass.getCurrentHeading', arguments);
        var win = function(result) {
            var ch = new CompassHeading(result.magneticHeading, result.trueHeading, result.headingAccuracy, result.timestamp);
            successCallback(ch);
        };
        var fail = function(code) {
            var ce = new CompassError(code);
            errorCallback(ce);
        };
        // Get heading
        exec(win, fail, null, "Compass", "getHeading", [options]);
    },
    /**
     * 监视指南针，根据指定的间隔时间循环获取指南针的方向信息，指南针可以测量的角度为0到359.99（Android, iOS, WP8）<br/>
     * @method watchHeading
     * @example
            var watchCompass = function() {
                var success = function(heading){
                    console.log("compassHeading success: " + heading.magneticHeading);
                };
                var fail = function(error){
                    console.log("watchCompass fail callback with error code " + getErrorMsg(error.code));
                };
                var opt = {};
                opt.frequency = 1000;
                navigator.compass.watchHeading(success, fail, opt);
            };
            var getErrorMsg = function(code){
                if(code == CompassError.COMPASS_INTERNAL_ERR){
                    return "COMPASS_INTERNAL_ERR";
                } else if(code == CompassError.COMPASS_NOT_SUPPORTED){
                    return "COMPASS_NOT_SUPPORTED";
                }
                return "";
            }
     * @param {Function} successCallback 成功回调函数
     * @param {CompassHeading} successCallback.heading 返回指南针当前的方向信息，具体请参考{{#crossLink "CompassHeading"}}{{/crossLink}}
     * @param {Function} [errorCallback] 失败回调函数
     * @param {CompassError} errorCallback.error 返回错误信息，具体请参考{{#crossLink "CompassError"}}{{/crossLink}}
     * @param {CompassOptions} [options] 用于监视指南针的选项，具体请参考{{#crossLink "CompassOptions"}}{{/crossLink}}
     * @return {String} 指南针id
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    watchHeading:function(successCallback, errorCallback, options) {
        argscheck.checkArgs('fFO', 'compass.watchHeading', arguments);
        // 默认的frequency(100 msec)
        var frequency = (options !== undefined && options.frequency !== undefined) ? options.frequency : 100;
        var filter = (options !== undefined && options.filter !== undefined) ? options.filter : 0;
        var id = utils.createUUID();
        if (filter > 0) {
            // is an iOS request for watch by filter, no timer needed
            timers[id] = "iOS";
            compass.getCurrentHeading(successCallback, errorCallback, options);
        } else {
            // Start watch timer to get headings
            timers[id] = window.setInterval(function() {
                compass.getCurrentHeading(successCallback, errorCallback);
            }, frequency);
        }
        return id;
    },
    /**
     * 消除指定的指南针监视器（Android, iOS, WP8）
     * @method clearWatch
     * @example
            var watchCompassId = null;
            var stopCompass = function() {
                var success = function(heading){
                    console.log("compassHeading success: " + heading.magneticHeading);
                };
                var fail = function(error){
                    console.log("watchCompass fail callback with error code " + getErrorMsg(error.code));
                };
                var opt = {};
                opt.frequency = 1000;
                watchCompassId = navigator.compass.watchHeading(success, fail, opt);
                if (watchCompassId) {
                    navigator.compass.clearWatch(watchCompassId);
                    watchCompassId = null;
                }
            };
            var getErrorMsg = function(code){
                if(code == CompassError.COMPASS_INTERNAL_ERR){
                    return "COMPASS_INTERNAL_ERR";
                } else if(code == CompassError.COMPASS_NOT_SUPPORTED){
                    return "COMPASS_NOT_SUPPORTED";
                }
                return "";
            }
     * @param {String} id 由watchHeading返回的指南针id
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    clearWatch:function(id) {
        argscheck.checkArgs('s', 'compass.clearWatch', arguments);
        // Stop javascript timer & remove from timer list
        if (id && timers[id]) {
            if (timers[id] != "iOS") {
                clearInterval(timers[id]);
            } else {
                // is iOS watch by filter so call into device to stop
                exec(null, null, null, "Compass", "stopHeading", []);
            }
            delete timers[id];
        }
    }
};
module.exports = compass;