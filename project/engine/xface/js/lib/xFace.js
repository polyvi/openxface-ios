
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
var channel = require('xFace/channel');

/**
 * Listen for DOMContentLoaded and notify our channel subscribers.
 */
document.addEventListener('DOMContentLoaded', function() {
    channel.onDOMContentLoaded.fire();
}, false);
if (document.readyState == 'complete' || document.readyState == 'interactive') {
    channel.onDOMContentLoaded.fire();
}

/**
 * Intercept calls to addEventListener + removeEventListener and handle deviceready,
 * resume, and pause events.
 */
var m_document_addEventListener = document.addEventListener;
var m_document_removeEventListener = document.removeEventListener;
var m_window_addEventListener = window.addEventListener;
var m_window_removeEventListener = window.removeEventListener;

/**
 * Houses custom event handlers to intercept on document + window event listeners.
 */
var documentEventHandlers = {},
    windowEventHandlers = {};

document.addEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    if (typeof documentEventHandlers[e] != 'undefined') {
        documentEventHandlers[e].subscribe(handler);
    } else {
        m_document_addEventListener.call(document, evt, handler, capture);
    }
};

window.addEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    if (typeof windowEventHandlers[e] != 'undefined') {
        windowEventHandlers[e].subscribe(handler);
    } else {
        m_window_addEventListener.call(window, evt, handler, capture);
    }
};

document.removeEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    // If unsubscribing from an event that is handled by an extension
    if (typeof documentEventHandlers[e] != "undefined") {
        documentEventHandlers[e].unsubscribe(handler);
    } else {
        m_document_removeEventListener.call(document, evt, handler, capture);
    }
};

window.removeEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    // If unsubscribing from an event that is handled by an extension
    if (typeof windowEventHandlers[e] != "undefined") {
        windowEventHandlers[e].unsubscribe(handler);
    } else {
        m_window_removeEventListener.call(window, evt, handler, capture);
    }
};

function createEvent(type, data) {
    var event = document.createEvent('Events');
    event.initEvent(type, false, false);
    if (data) {
        for (var i in data) {
            if (data.hasOwnProperty(i)) {
                event[i] = data[i];
            }
        }
    }
    return event;
}

if (typeof window.console === "undefined") {
    window.console = {
        log: function() {}
    };
}

var xFace = {
    define: define,
    require: require,
    /**
     * Methods to add/remove your own addEventListener hijacking on document + window.
     */
    addWindowEventHandler: function(event) {
        return (windowEventHandlers[event] = channel.create(event));
    },
    addStickyDocumentEventHandler: function(event) {
        return (documentEventHandlers[event] = channel.createSticky(event));
    },
    addDocumentEventHandler: function(event) {
        return (documentEventHandlers[event] = channel.create(event));
    },
    removeWindowEventHandler: function(event) {
        delete windowEventHandlers[event];
    },
    removeDocumentEventHandler: function(event) {
        delete documentEventHandlers[event];
    },
    /**
     * Retrieve original event handlers that were replaced by xFace
     *
     * @return object
     */
    getOriginalHandlers: function() {
        return {
            'document': {
                'addEventListener': m_document_addEventListener,
                'removeEventListener': m_document_removeEventListener
            },
            'window': {
                'addEventListener': m_window_addEventListener,
                'removeEventListener': m_window_removeEventListener
            }
        };
    },
    /**
     * Method to fire event from native code
     * bNoDetach is required for events which cause an exception which needs to be caught in native code
     */
    fireDocumentEvent: function(type, data, bNoDetach) {
        var evt = createEvent(type, data);
        if (typeof documentEventHandlers[type] != 'undefined') {
            if (bNoDetach) {
                documentEventHandlers[type].fire(evt);
            } else {
                setTimeout(function() {
                    documentEventHandlers[type].fire(evt);
                }, 0);
            }
        } else {
            document.dispatchEvent(evt);
        }
    },
    fireWindowEvent: function(type, data) {
        var evt = createEvent(type, data);
        if (typeof windowEventHandlers[type] != 'undefined') {
            setTimeout(function() {
                windowEventHandlers[type].fire(evt);
            }, 0);
        } else {
            window.dispatchEvent(evt);
        }
    },
    // TODO: this is Android only; think about how to do this better
    shuttingDown: false,
    UsePolling: false,
    // END TODO

    /**
     * Extension callback mechanism.
     */
    // Randomize the starting callbackId to avoid collisions after refreshing or navigating.
    // This way, it's very unlikely that any new callback would get the same callbackId as an old callback.
    callbackId: Math.floor(Math.random() * 2000000000),
    callbacks: {},
    callbackStatus: {
        NO_RESULT: 0,
        PROGRESS_CHANGING: 1,
        OK: 2,
        CLASS_NOT_FOUND_EXCEPTION: 3,
        ILLEGAL_ACCESS_EXCEPTION: 4,
        INSTANTIATION_EXCEPTION: 5,
        MALFORMED_URL_EXCEPTION: 6,
        IO_EXCEPTION: 7,
        INVALID_ACTION: 8,
        JSON_EXCEPTION: 9,
        ERROR: 10
    },
    /**
     * Called by native code when returning successful result from an action.
     */
    callbackSuccess: function(callbackId, args) {
        // TODO: Deprecate callbackSuccess, callbackError and callbackStatusChanged in favour of callbackFromNative.
        try {
            xFace.callbackFromNative(callbackId, true, args.status, [args.message], args.keepCallback);
        } catch (e) {
            console.log("Error in success callback: " + callbackId + " = " + e);
        }
    },

    /**
     * Called by native code when returning error result from an action.
     */
    callbackError: function(callbackId, args) {
        try {
            xFace.callbackFromNative(callbackId, false, args.status, [args.message], args.keepCallback);
        } catch (e) {
            console.log("Error in error callback: " + callbackId + " = " + e);
        }
    },

    /**
     * Called by native code when status changed from an async action.
     */
    callbackStatusChanged: function(callbackId, args) {
        try {
            xFace.callbackFromNative(callbackId, true, args.status, [args.message], args.keepCallback);
        } catch (e) {
            console.log("Error in status changed callback: " + callbackId + " = " + e);
        }
    },

    /**
     * Called by native code when returning the result from an action.
     */
    callbackFromNative: function(callbackId, success, status, message, keepCallback) {
        var callback = xFace.callbacks[callbackId];
        if (callback) {
            if (success && status == xFace.callbackStatus.OK &&  callback.success ) {
                callback.success.apply(null, message);
            } else if (success && status == xFace.callbackStatus.PROGRESS_CHANGING && callback.statusChanged) {
                callback.statusChanged.apply(null, message);
            } else if (!success && callback.fail) {
                callback.fail.apply(null, message);
            }

            // Clear callback if not expecting any more results
            if (!keepCallback) {
                delete xFace.callbacks[callbackId];
            }
        }

    },

    addConstructor: function(func) {
        channel.onxFaceReady.subscribe(function() {
            try {
                func();
            } catch (e) {
                console.log("Failed to run constructor: " + e);
            }
        });
    }
};

/**
 * 该模块定义事件相关的一些功能.
 * @module event
 */

/**
 * 该类定义了手机上面的绝大部分事件（Android, iOS, WP8）<br/>
 * @class BaseEvent
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
// Register pause, resume and deviceready channels as events on document.

/**
 * 当应用被放置到后台时，该事件被触发（Android, iOS, WP8）<br/>
 * 注意：在pause事件处理过程中，不能直接调用扩展提供的任何接口以及要求交互的语句，如alerts。请通过setTimeout的方式调用
 * @example
        function onPause() {
           //在应用被放置到后台时做出相应的处理
        }

        document.addEventListener("pause", onPause, false);
 * @event pause
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
channel.onPause = xFace.addDocumentEventHandler('pause');
/**
 * 当应用从后台被唤醒到前台时，该事件被触发（Android, iOS, WP8）<br/>
 * 注意：iOS平台在resume事件处理过程中，不能直接调用扩展提供的任何接口以及要求交互的语句，如alerts。请通过setTimeout的方式调用
 * @example
        function onResume() {
           //在应用从后台被唤醒到前台时做出相应的处理
        }

        document.addEventListener(("resume", onResume, false);
 * @event resume
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
channel.onResume = xFace.addDocumentEventHandler('resume');
/**
 * 当xFace全部加载完成会触发该事件，这个事件很重要，每一个xFace应用都需要使用该事件（Android, iOS, WP8）<br/>
 * 注意：所有xFace提供的API都必须要在deviceready触发的过程中或者触发后才能够被调用，否则可能会出现函数没有定义的错误
 * @example
        function onDeviceReady(para) {
            alert(para.data);
            //现在可以安全调用xFace的API了
        }
        document.addEventListener("deviceready", onDeviceReady, false); 
 * @event deviceready
 * @param {Object} [para] 可选启动参数。程序启动的时候可以接受portal或者引擎传过来的参数，参数传入通过xFace.AMS.startApplication接口（参见{{#crossLink "AMS/startApplication"}}{{/crossLink}}
）传入
 * @param {String} para.data   启动参数
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
channel.onDeviceReady = xFace.addStickyDocumentEventHandler('deviceready');

/**
 * 当放大音量键被按下时，会触发该事件（Android）<br/> 
 * @example
        function onVolumeUpButton(){
            alert("App deals with volumeupbutton by itself!");
        }
        document.addEventListener("volumeupbutton", onVolumeUpButton, false);
 * @event volumeupbutton
 * @platform Android, iOS
 * @since 3.0.0
 */
//volumeupbutton在platform.js中定义
/**
 * 当缩小音量键被按下时，会触发该事件（Android, iOS）<br/>
 * @example
        function onVolumeDownButton(){
            alert("App deals with volumedownbutton by itself!");
        }
        document.addEventListener("volumedownbutton", onVolumeDownButton, false);
 * @event volumedownbutton
 * @platform Android, iOS
 * @since 3.0.0
 */
//batterylow在platform.js中定义
/**
 * 当返回键被按下时，会触发该事件（Android,WP8）<br/>
 * 注意：如果应用没有注册返回键的事件，默认会直接退出程序
 * @example
 function onBackKeyDown() {
 alert("返回键事件被触发");
 }
 document.addEventListener("backbutton", onBackKeyDown, false);
 * @event backbutton
 * @for BaseEvent
 * @platform Android,WP8
 * @since 3.0.0
 */
//backbutton在platform.js中定义

module.exports = xFace;