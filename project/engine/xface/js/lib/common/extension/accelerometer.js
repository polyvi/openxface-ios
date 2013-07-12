
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
 * 该模块定义与重力加速度信息相关的一些操作
 * @module accelerometer
 * @main
 */

/**
 * 该类提供基础的API,用于捕捉x,y,z三个方向的加速度（Android, iOS, WP8）<br/>
 * 该类的对象实例是唯一的，只能通过navigator.accelerometer进行引用
 * @class Accelerometer
 * @static
 * @platform Andriod,iOS,WP8
 * @since 3.0.0
 */
var argscheck = require('xFace/argscheck'),
    utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    Acceleration = require('xFace/extension/Acceleration');

// Is the accel sensor running?
var running = false;

// Keeps reference to watchAcceleration calls.
var timers = {};

// Array of listeners; used to keep track of when we should call start and stop.
var listeners = [];

// Last returned acceleration object from native
var accel = null;

// Tells native to start.

function start() {
    exec(function(a) {
        var tempListeners = listeners.slice(0);
        accel = new Acceleration(a.x, a.y, a.z, a.timestamp);
        for(var i = 0, l = tempListeners.length; i < l; i++) {
            tempListeners[i].win(accel);
        }
    }, function(e) {
        var tempListeners = listeners.slice(0);
        for(var i = 0, l = tempListeners.length; i < l; i++) {
            tempListeners[i].fail(e);
        }
    }, null, "Accelerometer", "start", []);
    running = true;
}

// Tells native to stop.

function stop() {
    exec(null, null, null, "Accelerometer", "stop", []);
    running = false;
}

// Adds a callback pair to the listeners array

function createCallbackPair(win, fail) {
    return {
        win: win,
        fail: fail
    };
}

// Removes a win/fail listener pair from the listeners array

function removeListeners(l) {
    var idx = listeners.indexOf(l);
    if(idx > -1) {
        listeners.splice(idx, 1);
        if(listeners.length === 0) {
            stop();
        }
    }
}

var accelerometer = {
    /**
     * 获取当前的重力加速度数据，重力加速度数据说明参考{{#crossLink "Acceleration"}}{{/crossLink}}(Andriod,iOS,WP8)
     * @example
            function onSuccess(Acceleration acceleration){
                // do something......
            }
            function onError(){
                // handle error......
            }
            getCurrentAcceleration(onSuccess,onError);
     * @method getCurrentAcceleration
     * @param {function} successCallback  成功回调函数
     * @param {function} [errorCallback] 失败回调函数
     * @platform Andriod,iOS,WP8
     * @since 3.0.0
     */
    getCurrentAcceleration: function(successCallback, errorCallback) {
        argscheck.checkArgs('fF', 'accelerometer.getCurrentAcceleration', arguments);
        var p;
        var win = function(a) {
                successCallback(a);
                removeListeners(p);
            };
        var fail = function(e) {
                errorCallback(e);
                removeListeners(p);
            };

        p = createCallbackPair(win, fail);
        listeners.push(p);

        if(!running) {
            start();
        }
    },
    /**
     * 监视{{#crossLink "Acceleration"}}{{/crossLink}}的变化,若未指定frequency则默认采用10s(Andriod,iOS,WP8)
     * @example
            var watchId=null;
            function onSuccess(Acceleration acceleration){
                // do something......
            }
            function onError(){
                // handle error......
            }
            options={ frequency: 3000};
            watchId=watchAcceleration()
     * @method watchAcceleration
     * @param {function} successCallback 成功回调函数
     * @param {function} [errorCallback]  失败回调函数
     * @param {Object} [options]  用于指定获取acceleration的时间间隔，此对象包含唯一的属性frequence，该属性以毫秒为单位，默认值为10000
     * @return {String} 返回唯一的watchId,与clearWatch配合使用可以取消指定的监视器
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    watchAcceleration: function(successCallback, errorCallback, options) {
        argscheck.checkArgs('fFO', 'accelerometer.watchAcceleration', arguments);
        // Default interval (10 sec)
        var frequency = (options && options.frequency && typeof options.frequency == 'number') ? options.frequency : 10000;

        // successCallback required
        if(typeof successCallback !== "function") {
            throw "watchAcceleration must be called with at least a success callback function as first parameter.";
        }

        // Keep reference to watch id, and report accel readings as often as defined in frequency
        var id = utils.createUUID();

        var p = createCallbackPair(function() {}, function(e) {
            errorCallback(e);
            removeListeners(p);
        });
        listeners.push(p);

        timers[id] = {
            timer: window.setInterval(function() {
                if(accel) {
                    successCallback(accel);
                }
            }, frequency),
            listeners: p
        };

        if(running) {
            // If we're already running then immediately invoke the success callback
            successCallback(accel);
        } else {
            start();
        }

        return id;
    },

    /**
     * 取消指定的监视器(Andriod,iOS,WP8)
     * @example
            var watchId=null;
            function onSuccess(Acceleration acceleration){
                // do something......
            }
            function onError(){
                // handle error......
            }
            options={frequency: 3000};
            watchId=watchAcceleration(onSuccess,onError,options)
            if (watchId) {
                navigator.accelerometer.clearWatch(watchId);
                watchId = null;
            }
     * @method clearWatch
     * @param {String} id  由watchAcceleration返回的watchId
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    clearWatch: function(id) {
        // Stop javascript timer & remove from timer list
        if(id && timers[id]) {
            window.clearInterval(timers[id].timer);
            removeListeners(timers[id].listeners);
            delete timers[id];
        }
    }
};

module.exports = accelerometer;