
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

var utils = require('xFace/utils'),
    nextGuid = 1;

/**
 * 通过此对象可以注册函数到"channel"上.
 * 此对象用于定义并触发xFace初始化过程相关的事件以及其后的自定义事件.
 *
 * 页面加载以及xFace启动过程中的事件触发顺序如下:
 *
 * onDOMContentLoaded*         内部事件，用于表明页面解析加载完成.
 * onNativeReady*              内部事件，用于表明xFace native端ready.
 * onxFaceReady*               内部事件，在xFace JavaScript对象全部创建后被触发.
 * onxFaceInfoReady*           内部事件，在设备属性可用后被触发.
 * onxFaceConnectionReady*     内部事件，在connection属性设置后被触发.
 * onDeviceReady*              用户事件，用于表明xFace已经ready.
 * onResume                    用户事件，在start/resume lifecycle event发生时被触发.
 * onPause                     用户事件，在pause lifecycle event发生时被触发.
 * onDestroy*                  内部事件，当引擎销毁时被触发(用户不应直接使用onDestroy事件，而应使用window.onunload事件).
 *
 * 被表识为 * 的事件为sticky事件.一旦这些sticky事件被触发，它们就会一直处于fired状态.
 * 在事件触发后注册的监听器将会立刻被执行.
 *
 * 只有以下xFace事件需要由用户注册:
 *      deviceready           xFace native端ready并且允许通过JavaScript调用xFace APIs
 *      pause                 引擎进入后台
 *      resume                引擎切换回前台
 *
 * 监听器注册示例:
 *      document.addEventListener("deviceready", myDeviceReadyListener, false);
 *      document.addEventListener("resume", myResumeListener, false);
 *      document.addEventListener("pause", myPauseListener, false);
 *
 * DOM lifecycle events 可用于保存/恢复状态
 *      window.onload
 *      window.onunload
 *
 */

/**
 * Channel
 * @constructor
 * @param type String  通道的名字
 * @param type Boolean 用于表识是否为sticky,true = sticky,false = non-sticky
 */
var Channel = function(type, sticky) {
    this.type = type;
    // 用于建立guid -> function的映射关系.
    this.handlers = {};
    // 0 = Non-sticky, 1 = Sticky non-fired, 2 = Sticky fired.
    this.state = sticky ? 1 : 0;
    // 用于保存传递给fire()的参数，在sticky mode下被使用.
    this.fireArgs = null;
    // 用于判定当前是否注册了监听器，用于onHasSubscribersChange函数的触发.
    this.numHandlers = 0;
    // 当第一个监听器被注册或最后一个监听器被反注册时调用的函数.
    this.onHasSubscribersChange = null;
},
    channel = {
        /**
         * 所有的通道被fire之后，才会执行提供的函数，所有的通道必须为sticky通道.
         * @param h 需要执行的函数
         * @param c 通道数组
         */
        join: function(h, c) {
            var len = c.length,
                i = len,
                f = function() {
                    if (!(--i)) h();
                };
            for (var j=0; j<len; j++) {
                if (c[j].state === 0) {
                    throw Error('Can only use join with sticky channels.');
                }
                c[j].subscribe(f);
            }
            if (!len) h();
        },
        create: function(type) {
            return channel[type] = new Channel(type, false);
        },
        createSticky: function(type) {
            return channel[type] = new Channel(type, true);
        },

        /**
         * 通道数组，所有数组中的通道在deviceready前，会被fire.
         */
        deviceReadyChannelsArray: [],
        deviceReadyChannelsMap: {},

        /**
         * 所有在使用前需要初始化的功能都需要调用该函数
         * deviceready前，所有调用该函数的功能都会被fire
         * @param{String} feature 功能名字
         */
        waitForInitialization: function(feature) {
            if (feature) {
                var c = channel[feature] || this.createSticky(feature);
                this.deviceReadyChannelsMap[feature] = c;
                this.deviceReadyChannelsArray.push(c);
            }
        },

        /**
         * feature初始化代码已经完成，表明feature提供的能够已经能够使用.
         */
        initializationComplete: function(feature) {
            var c = this.deviceReadyChannelsMap[feature];
            if (c) {
                c.fire();
            }
        }
    };

function forceFunction(f) {
    if (typeof f != 'function') throw "Function required as first argument!";
}

/**
 * 订阅一个函数
 */
Channel.prototype.subscribe = function(f, c) {
    // need a function to call
    forceFunction(f);
    if (this.state == 2) {
        f.apply(c || this, this.fireArgs);
        return;
    }

    var func = f,
        guid = f.observer_guid;
    if (typeof c == "object") { func = utils.close(c, f); }

    if (!guid) {
        // first time any channel has seen this subscriber
        guid = '' + nextGuid++;
    }
    func.observer_guid = guid;
    f.observer_guid = guid;

    // Don't add the same handler more than once.
    if (!this.handlers[guid]) {
        this.handlers[guid] = func;
        this.numHandlers++;
        if (this.numHandlers == 1) {
            if (this.onHasSubscribersChange) {
                this.onHasSubscribersChange();
            }
        }
    }
};

/**
 * 从通道中反订阅一个函数
 */
Channel.prototype.unsubscribe = function(f) {
    // need a function to unsubscribe
    forceFunction(f);

    var guid = f.observer_guid,
        handler = this.handlers[guid];
    if (handler) {
        delete this.handlers[guid];
        this.numHandlers--;
        if (this.numHandlers === 0) {
            if (this.onHasSubscribersChange) {
                this.onHasSubscribersChange();
            }
        }
    }
};

/**
 * fire 通道中的所有订阅的函数
 */
Channel.prototype.fire = function(e) {
    var fail = false,
        fireArgs = Array.prototype.slice.call(arguments);
    // Apply stickiness.
    if (this.state == 1) {
        this.state = 2;
        this.fireArgs = fireArgs;
    }
    if (this.numHandlers) {
        // Copy the values first so that it is safe to modify it from within
        // callbacks.
        var toCall = [];
        for (var item in this.handlers) {
            toCall.push(this.handlers[item]);
        }
        for (var i = 0; i < toCall.length; ++i) {
            toCall[i].apply(this, fireArgs);
        }
        if (this.state == 2 && this.numHandlers) {
            this.numHandlers = 0;
            this.handlers = {};
            if (this.onHasSubscribersChange) {
                this.onHasSubscribersChange();
            }
        }
    }
};

channel.createSticky('onDOMContentLoaded');

channel.createSticky('onNativeReady');

channel.createSticky('onxFaceReady');

channel.createSticky('onxFaceInfoReady');

channel.createSticky('onxFaceConnectionReady');

channel.createSticky('onDeviceReady');

channel.create('onResume');

channel.create('onPause');

channel.createSticky('onDestroy');

channel.waitForInitialization('onxFaceReady');
channel.waitForInitialization('onxFaceConnectionReady');

module.exports = channel;
