// File generated at :: Wed Mar 20 2013 14:56:12 GMT+0800 (CST)


;(function() {

// file: lib/scripts/require.js
var require,
    define;

(function () {
    var modules = {};
    // 用于维护处于build过程中的moduleIds
    var requireStack = [];
    // 用于建立moduleId与moduleId在requireStack中索引位置的映射关系
    var inProgressModules = {};

    function build(module) {
        var factory = module.factory;
        module.exports = {};
        delete module.factory;
        factory(require, module.exports, module);
        return module.exports;
    }

    require = function (id) {
        if (!modules[id]) {
            throw "module " + id + " not found";
        } else if (id in inProgressModules) {
            var cycle = requireStack.slice(inProgressModules[id]).join('->') + '->' + id;
            throw "Cycle in require graph: " + cycle;
        }
        if (modules[id].factory) {
            try {
                inProgressModules[id] = requireStack.length;
                requireStack.push(id);
                return build(modules[id]);
            } finally {
                delete inProgressModules[id];
                requireStack.pop();
            }
        }
        return modules[id].exports;
    };

    define = function (id, factory) {
        if (modules[id]) {
            throw "module " + id + " already defined";
        }

        modules[id] = {
            id: id,
            factory: factory
        };
    };

    define.remove = function (id) {
        delete modules[id];
    };

})();

if (typeof module === "object" && typeof require === "function") {
    module.exports.require = require;
    module.exports.define = define;
}

// file: lib/xFace.js
define("xFace", function(require, exports, module) {
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

if(typeof window.console === "undefined") {
    window.console = {
        log:function(){}
    };
}

var xFace = {
    define:define,
    require:require,
    /**
     * Methods to add/remove your own addEventListener hijacking on document + window.
     */
    addWindowEventHandler:function(event) {
        return (windowEventHandlers[event] = channel.create(event));
    },
    addStickyDocumentEventHandler:function(event) {
        return (documentEventHandlers[event] = channel.createSticky(event));
    },
    addDocumentEventHandler:function(event) {
        return (documentEventHandlers[event] = channel.create(event));
    },
    removeWindowEventHandler:function(event) {
        delete windowEventHandlers[event];
    },
    removeDocumentEventHandler:function(event) {
        delete documentEventHandlers[event];
    },
    /**
     * Retrieve original event handlers that were replaced by xFace
     *
     * @return object
     */
    getOriginalHandlers: function() {
        return {'document': {'addEventListener': m_document_addEventListener, 'removeEventListener': m_document_removeEventListener},
        'window': {'addEventListener': m_window_addEventListener, 'removeEventListener': m_window_removeEventListener}};
    },
    /**
     * Method to fire event from native code
     * bNoDetach is required for events which cause an exception which needs to be caught in native code
     */
    fireDocumentEvent: function(type, data, bNoDetach) {
        var evt = createEvent(type, data);
        if (typeof documentEventHandlers[type] != 'undefined') {
            if( bNoDetach ) {
              documentEventHandlers[type].fire(evt);
            }
            else {
              setTimeout(function() {
                  documentEventHandlers[type].fire(evt);
              }, 0);
            }
        } else {
            document.dispatchEvent(evt);
        }
    },
    fireWindowEvent: function(type, data) {
        var evt = createEvent(type,data);
        if (typeof windowEventHandlers[type] != 'undefined') {
            setTimeout(function() {
                windowEventHandlers[type].fire(evt);
            }, 0);
        } else {
            window.dispatchEvent(evt);
        }
    },
    // TODO: this is Android only; think about how to do this better
    shuttingDown:false,
    UsePolling:false,
    // END TODO

    /**
     * Extension callback mechanism.
     */
    // Randomize the starting callbackId to avoid collisions after refreshing or navigating.
    // This way, it's very unlikely that any new callback would get the same callbackId as an old callback.
    callbackId: Math.floor(Math.random() * 2000000000),
    callbacks:  {},
    callbackStatus: {
        NO_RESULT: 0,
        PROGRESS_CHANGING:1,
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
    callbackType: {
        SUCCESS_CALLBACK: 0,
        ERROR_CALLBACK: 1,
        STATUSCHANGED_CALLBACK: 2
    },

    /**
     * Called by native code when returning successful result from an action.
     */
    callbackSuccess: function(callbackId, args) {
         // TODO: Deprecate callbackSuccess, callbackError and callbackStatusChanged in favour of callbackFromNative.
        try {
            xFace.callbackFromNative(callbackId, xFace.callbackType.SUCCESS_CALLBACK, args.status, args.message, args.keepCallback);
        } catch (e) {
            console.log("Error in success callback: " + callbackId + " = " + e);
        }
    },

    /**
     * Called by native code when returning error result from an action.
     */
    callbackError: function(callbackId, args) {
        try {
            xFace.callbackFromNative(callbackId, xFace.callbackType.ERROR_CALLBACK, args.status, args.message, args.keepCallback);
        } catch (e) {
            console.log("Error in error callback: " + callbackId + " = " + e);
        }
    },

    /**
     * Called by native code when status changed from an async action.
     */
    callbackStatusChanged : function(callbackId, args){
        try {
            xFace.callbackFromNative(callbackId, xFace.callbackType.STATUSCHANGED_CALLBACK, args.status, args.message, args.keepCallback);
        } catch (e) {
            console.log("Error in status changed callback: " + callbackId + " = " + e);
        }
    },

    /**
     * Called by native code when returning the result from an action.
     */
    callbackFromNative: function(callbackId, type, status, message, keepCallback) {
        var callback = xFace.callbacks[callbackId];
        if (callback) {
            if (type === xFace.callbackType.SUCCESS_CALLBACK && status === xFace.callbackStatus.OK) {
                if (typeof callback.success === 'function') {
                    callback.success(message);
                }
            } else if (type === xFace.callbackType.STATUSCHANGED_CALLBACK && status === xFace.callbackStatus.PROGRESS_CHANGING) {
                if (typeof callback.statusChanged === 'function') {
                    callback.statusChanged(message);
                }
            } else if (type === xFace.callbackType.ERROR_CALLBACK) {
                if (typeof callback.fail === 'function') {
                    callback.fail(message);
                }
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
            } catch(e) {
                console.log("Failed to run constructor: " + e);
            }
        });
    },

    // TODO: 因为此功能只在自动化测试时使用，考虑分工程加载
    printScreen: function(imgName, successCallback, errorCallback) {
        var exec = require('xFace/exec');
        exec(successCallback, errorCallback, null, "PrintScreen", "printScreen", [imgName]);
    }
};

/**
 * 该模块定义事件相关的一些功能.
 * @module event
 */

/**
 * 该类定义了手机上面的绝大部分事件（Android, iOS）<br/> 
 * @class BaseEvent
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
// Register pause, resume and deviceready channels as events on document.

/**
 * 当应用被放置到后台时，该事件被触发（Android, iOS）<br/>
 * 注意：在pause事件处理过程中，不能直接调用扩展提供的任何接口以及要求交互的语句，如alerts。请通过setTimeout的方式调用
 * @example
        function onPause() {
           //在应用被放置到后台时做出相应的处理
        }

        document.addEventListener("pause", onPause, false);
 * @event pause
 * @platform Android, iOS
 * @since 3.0.0
 */
channel.onPause = xFace.addDocumentEventHandler('pause');
/**
 * 当应用从后台被唤醒到前台时，该事件被触发（Android, iOS）<br/>
 * 注意：iOS平台在resume事件处理过程中，不能直接调用扩展提供的任何接口以及要求交互的语句，如alerts。请通过setTimeout的方式调用
 * @example
        function onResume() {
           //在应用从后台被唤醒到前台时做出相应的处理
        }

        document.addEventListener(("resume", onResume, false);
 * @event resume
 * @platform Android, iOS
 * @since 3.0.0
 */
channel.onResume = xFace.addDocumentEventHandler('resume');
/**
 * 当xFace全部加载完成会触发该事件，这个事件很重要，每一个xFace应用都需要使用该事件（Android, iOS）<br/>
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
 * @platform Android, iOS
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

module.exports = xFace;

});

// file: lib/common/ajax.js
define("xFace/ajax", function(require, exports, module) {
var privateModule = require('xFace/privateModule');
XMLHttpRequest.prototype.open_raw  = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function(m, u, b) {
  if(privateModule.isSecurityMode())
  {
    if(url.indexOf("http")==-1)
    {
     this.open_raw(m, u, b);
    }else
    {
        //TODO:目前异步请求不稳定，待处理
        this.open_raw(m, url, false);
    }
  }else
  {
     this.open_raw(m, u, b);
  }
  if(xFace.iOSWVAddr)
  {
     //用于在引擎内部区分不同xapp的请求（iOS only）
     this.setRequestHeader('wv', xFace.iOSWVAddr);
  }
};

function redirectUrl(url)
{
   var TOKEN ="_xface_proxy_ajax_";
   var reurl = url;

   //TODO:https 的支持
   if(url.indexOf("http") != -1 && privateModule.isSecurityMode())
   {
    //需要进行重定向
      reurl = "/"+ TOKEN +"/" + url;
   }
   return reurl;
}
});

// file: lib/common/app.js
define("xFace/app", function(require, exports, module) {

 /**
  * 该类提供一系列基础api，用于进行app通信以及监听app的启动、关闭事件（Android, iOS）<br/>
  * 该类不能通过new来创建相应的对象，只能通过xFace.app对象来直接使用该类中定义的方法
  * @class App
  * @namespace xFace
  * @platform Android, iOS
  * @since 3.0.0
  */
var channel = require('xFace/channel');
var gstorage = require('xFace/localStorage');
/**
 * 当前应用收到其它应用发送的消息时，该事件被触发（Android, iOS）<br/>
 * 注意：只支持主应用与普通应用之间进行通信
 * @example
        function handler(data) {
            console.log("Received message: " + data);
        }
        xFace.app.addEventListener("message", handler);
 * @event message
 * @param {String} data 其它应用发送的数据
 * @platform Android, iOS
 * @since 3.0.0
 */
var message = channel.create("message");
/**
 * 当一个应用启动时，该事件被触发（Android, iOS）<br/>
 * 注意：只有主应用能够监听该事件
 * @example
        function handler() {
            console.log("One app has started!");
        }
        xFace.app.addEventListener("start", handler);
 * @event start
 * @platform Android, iOS
 * @since 3.0.0
 */
var start = channel.create("start");
/**
 * 当一个应用关闭时，该事件被触发（Android, iOS）<br/>
 * 注意：只有主应用能够监听该事件
 * @example
        function handler() {
            console.log("One app has closed!");
        }
        xFace.app.addEventListener("start", handler);
 * @event close
 * @platform Android, iOS
 * @since 3.0.0
 */
var close = channel.create("close");

var app =
{
    /**
     * 注册应用相关的事件监听器（Android, iOS）
     * @example
            function handler(data) {
                console.log("Received message: " + data);
            }
            xFace.app.addEventListener("message", handler);
     * @method addEventListener
     * @param {String} evt 事件类型，仅支持"message", "start", "close"
     * @param {Function} handler 事件触发时的回调函数
     * @param {String} handler.data 当注册的事件为"message"事件时有效，用于接收应用之间通信时传递的数据
     * @platform Android, iOS
     * @since 3.0.0
     */
    addEventListener:function(evt, handler){
        var e = evt.toLowerCase();
        if(e == "message"){
            message.subscribe(handler);
        }else if(e == "start"){
            start.subscribe(handler);
        }else if(e == "close"){
            close.subscribe(handler);
        }
    },

    /**
     * 注销应用相关的事件监听器（Android, iOS）
     * @example
            function handler(data) {
                console.log("Received message: " + data);
            }
            xFace.app.addEventListener("message", handler);

            // do something ......

            xFace.app.removeEventListener("message", handler);
     * @method removeEventListener
     * @param {String} evt 事件类型，支持"message", "start", "close"
     * @param {Function} handler 要注销的事件监听器<br/>
     *  （该事件监听器通过{{#crossLink "xFace.App/addEventListener"}}{{/crossLink}}接口注册过）
     * @platform Android, iOS
     * @since 3.0.0
     */
    removeEventListener:function(evt, handler){
        var e = evt.toLowerCase();
        if(e == "message"){
            message.unsubscribe(handler);
        }else if(e == "start"){
            start.unsubscribe(handler);
        }else if(e == "close"){
            close.unsubscribe(handler);
        }

    },

    /**
     * 引擎触发应用相关事件的入口函数
     */
    fireAppEvent: function(evt, id){
        var e = evt.toLowerCase();
        if( e == "message"){
           var data = gstorage.getOriginalLocalStorage().getItem.call(localStorage, id);
           gstorage.getOriginalLocalStorage().removeItem.call(localStorage, id);
           message.fire(data);
        }else if(e == "start"){
            start.fire();
        }else if(e == "close"){
            close.fire();
        }
    },

    /**
     * 向其它应用发送消息（Android, iOS）<br/>
     * 注意：只支持主应用与普通应用之间进行通信
     * @example
            xFace.app.sendMessage("This is the message content sent to another app!", null);
     * @method sendMessage
     * @param {Object} data 要发送的消息内容
     * @param {String} [appid] 消息发送的目标应用的应用id（目前不支持该参数）
     * @platform Android, iOS
     * @since 3.0.0
     */
    sendMessage:function(data, appid){

        function toString(data)
        {
            var result;
            if( typeof data == 'string'){
                result = data;
            }else if( data !== null && typeof data == 'object'){
                result = data.toString();
            }
            return result;

        }
        function generateUniqueMsgId()
        {
            var msgId = parseInt((Math.random() * 65535), 10).toString(10);
            while(null !== gstorage.getOriginalLocalStorage().getItem.call(localStorage, msgId))
            {
                 msgId = parseInt((Math.random() * 65535), 10).toString(10);
            }
            return msgId;
        }

        var args = arguments;
        if(args.length === 1){
            //如果是portal,则消息接收者是所有的app，如果是app，则消息接收者是portal
            var msgId = generateUniqueMsgId();
            gstorage.getOriginalLocalStorage().setItem.call(localStorage, msgId, toString(data));
            require('xFace/extension/privateModule').execCommand("xFace_app_send_message:", [msgId]);
        }else if(args.length === 2){
            //TODO
            //发送消息给指定的app
            alert('specified app');

        }
    }
};
module.exports = app;
});

// file: lib/common/argscheck.js
define("xFace/argscheck", function(require, exports, module) {
var moduleExports = module.exports;

var typeMap = {
    'A': 'Array',
    'D': 'Date',
    'N': 'Number',
    'S': 'String',
    'F': 'Function',
    'O': 'Object',
    'B': 'Boolean'
};

function extractParamName(callee, argIndex) {
    return (/.*?\((.*?)\)/).exec(callee)[1].split(', ')[argIndex];
}

function checkArgs(spec, functionName, args, opt_callee) {
    if (!moduleExports.enableChecks) {
        return;
    }
    var errMsg = null;
    var type;
    for (var i = 0; i < spec.length; ++i) {
        var c = spec.charAt(i),
            cUpper = c.toUpperCase(),
            arg = args[i];
        if (c == '*') {
            continue;
        }
        type = Object.prototype.toString.call(arg).slice(8, -1);
        if ((arg === null || arg === undefined) && c == cUpper) {
            continue;
        }
        if (type != typeMap[cUpper]) {
            errMsg = 'Expected ' + typeMap[cUpper];
            break;
        }
    }
    if (errMsg) {
        errMsg += ', but got ' + type + '.';
        errMsg = 'Wrong type for parameter "' + extractParamName(opt_callee || args.callee, i) + '" of ' + functionName + ': ' + errMsg;
        console.error(errMsg);
        throw TypeError(errMsg);
    }
}

moduleExports.checkArgs = checkArgs;
moduleExports.enableChecks = true;
});

// file: lib/common/builder.js
define("xFace/builder", function(require, exports, module) {
var utils = require('xFace/utils');

function each(objects, func, context) {
    for (var prop in objects) {
        if (objects.hasOwnProperty(prop)) {
            func.apply(context, [objects[prop], prop]);
        }
    }
}

function include(parent, objects, clobber, merge) {
    each(objects, function (obj, key) {
        try {
          var result = obj.path ? require(obj.path) : {};

          if (clobber) {
              // Clobber if it doesn't exist.
              if (typeof parent[key] === 'undefined') {
                  parent[key] = result;
              } else if (typeof obj.path !== 'undefined') {
                  // If merging, merge properties onto parent, otherwise, clobber.
                  if (merge) {
                      recursiveMerge(parent[key], result);
                  } else {
                      parent[key] = result;
                  }
              }
              result = parent[key];
          } else {
            // Overwrite if not currently defined.
            if (typeof parent[key] == 'undefined') {
              parent[key] = result;
            } else if (merge && typeof obj.path !== 'undefined') {
              // If merging, merge parent onto result
              recursiveMerge(result, parent[key]);
              parent[key] = result;
            } else {
              // Set result to what already exists, so we can build children into it if they exist.
              result = parent[key];
            }
          }

          if (obj.children) {
            include(result, obj.children, clobber, merge);
          }
        } catch(e) {
          utils.alert('Exception building xFace JS globals: ' + e + ' for key "' + key + '"');
        }
    });
}

/**
 * 递归的合并一个对象的属性到另一个对象上，如果源对象和目标对象的属性相同，则源对象的属性值会覆盖目标对象
 *
 * @param target 目标对象
 * @param src    源对象
 */
function recursiveMerge(target, src) {
    for (var prop in src) {
        if (src.hasOwnProperty(prop)) {
            if (typeof target.prototype !== 'undefined' && target.prototype.constructor === target) {
                // If the target object is a constructor override off prototype.
                target.prototype[prop] = src[prop];
            } else {
                target[prop] = typeof src[prop] === 'object' ? recursiveMerge(
                        target[prop], src[prop]) : src[prop];
            }
        }
    }
    return target;
}

module.exports = {
    build: function (objects) {
        return {
            intoButDontClobber: function (target) {
                include(target, objects, false, false);
            },
            intoAndClobber: function(target) {
                include(target, objects, true, false);
            },
            intoAndMerge: function(target) {
                include(target, objects, true, true);
            }
        };
    }
};
});

// file: lib/common/channel.js
define("xFace/channel", function(require, exports, module) {
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

});

// file: lib/common/common.js
define("xFace/common", function(require, exports, module) {
require('xFace/ajax');

module.exports = {
    objects: {
        xFace: {
            path: 'xFace',
            children: {
                app:{
                  path: 'xFace/app'
                },
                exec: {
                    path: 'xFace/exec'
                },
                AMS:{
                    path:'xFace/extension/ams'
                },
                Message: {
                    path: 'xFace/extension/Message'
                },
                Messaging: {
                    path: 'xFace/extension/Messaging'
                },
                MessageTypes: {
                    path: 'xFace/extension/MessageTypes'
                },
                Telephony: {
                    path: 'xFace/extension/Telephony'
                },
                AdvancedFileTransfer: {
                    path: 'xFace/extension/AdvancedFileTransfer'
                },
                Security: {
                   path: 'xFace/extension/Security'
                },
                Setting: {
                   path: 'xFace/extension/Setting'
                },
                PushNotification: {
                   path: 'xFace/extension/PushNotification'
                },
                Zip: {
                   path: 'xFace/extension/Zip'
                },
                BarcodeScanner: {
                   path:'xFace/extension/BarcodeScanner'
                },
                ui: {
                    children: {
                        Calendar:{
                            path:'xFace/extension/Calendar'
                        }
                    }
                }
            }
        },
        navigator: {
            children: {
                app: {
                    path: 'xFace/extension/app'
                },
                accelerometer: {
                    path: 'xFace/extension/accelerometer'
                },
                compass: {
                    path: 'xFace/extension/compass'
                },
                network: {
                    children: {
                        connection: {
                            path: 'xFace/extension/network'
                        }
                    }
                },
                contacts: {
                    path: 'xFace/extension/contacts'
                },
                notification: {
                    path: 'xFace/extension/Notification'
                },
                battery:{
                    path: 'xFace/extension/battery'
                },
                camera:{
                    path: 'xFace/extension/Camera'
                },
                device:{
                    children:{
                        capture: {
                            path: 'xFace/extension/capture'
                        }
                    }
                },
                splashscreen: {
                    path: 'xFace/extension/splashscreen'
                }
            }
        },
        Acceleration: {
            path: 'xFace/extension/Acceleration'
        },
        Camera:{
            path: 'xFace/extension/CameraConstants'
        },
        Connection: {
            path: 'xFace/extension/Connection'
        },
        Contact: {
            path: 'xFace/extension/Contact'
        },
        ContactAddress: {
            path: 'xFace/extension/ContactAddress'
        },
        ContactError: {
            path: 'xFace/extension/ContactError'
        },
        ContactField: {
            path: 'xFace/extension/ContactField'
        },
        ContactAccountType: {
            path: 'xFace/extension/ContactAccountType'
        },
        ContactFindOptions: {
            path: 'xFace/extension/ContactFindOptions'
        },
        ContactName: {
            path: 'xFace/extension/ContactName'
        },
        ContactOrganization: {
            path: 'xFace/extension/ContactOrganization'
        },
        device: {
            path: 'xFace/extension/device'
        },
        DirectoryEntry: {
            path: 'xFace/extension/DirectoryEntry'
        },
        DirectoryReader: {
            path: 'xFace/extension/DirectoryReader'
        },
        Entry: {
            path: 'xFace/extension/Entry'
        },
        FileEntry: {
            path: 'xFace/extension/FileEntry'
        },
        File: {
            path: 'xFace/extension/File'
        },
        FileError: {
            path: 'xFace/extension/FileError'
        },
        FileWriter: {
            path: 'xFace/extension/FileWriter'
        },
        FileReader: {
            path: 'xFace/extension/FileReader'
        },
        FileTransfer: {
            path: 'xFace/extension/FileTransfer'
        },
        FileTransferError: {
            path: 'xFace/extension/FileTransferError'
        },
        FileUploadOptions: {
            path: 'xFace/extension/FileUploadOptions'
        },
        FileUploadResult: {
            path: 'xFace/extension/FileUploadResult'
        },
        FileSystem: {
            path: 'xFace/extension/FileSystem'
        },
        Flags: {
            path: 'xFace/extension/Flags'
        },
        LocalFileSystem: {
            path: 'xFace/extension/LocalFileSystem'
        },
        Metadata: {
            path: 'xFace/extension/Metadata'
        },
        requestFileSystem: {
            path: 'xFace/extension/requestFileSystem'
        },
        resolveLocalFileSystemURI: {
            path: 'xFace/extension/resolveLocalFileSystemURI'
        },
        ProgressEvent: {
            path: 'xFace/extension/ProgressEvent'
        },
        CompassHeading:{
            path: 'xFace/extension/CompassHeading'
        },
        CompassOptions:{
            path: 'xFace/extension/CompassOptions'
        },
        CompassError:{
            path: 'xFace/extension/CompassError'
        },
        CaptureError: {
            path: 'xFace/extension/CaptureError'
        },
        CaptureAudioOptions:{
            path: 'xFace/extension/CaptureAudioOptions'
        },
        CaptureImageOptions: {
            path: 'xFace/extension/CaptureImageOptions'
        },
        CaptureVideoOptions: {
            path: 'xFace/extension/CaptureVideoOptions'
        },
        ConfigurationData: {
            path: 'xFace/extension/ConfigurationData'
        },
        Media: {
            path: 'xFace/extension/Media'
        },
        MediaError: {
            path: 'xFace/extension/MediaError'
        },
        MediaFile: {
            path: 'xFace/extension/MediaFile'
        },
        MediaFileData:{
            path: 'xFace/extension/MediaFileData'
        },
        ZipError: {
             path: 'xFace/extension/ZipError'
        },
        ZipOptions:{
             path: 'xFace/extension/ZipOptions'
        },
        AmsError: {
             path: 'xFace/extension/AmsError'
        },
        AmsState: {
             path: 'xFace/extension/AmsState'
        },
        AmsOperationType: {
             path: 'xFace/extension/AmsOperationType'
        }
    }
};

});

// file: lib/ios/exec.js
define("xFace/exec", function(require, exports, module) {
 var xFace = require('xFace'),
     channel = require('xFace/channel'),
     utils = require('xFace/utils'),
     jsToNativeModes = {
         IFRAME_NAV: 0,
         XHR_NO_PAYLOAD: 1,
         XHR_WITH_PAYLOAD: 2,
         XHR_OPTIONAL_PAYLOAD: 3
     },
     bridgeMode,
     execIframe,
     execXhr,
     requestCount = 0,
     commandQueue = [], // Contains pending JS->Native messages.
     isInContextOfEvalJs = 0;

function createExecIframe() {
    var iframe = document.createElement("iframe");
    iframe.style.display = 'none';
    document.body.appendChild(iframe);
    return iframe;
}

function shouldBundleCommandJson() {
    if (bridgeMode == jsToNativeModes.XHR_WITH_PAYLOAD) {
        return true;
    }
    if (bridgeMode == jsToNativeModes.XHR_OPTIONAL_PAYLOAD) {
        var payloadLength = 0;
        for (var i = 0; i < commandQueue.length; ++i) {
            payloadLength += commandQueue[i].length;
        }
        // The value here was determined using the benchmark within CordovaLibApp on an iPad 3.
        return payloadLength < 4500;
    }
    return false;
}

function iOSExec() {
    // XHR mode's main advantage is working around a bug in -webkit-scroll, which only exists in 5.X devices
    if (bridgeMode === undefined) {
        bridgeMode = navigator.userAgent.indexOf(' 5_') != -1 ? jsToNativeModes.XHR_NO_PAYLOAD : jsToNativeModes.IFRAME_NAV;
    }

    var successCallback, failCallback, statusChangedCallback, service, action, actionArgs, splitCommand;
    var callbackId = null;
    if (typeof arguments[0] !== "string") {
        // FORMAT ONE
        successCallback = arguments[0];
        failCallback = arguments[1];
        statusChangedCallback = arguments[2];
        service = arguments[3];
        action = arguments[4];
        actionArgs = arguments[5];

        // Since we need to maintain backwards compatibility, we have to pass
        // an invalid callbackId even if no callback was provided since extensions
        // will be expecting it. The xFace.exec() implementation allocates
        // an invalid callbackId and passes it even if no callbacks were given.
        callbackId = 'INVALID';
    } else {
        // FORMAT TWO
        splitCommand = arguments[0].split(".");
        action = splitCommand.pop();
        service = splitCommand.join(".");
        actionArgs = Array.prototype.splice.call(arguments, 1);
    }

    // Register the callbacks and add the callbackId to the positional
    // arguments if given.
    if (successCallback || failCallback || statusChangedCallback) {
        callbackId = service + xFace.callbackId++;
        xFace.callbacks[callbackId] =
        {success:successCallback, fail:failCallback, statusChanged:statusChangedCallback};
    }

    var command = [callbackId, service, action, actionArgs];

    // Stringify and queue the command. We stringify to command now to
    // effectively clone the command arguments in case they are mutated before
    // the command is executed.
    commandQueue.push(JSON.stringify(command));

    // If we're in the context of a stringByEvaluatingJavaScriptFromString call,
    // then the queue will be flushed when it returns; no need for a poke.
    // Also, if there is already a command in the queue, then we've already
    // poked the native side, so there is no reason to do so again.
    if (!isInContextOfEvalJs && commandQueue.length == 1) {
        if (bridgeMode != jsToNativeModes.IFRAME_NAV) {
            // This prevents sending an XHR when there is already one being sent.
            // This should happen only in rare circumstances (refer to unit tests).
            if (execXhr && execXhr.readyState != 4) {
                execXhr = null;
            }
            // Re-using the XHR improves exec() performance by about 10%.
            execXhr = execXhr || new XMLHttpRequest();
            // Changing this to a GET will make the XHR reach the URIProtocol on 4.2.
            // For some reason it still doesn't work though...
            execXhr.open('HEAD', "/!xface_exec", true);
            execXhr.setRequestHeader('rc', ++requestCount);
            if (shouldBundleCommandJson()) {
                execXhr.setRequestHeader('cmds', iOSExec.nativeFetchMessages());
            }
            execXhr.send(null);
        } else {
            execIframe = execIframe || createExecIframe();
            execIframe.src = "xface://ready";
        }
    }
}

iOSExec.jsToNativeModes = jsToNativeModes;

iOSExec.setJsToNativeBridgeMode = function(mode) {
    // Remove the iFrame since it may be no longer required, and its existence
    // can trigger browser bugs.
    // https://issues.apache.org/jira/browse/CB-593
    if (execIframe) {
        execIframe.parentNode.removeChild(execIframe);
        execIframe = null;
    }
    bridgeMode = mode;
};

iOSExec.nativeFetchMessages = function() {
    // Each entry in commandQueue is a JSON string already.
    if (!commandQueue.length) {
        return '';
    }
    var json = '[' + commandQueue.join(',') + ']';
    commandQueue.length = 0;
    return json;
};

iOSExec.nativeCallback = function(callbackId, status, payload, keepCallback) {
    return iOSExec.nativeEvalAndFetch(function() {
        var callbackType = xFace.callbackType.ERROR_CALLBACK;
        if((xFace.callbackStatus.NO_RESULT === status) || (xFace.callbackStatus.OK === status))
        {
            //if status is NO_RESULT, just clear callback
            callbackType = xFace.callbackType.SUCCESS_CALLBACK;
        }
        else if(xFace.callbackStatus.PROGRESS_CHANGING === status)
        {
            callbackType = xFace.callbackType.STATUSCHANGED_CALLBACK;
        }

        xFace.callbackFromNative(callbackId, callbackType, status, payload, keepCallback);
    });
};

iOSExec.nativeEvalAndFetch = function(func) {
    // This shouldn't be nested, but better to be safe.
    isInContextOfEvalJs++;
    try {
        func();
        return iOSExec.nativeFetchMessages();
    } finally {
        isInContextOfEvalJs--;
    }
};

module.exports = iOSExec;
});

// file: lib/common/extension/Acceleration.js
define("xFace/extension/Acceleration", function(require, exports, module) {

 /**
 * 该类对象包含特定时间点采集到的加速计数据，并作为{{#crossLink "Accelerometer"}}{{/crossLink}}的参数返回(Andriod,iOS) </br>
 * @class Acceleration
 * @platform Android,iOS
 * @since 3.0.0
 */
var Acceleration = function(x, y, z, timestamp) {
/**
 * x轴方向的加速度(Andriod,iOS)
 * @property x
 * @type Number
 * @platform Android,iOS
 * @since 3.0.0
 */
  this.x = x;
/**
 * y轴方向的加速度(Andriod,iOS)
 * @property y
 * @type Number
 * @platform Android,iOS
 * @since 3.0.0
 */
  this.y = y;
/**
 * z轴方向的加速度(Andriod,iOS)
 * @property z
 * @type Number
 * @platform Android,iOS
 * @since 3.0.0
 */
  this.z = z;
/**
 * 获取加速度信息获取时的时间（距1970年1月1日之间的毫秒数）(Andriod,iOS)
 * @property timestamp
 * @type Number
 * @platform Android,iOS
 * @since 3.0.0
 */
  this.timestamp = timestamp || (new Date()).getTime();
};

module.exports = Acceleration;
});

// file: lib/common/extension/AdvancedFileTransfer.js
define("xFace/extension/AdvancedFileTransfer", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

/**
 * 提供高级文件传输（断点下载与上传），暂停，取消等功能（Android，iOS）<br/>
 * @example
        var uploadUrl = "http://polyvi.net:8091/mi/UploadServer";
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer1 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe");//构造下载对象
        var fileTransfer2 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);//构造下载对象
        var fileTransfer3 = new xFace.AdvancedFileTransfer("test_upload2.rar", uploadUrl, true); //构造上传对象
 * @param {String} source 文件传输的源文件地址（下载时为服务器地址，上传时为本地地址（只能在workspace目录下））
 * @param {String} target 文件传输的目标地址（下载时为本地地址（可以为工作目录也可以指定其他路径，其他路径用file://头标示），上传时为服务器地址）
 * @param {boolean} [isUpload=false] 标识是上传还是下载（默认为false，即默认为下载，iOS目前还不支持上传）
 * @class AdvancedFileTransfer
 * @namespace xFace
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS
 */
var AdvancedFileTransfer = function(source, target, isUpload) {
    argscheck.checkArgs('ssB', 'AdvancedFileTransfer.AdvancedFileTransfer', arguments);
    this.source = source;
    this.target = target;
    this.isUpload = isUpload || false;
    /**
    * 用于接收文件传输的进度通知，该回调函数包含一个类型为Object的参数，该参数包含以下属性：（Android，iOS）<br/>
    * loaded: 已经传输的文件块大小<br/>
    * total: 要传输的文件总大小
    * @property onprogress
    * @type Function
    * @platform Android, iOS
    * @since 3.0.0
    */
    this.onprogress = null;     // While download the file, and reporting partial download data
};

/**
 * 下载一个文件到指定的路径(Android, iOS)<br/>
 * 下载过程中会通过onprogress属性更新文件传输进度。
 * @example
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);
        fileTransfer.download(success, fail);
        fileTransfer.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        function success(entry) {
            alert("success");
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert(error.code);
            alert(error.source);
            alert(error.target);
        }
 * @method download
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry} successCallback.fileEntry 成功回调返回下载得到的文件的{{#crossLink "FileEntry"}}{{/crossLink}}对象
 * @param {Function} [errorCallback]   失败回调函数
 * @param {Object} errorCallback.errorInfo 失败回调返回的参数
 * @param {Number} errorCallback.errorInfo.code 错误码（在<a href="FileTransferError.html">FileTransferError</a>中定义）
 * @param {String} errorCallback.errorInfo.source 下载源地址
 * @param {String} errorCallback.errorInfo.target 下载目标地址
 * @platform Android, iOS
 * @since 3.0.0
 */
AdvancedFileTransfer.prototype.download = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'AdvancedFileTransfer.download', arguments);
    var win = function(result) {
        var entry = null;
        if (result.isDirectory) {
            entry = new DirectoryEntry();
        }
        else if (result.isFile) {
            entry = new FileEntry();
        }
        entry.isDirectory = result.isDirectory;
        entry.isFile = result.isFile;
        entry.name = result.name;
        entry.fullPath = result.fullPath;
        successCallback(entry);
    };
    var me = this;
    var s = function(result) {
        if (typeof me.onprogress === "function") {
                me.onprogress(new ProgressEvent("progress", {loaded:result.loaded, total:result.total}));
            }
    };

    exec(win, errorCallback, s, 'AdvancedFileTransfer', 'download', [this.source, this.target]);
};

/**
*  暂停文件传输操作（上传/下载）（Android, iOS）<br/>
*  @example
        //构造下载对象，先调用下载接口，然后调用暂停接口暂停下载
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer1 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);
        fileTransfer1.download(success, fail);
        fileTransfer1.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer1.pause();
        //构造上传对象，先调用上传接口，然后调用暂停接口暂停上传。
        var uploadUrl = "http://polyvi.net:8091/mi/UploadServer";
        var fileTransfer2 = new xFace.AdvancedFileTransfer("test_upload2.rar",uploadUrl,true);
        fileTransfer2.upload(success, fail);
        fileTransfer2.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer2.pause();
        function success() {
            alert("success");
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert(error.code);
            alert(error.source);
            alert(error.target);
        }
*  @method pause
*  @platform Android, iOS
*  @since 3.0.0
*/
AdvancedFileTransfer.prototype.pause = function() {
    exec(null, null, null, 'AdvancedFileTransfer', 'pause', [this.source]);
};

/**
*  取消文件的传输操作（上传/下载），相应的临时文件也会被删除（Android, iOS）<br/>
*  @example
        //构造下载对象，先调用下载接口，然后调用取消接口取消下载。
        var downloadUrl = "http://apollo.polyvi.com/develop/TestFileTransfer/test.exe";
        var fileTransfer1 = new xFace.AdvancedFileTransfer(downloadUrl, "test.exe", false);
        fileTransfer1.download(success, fail);
        fileTransfer1.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer1.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer1.cancel();
        //构造上传对象，先调用上传接口，然后调用取消接口取消上传。
        var uploadUrl = "http://polyvi.net:8091/mi/UploadServer";
        var fileTransfer2 = new xFace.AdvancedFileTransfer("test_upload2.rar",uploadUrl,true);
        fileTransfer2.upload(success, fail)
        fileTransfer2.onprogress = function(evt){
            var progress  = evt.loaded / evt.total;
        };
        fileTransfer2.cancel();
        function success() {
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert(error.code);
            alert(error.source);
            alert(error.target);
        }
*  @method cancel
*  @platform Android, iOS
*  @since 3.0.0
*/
AdvancedFileTransfer.prototype.cancel = function() {
    exec(null, null, null, 'AdvancedFileTransfer', 'cancel', [this.source, this.target, this.isUpload]);
};

module.exports = AdvancedFileTransfer;
});

// file: lib/common/extension/AmsError.js
define("xFace/extension/AmsError", function(require, exports, module) {
 
/**
 * 该类定义了AMS的错误码，相关用法参考{{#crossLink "AMS"}}{{/crossLink}} （Android, iOS）<br/>
 * @class AmsError
 * @static
 * @platform Android,iOS
 * @since 3.0.0
 */
function AmsError(error) {
 /**
  * 应用操作的错误码，用于表示具体的应用操作的错误(Android, iOS)<br/>
  * 其取值范围参考{{#crossLink "AmsError"}}{{/crossLink}}中定义的常量
  * @example
        function errorCallback(amsError) {
            if( amsError.code == AmsError.NO_SRC_PACKAGE) {
                print("Package does not exist");
            }
        }
  * @property code
  * @type Number
  * @platform Android, iOS
  * @since 3.0.0
  */
  this.code = error || null;
}

// ams error codes

/**
 * 应用安装包不存在
 * @property NO_SRC_PACKAGE
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsError.NO_SRC_PACKAGE = 1;  

/**
 * 应用已经存在
 * @property APP_ALREADY_EXISTED
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsError.APP_ALREADY_EXISTED =  2;

/**
 * IO异常错误
 * @property IO_ERROR
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
 
AmsError.IO_ERROR = 3;             
/**
 * 用于标识没有找到待操作的目标应用
 * @property NO_TARGET_APP
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsError.NO_TARGET_APP = 4;
/**
 * 应用包中的配置文件不存在
 * @property NO_APP_CONFIG_FILE
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */       
AmsError.NO_APP_CONFIG_FILE = 5;  
/**
 * 未知错误
 * @property UNKNOWN
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */       
AmsError.UNKNOWN = 7;              

module.exports = AmsError;

});

// file: lib/common/extension/AmsOperationType.js
define("xFace/extension/AmsOperationType", function(require, exports, module) {

/**
 * 该类定义了AMS的操作类型，相关用法参考{{#crossLink "AMS"}}{{/crossLink}} （Android, iOS）<br/>
 * @class AmsOperationType
 * @static
 * @platform Android,iOS
 * @since 3.0.0
 */
function AmsOperationType(type) {
 /**
  * AMS的操作类型，用于表示当前操作类型(Android, iOS)<br/>
  * 其取值范围参考{{#crossLink "AmsOperationType"}}{{/crossLink}}中定义的常量
  * @example
        function errorCallback(error) {
            if( error.type == AmsOperationType.INSTALL) {
                console.log("Package install operation error!");
            }
        }
  * @property type
  * @type Number
  * @platform Android, iOS
  * @since 3.0.0
  */
  this.type = type || null;
}

// ams error codes

/**
 * 应用安装操作
 * @property INSTALL
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsOperationType.INSTALL = 1;

/**
 * 应用更新操作
 * @property UPDATE
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsOperationType.UPDATE =  2;

/**
 * 应用卸载操作
 * @property UNINSTALL
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */

AmsOperationType.UNINSTALL = 3;

module.exports = AmsOperationType;

});

// file: lib/common/extension/AmsState.js
define("xFace/extension/AmsState", function(require, exports, module) {
 
/**
 * 该类定义了AMS在安装过程的状态信息，相关用法参考{{#crossLink "AMS"}}{{/crossLink}}（Android, iOS）<br/>
 * @class AmsState
 * @static
 * @platform Android,iOS
 * @since 3.0.0
 */
function AmsState(state) {
/**
 * 安装的状态码，用于表示具体应用安装的状态(Android, iOS)<br/>
 * 其取值范围参考{{#crossLink "AmsState"}}{{/crossLink}}中定义的常量
 * @example
        function stateChange(amsstate) {
            if( amsstate.code ==AmsState.INSTALL_INSTALLING) {
            print("the application is installing");
            }
        }
 * @property code
 * @type Number
 * @platform Android, iOS
 * @since 3.0.0
 */
  this.code = state || null;
}
/**
 * 安装初始化
 * @property INSTALL_INITIALIZE
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsState.INSTALL_INITIALIZE          = 0;   
/**
 * 应用正在安装
 * @property INSTALL_INSTALLING 
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsState.INSTALL_INSTALLING          = 1;   
/**
 * 正在写配置文件
 * @property INSTALL_WRITE_CONFIGURATION
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsState.INSTALL_WRITE_CONFIGURATION = 2;   
/**
 * 应用安装完成
 * @property INSTALL_FINISHED 
 * @type Number
 * @final
 * @platform Android,iOS
 * @since 3.0.0
 */
AmsState.INSTALL_FINISHED            =  3;

module.exports = AmsState;

});

// file: lib/common/extension/BarcodeScanner.js
define("xFace/extension/BarcodeScanner", function(require, exports, module) {

 /**
  * BarcodeScanner扩展提供条形码扫描的功能（Android, iOS）<br/>
  * 该类不能通过new来创建相应的对象，只能通过xFace.BarcodeScanner对象来直接使用该类中定义的方法
  * @class BarcodeScanner
  * @static
  * @platform Android, iOS
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
function BarcodeScanner(){}

/**
 * 启动条形码扫描器（Android, iOS）<br/>
 * 该方法通过异步方式尝试扫描条形码。如果扫描成功，成功回调被调用并传回barcode的字符串；否则失败回调被调用。
  @example
      function start() {
          xFace.BarcodeScanner.start(success, fail);
      }
      function success(barcode) {
          alert(barcode);
          alert("success");
      }
      function fail() {
          alert("fail to scanner barcode" );
      }
 * @method start
 * @param {Function} successCallback   成功回调函数
 * @param {String} successCallback.barcode 扫描码结果
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
BarcodeScanner.prototype.start = function(successCallback, errorCallback){
    argscheck.checkArgs('fF', 'BarcodeScanner.start', arguments);
    exec(successCallback, errorCallback, null, "BarcodeScanner", "start", []);
};
module.exports = new BarcodeScanner();
});

// file: lib/common/extension/Calendar.js
define("xFace/extension/Calendar", function(require, exports, module) {

/**
 * calendar模块提供时间和日期的选取
 * @module ui
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 此类提供系统原生ui控件支持.此类不能通过new来创建相应的对象,只能通过xFace.ui.Calendar
 * 对象来直接使用该类中定义的方法(Android,iOS)
 * @class Calendar
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
function Calendar() {}

/**定义时间的一些常量*/
var MAX_YEARS    = 2100;
var MAX_MONTHS   = 12;
var MAX_DAYS     = 31;
var MAX_HOURS    = 23;
var MAX_MINUTES  = 59;
var MIN_YEARS    = 1900;
var MIN_MONTHS   = 1;
var MIN_DAYS     = 1;
var MIN_HOURS    = 0;
var MIN_MINUTES  = 0;

/**
 * 打开原生时间控件.可以指定控件显示的初始时间,如果用户不传入初始时间，则默认为当前系统时间.(Android,iOS)
 * 注意：初始时间要么不传，要么全传，否则会报错。
 * @example
        //通过Calendar控件获取用户选取的时间
        function getTime(){
            xFace.ui.Calendar.getTime(
                function(res){
                    alert(res.hour);
                    alert(res.minute);
                },
                function(){alert(" Calendar fail!");}
                );
        }
 * @method getTime
 * @param {Function} successCallback   成功的回调函数，返回用户设置的时间.
 * @param {Object}  successCallback.obj  回调函数的参数为一个带有hour,minute属性的Object对象
 * @param {Function} [errorCallback]     失败的回调函数
 * @param {Number} [hours]   初始小时值(iOS上不支持传参初始化Calendar控件,默认显示系统当前的时间)
 * @param {Number} [minutes] 初始分钟值(iOS上不支持传参初始化,不需要该参数）
 * @platform Android,iOS
 * @since 3.0.0
 */
Calendar.prototype.getTime = function(successCallback, errorCallback, hours, minutes) {
    argscheck.checkArgs('fFNN', 'Calendar.getTime', arguments);
    if(arguments.length == 3){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback("The parameter length is invalid! ");
            return;
        }
    }
    var checkTime = function(hour, minute) {
        if((hour < MIN_HOURS) || (minute < MIN_MINUTES) ||
            (hour > MAX_HOURS) || (minute > MAX_MINUTES)){
            return false;
        }
        //实例一个Date对象
        var d = new Date();
        d.setHours(hour);
        d.setMinutes(minute);
        return (d.getHours() == hour &&
        d.getMinutes() == minute);
    };
    var newArguments = [];
    if(arguments.length == 4) {
        if(!checkTime(hours, minutes)){
            if(errorCallback && typeof errorCallback == "function") {
                errorCallback("The parameter value is invalid! ");
                return;
            }
        } else {
            newArguments = [hours, minutes];
        }
    }
    exec(successCallback, errorCallback, null, "Calendar", "getTime", newArguments);
}

/**
 * 打开原生日期控件。可以指定控件显示的初始日期,如果用户不传入初始日期，则默认为当前系统日期.(Android,iOS)
 * 注意：初始日期要么不传，要么全传，否则会报错。
 * @example
        //通过Calendar控件获取用户选取的日期
        function getDate(){
            xFace.ui.Calendar.getDate(
                function(res){
                    alert(res.year);
                    alert(res.month);
                    alert(res.day);
                },
                function(){alert(" Calendar fail!");}
                    2012,09,10 );
        }

 * @method getDate
 * @param {Function} successCallback   成功回调函数，返回用户设置的日期.
 * @param {Object}  successCallback.obj  回调函数的参数为一个带有year,month,day属性的Object对象
 * @param {Function} [errorCallback]      失败回调函数
 * @param {Number} [year]    初始年值(iOS上不支持传参初始化Calendar控件,默认显示系统当前的日期)
 * @param {Number} [month]   初始月份值(iOS上不支持传参初始化,不需要该参数)
 * @param {Number} [day]     初始日值(iOS上不支持传参初始化,不需要该参数)
 * @platform Android,iOS
 * @since 3.0.0
 */
Calendar.prototype.getDate = function(successCallback, errorCallback, year, month, day) {
    argscheck.checkArgs('fFNNN', 'Calendar.getDate', arguments);
    if(arguments.length != 5 && arguments.length != 2 && arguments.length != 1){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback("The parameter length is invalid! ");
            return;
        }
    }
    var checkDate = function(years, months, days) {
        if((years < MIN_YEARS) || (months < MIN_MONTHS) || (days < MIN_DAYS) ||
            (years > MAX_YEARS) || (months > MAX_MONTHS) || (days > MAX_DAYS) ){
            return false;
        }
        //实例一个Date对象并初始化各个属性值，注意月份是从0开始，因此减1
        var d = new Date(years, months-1, days);
        //判断输入时期是否合法 ，同样月份需要加1
        return (d.getFullYear() == years
           && d.getMonth()+1 == months
           && d.getDate()== days);
    };
    var newArguments = [];
    if(arguments.length == 5) {
        if(!checkDate(year,month,day)){
            if(errorCallback && typeof errorCallback == "function") {
                errorCallback("The parameter value is invalid! ");
                return;
            }
        } else {
            newArguments = [year, month, day];
        }
    }

    exec(successCallback, errorCallback, null, "Calendar", "getDate",newArguments);
}

module.exports = new Calendar();

});

// file: lib/common/extension/Camera.js
define("xFace/extension/Camera", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    Camera = require('xFace/extension/CameraConstants');

/**
 * 该类定义了图像采集的相关接口（Android, iOS）<br/>
 * 该类不能通过new来创建相应的对象，只能通过navigator.camera对象来直接使用该类中定义的方法<br/>
 * @class Camera
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
var cameraExport = {};

// Tack on the Camera Constants to the base camera plugin.
for (var key in Camera) {
    cameraExport[key] = Camera[key];
}

/**
 * 根据"options.sourceType"从 source中获取一张图片,并根据"options.destinationType"
 * 决定返回图片的结果（Android, iOS）
 * @example
        navigator.camera.getPicture(onSuccess, onFail, { quality: 50,
        destinationType: Camera.DestinationType.FILE_URI,
        sourceType: Camera.PictureSourceType.CAMERA,
        targetWidth: 260,
        targetHeight: 200});

 * @method getPicture
 * @param {Function} successCallback 成功回调方法
 * @param {String} successCallback.data options.destinationType为DATA_URL返回base64编码的数据；<br/>options.destinationType为FILE_URI返回文件url
 * @param {Function} [errorCallback] 失败回调方法
 * @param {String} errorCallback.msg 错误信息
 * @param {Object} [options] 可选参数<br/>
 * @param {Number} options.quality    图像质量(0-100)，iOS设置在50 以下，避免在一些设备上出现内存错误
 * @param {Number} options.destinationType    目标图像的数据类型,取值范围参见{{#crossLink "Camera.DestinationType"}}{{/crossLink}}
 * @param {Number} options.sourceType    图像资源类型,取值范围参见{{#crossLink "Camera.PictureSourceType"}}{{/crossLink}}
 * @param {Boolean} options.allowEdit    是否允许编辑，Android不支持
 * @param {Number} options.encodingType  编码类型，Android不支持，取值范围参见{{#crossLink "Camera.EncodingType"}}{{/crossLink}}
 * @param {Number} options.targetWidth   图像宽度
 * @param {Number} options.targetHeight  图像高度
 * @param {Number} options.mediaType     媒体文件类型，取值范围参见{{#crossLink "Camera.MediaType"}}{{/crossLink}}
 * @param {Boolean} options.saveToPhotoAlbum    图像是否保存到设备的相册
 * @platform Android, iOS
 * @since 3.0.0
 */
cameraExport.getPicture = function(successCallback, errorCallback, options) {
    argscheck.checkArgs('fFO', 'camera.getPicture', arguments);
    var quality = 50;
    if (options && typeof options.quality == "number") {
        quality = options.quality;
    } else if (options && typeof options.quality == "string") {
        var qlity = parseInt(options.quality, 10);
        if (isNaN(qlity) === false) {
            quality = qlity.valueOf();
        }
    }

    var destinationType = Camera.DestinationType.FILE_URI;
    if (typeof options.destinationType == "number") {
        destinationType = options.destinationType;
    }

    var sourceType = Camera.PictureSourceType.CAMERA;
    if (typeof options.sourceType == "number") {
        sourceType = options.sourceType;
    }

    var targetWidth = -1;
    if (typeof options.targetWidth == "number") {
        targetWidth = options.targetWidth;
    } else if (typeof options.targetWidth == "string") {
        var width = parseInt(options.targetWidth, 10);
        if (isNaN(width) === false) {
            targetWidth = width.valueOf();
        }
    }

    var targetHeight = -1;
    if (typeof options.targetHeight == "number") {
        targetHeight = options.targetHeight;
    } else if (typeof options.targetHeight == "string") {
        var height = parseInt(options.targetHeight, 10);
        if (isNaN(height) === false) {
            targetHeight = height.valueOf();
        }
    }

    var encodingType = Camera.EncodingType.JPEG;
    if (typeof options.encodingType == "number") {
        encodingType = options.encodingType;
    }

    var mediaType = Camera.MediaType.PICTURE;
    if (typeof options.mediaType == "number") {
        mediaType = options.mediaType;
    }
    var allowEdit = false;
    if (typeof options.allowEdit == "boolean") {
        allowEdit = options.allowEdit;
    } else if (typeof options.allowEdit == "number") {
        allowEdit = options.allowEdit <= 0 ? false : true;
    }
    var correctOrientation = false;
    if (typeof options.correctOrientation == "boolean") {
        correctOrientation = options.correctOrientation;
    } else if (typeof options.correctOrientation == "number") {
        correctOrientation = options.correctOrientation <=0 ? false : true;
    }
    var saveToPhotoAlbum = false;
    if (typeof options.saveToPhotoAlbum == "boolean") {
        saveToPhotoAlbum = options.saveToPhotoAlbum;
    } else if (typeof options.saveToPhotoAlbum == "number") {
        saveToPhotoAlbum = options.saveToPhotoAlbum <=0 ? false : true;
    }
   /**
    * @param options 获取图片的参数
    * - 0 NSString* callbackId
    * - 1 quality 压缩质量百分比
    * - 2 destinationType 目标结果的类型
    * - 3 sourceType 图像来源;如 相片库/照相机/保存的相片
    * - 4 targetWidth 目标尺寸宽度
    * - 5 targetHeight 目标尺寸高度
    * - 6 encodingType 编码格式
    * - 7 mediaType 媒体类型
    * - 8 allowEdit 是否允许编辑
    * - 9 correctOrientation 正确的方向
    * - 10 saveToPhotoAlbum 保存到相册
    */
   exec(successCallback, errorCallback, null, "Camera", "takePicture", [quality, destinationType, sourceType, targetWidth, targetHeight, encodingType, mediaType, allowEdit, correctOrientation, saveToPhotoAlbum]);
};

module.exports = cameraExport;
});

// file: lib/common/extension/CameraConstants.js
define("xFace/extension/CameraConstants", function(require, exports, module) {


module.exports = {
  /**
   * 该类定义一些常量，用于标识camera的目标图像的数据类型（Android, iOS）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class DestinationType
   * @namespace Camera
   * @static
   * @platform Android, iOS
   * @since 3.0.0
   */
  DestinationType:{
   /**
    * base64编码格式的数据（Android, iOS）
    * @property DATA_URL
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    DATA_URL: 0,         // Return base64 encoded string
    /**
    * 文件url（iOS）
    * @property FILE_URI
    * @type Number
    * @final
    * @platform iOS
    * @since 3.0.0
    */
    FILE_URI: 1,          // Return file uri (content://media/external/images/media/2 for Android)
    /**
    * 本地url（Android）
    * @property NATIVE_URI
    * @type Number
    * @final
    * @platform Android
    * @since 3.0.0
    */
    NATIVE_URI: 2
  },
  /**
   * 该类定义一些常量，用于标识camera的目标图像的编码类型（iOS）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class EncodingType
   * @namespace Camera
   * @static
   * @platform iOS
   * @since 3.0.0
   */
  EncodingType:{
  /**
    * 图片为JPEG格式（iOS）
    * @property JPEG
    * @type Number
    * @final
    * @platform iOS
    * @since 3.0.0
    */
    JPEG: 0,             // Return JPEG encoded image
  /**
    * 图片为PNG格式（iOS）
    * @property PNG
    * @type Number
    * @final
    * @platform iOS
    * @since 3.0.0
    */
    PNG: 1               // Return PNG encoded image
  },
  /**
   * 该类定义一些常量，用于标识camera的媒体文件类型（Android, iOS）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class MediaType
   * @namespace Camera
   * @static
   * @platform Android, iOS
   * @since 3.0.0
   */
  MediaType:{
  /**
    * 照片（Android, iOS）
    * @property PICTURE
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    PICTURE: 0,          // allow selection of still pictures only. DEFAULT. Will return format specified via DestinationType
    /**
    * 视频（Android, iOS）
    * @property VIDEO
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    VIDEO: 1,            // allow selection of video only, ONLY RETURNS URL
    /**
    * 所有媒体类型（Android, iOS）
    * @property ALLMEDIA
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    ALLMEDIA : 2         // allow selection from all media types
  },
  /**
   * 该类定义一些常量，用于标识camera的图片源类型（Android, iOS）<br/>
   * 相关参考： {{#crossLink "Camera"}}{{/crossLink}}
   * @class PictureSourceType
   * @namespace Camera
   * @static
   * @platform Android, iOS
   * @since 3.0.0
   */
  PictureSourceType:{
    /**
    * 从图片库选择图片（Android, iOS）
    * @property PHOTOLIBRARY
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    PHOTOLIBRARY : 0,    // Choose image from picture library (same as SAVEDPHOTOALBUM for Android)
    /**
    * 调用设备摄像头照相采集照片（Android, iOS）
    * @property CAMERA
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    CAMERA : 1,          // Take picture from camera
    /**
    * 从相册选择图片，（Android平台上，与PHOTOLIBRARY等效）（Android, iOS）
    * @property SAVEDPHOTOALBUM
    * @type Number
    * @final
    * @platform Android, iOS
    * @since 3.0.0
    */
    SAVEDPHOTOALBUM : 2  // Choose image from picture library (same as PHOTOLIBRARY for Android)
  }
};
});

// file: lib/common/extension/CaptureAudioOptions.js
define("xFace/extension/CaptureAudioOptions", function(require, exports, module) {

 /**
  * 该类封装了音频采集功能的配置选项（Android, iOS）<br/>
  * @class CaptureAudioOptions
  * @constructor
  * @platform Android, iOS
  * @since 3.0.0
  */
var CaptureAudioOptions = function(){
    /**
     * 在单个采集操作期间能够记录的音频剪辑数量最大值，必须设定为大于等于1(Android)<br/>
     * @example
            var options = new CaptureAudioOptions();
            options.limit = 3;
            navigator.device.capture.captureAudio(captureSuccess, captureError, options);
     * @property limit
     * @type Number
     * @default 1
     * @platform Android
     * @since 3.0.0
     */
    this.limit = 1;
    /**
     * 一个音频剪辑的最长时间（以毫秒为单位）(iOS)
     * @example
            var options = new CaptureAudioOptions();
            options.duration = 10;
            navigator.device.capture.captureAudio(captureSuccess, captureError, options);
     * @property duration
     * @type Number
     * @default 0
     * @platform iOS
     * @since 3.0.0
     */
    this.duration = 0;
    /**
     * 选定的音频模式（两个平台都不支持）<br/>
     */
     // TODO: 支持capture.supportedAudioModes
    this.mode = null;
};

module.exports = CaptureAudioOptions;
});

// file: lib/common/extension/CaptureError.js
define("xFace/extension/CaptureError", function(require, exports, module) {

 /**
  * 用于描述多媒体采集时产生的错误（Android, iOS）<br/>
  * @class CaptureError
  * @platform Android, iOS
  * @since 3.0.0
  */
var CaptureError = function(c) {
   /**
      * 错误码，用于标识具体的错误类型(Android, iOS)
      * @example
             function errorCallback(error) {
                 var msg = 'An error occurred during capture: ' + getErrorMsg(error.code);
                 console.log(msg);
             }
             var getErrorMsg = function(code){
                if(code == CaptureError.CAPTURE_INTERNAL_ERR){
                    return "capture internal error";
                } else if(code == CaptureError.CAPTURE_APPLICATION_BUSY){
                    return "capture application busy";
                }else if(code == CaptureError.CAPTURE_INVALID_ARGUMENT){
                    return "capture invalid argument";
                }else if(code == CaptureError.CAPTURE_NO_MEDIA_FILES){
                    return "capture no media files";
                }else if(code == CaptureError.CAPTURE_NOT_SUPPORTED){
                    return "capture not supported";
                }
                return "";
            }
      * @property code
      * @default null
      * @type Number
      * @platform Android, iOS
      * @since 3.0.0
      */
   this.code = c || null;
};

/**
  * 摄像头/耳机采集图片或声音时失败(Android, iOS)
  * @example
         CaptureError.CAPTURE_INTERNAL_ERR 
  * @property CAPTURE_INTERNAL_ERR
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_INTERNAL_ERR = 0;
/**
  * 摄像头/音频采集程序正在处理别的采集请求(Android, iOS)
  * @example
         CaptureError.CAPTURE_APPLICATION_BUSY 
  * @property CAPTURE_APPLICATION_BUSY
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_APPLICATION_BUSY = 1;
/**
  * api的调用方式不对(例如：limit 参数的值小于1)(Android, iOS)
  * @example
         CaptureError.CAPTURE_INVALID_ARGUMENT 
  * @property CAPTURE_INVALID_ARGUMENT
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_INVALID_ARGUMENT = 2;
/**
  * 在采集到任何信息之前用户退出了摄像头/音频采集程序(Android, iOS)
  * @example
         CaptureError.CAPTURE_NO_MEDIA_FILES 
  * @property CAPTURE_NO_MEDIA_FILES
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_NO_MEDIA_FILES = 3;
/**
  * 设备不支持该采集操作(Android, iOS)
  * @example
         CaptureError.CAPTURE_NOT_SUPPORTED 
  * @property CAPTURE_NOT_SUPPORTED
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CaptureError.CAPTURE_NOT_SUPPORTED = 20;

module.exports = CaptureError;

});

// file: lib/common/extension/CaptureImageOptions.js
define("xFace/extension/CaptureImageOptions", function(require, exports, module) {

 /**
  * 该类封装了图像采集功能的配置选项（Android）<br/>
  * @class CaptureImageOptions
  * @constructor
  * @platform Android
  * @since 3.0.0
  */
var CaptureImageOptions = function(){
    /**
     * 在单个采集操作期间能够记录的图像剪辑数量最大值，必须设定为大于等于1(Android)<br/>
     * @example
            var options = new CaptureImageOptions();
            options.limit = 3;
            navigator.device.capture.captureImage(captureSuccess, captureError, options);
     * @property limit
     * @type Number
     * @default 1
     * @platform Android
     * @since 3.0.0
     */
    this.limit = 1;
    /**
     * 选定的音频模式（两个平台都不支持）<br/>
     */
     // TODO: 支持capture.supportedImageModes
    this.mode = null;
};

module.exports = CaptureImageOptions;
});

// file: lib/common/extension/CaptureVideoOptions.js
define("xFace/extension/CaptureVideoOptions", function(require, exports, module) {

 /**
  * 该类封装了视频采集功能的配置选项（Android）<br/>
  * @class CaptureVideoOptions
  * @constructor
  * @platform Android
  * @since 3.0.0
  */
var CaptureVideoOptions = function(){
    /**
     * 在单个采集操作期间能够记录的视频剪辑数量最大值，必须设定为大于等于1(Android)<br/>
     * @example
            var options = new CaptureVideoOptions();
            options.limit = 3;
            navigator.device.capture.captureVideo(captureSuccess, captureError, options);
     * @property limit
     * @type Number
     * @default 1
     * @platform Android
     * @since 3.0.0
     */
    this.limit = 1;
    /**
     * 一个视频剪辑的最长时间（以毫秒为单位）(Android)
     * @example
            var options = new CaptureVideoOptions();
            options.duration = 10;
            navigator.device.capture.captureVideo(captureSuccess, captureError, options);
     * @property duration
     * @type Number
     * @default 0
     * @platform Android
     * @since 3.0.0
     */
    this.duration = 0;
    /**
     * 选定的视频模式（两个平台都不支持）<br/>
     */
     // TODO: 支持capture.supportedVideoModes
    this.mode = null;
};

module.exports = CaptureVideoOptions;
});

// file: lib/common/extension/CompassError.js
define("xFace/extension/CompassError", function(require, exports, module) {
 
 /**
 * 用于描述获取指南针信息时产生的错误（Android, iOS）<br/>
 * @class CompassError
 * @platform Android, iOS
 * @since 3.0.0
 */
var CompassError = function(err) {
    /**
      * 错误码，用于标识具体的错误类型 (Android, iOS).
      * @example
             var fail = function(error){
                console.log("getCompass fail callback with error code " + getErrorMsg(error.code));
             var getErrorMsg = function(code){
                if(code == CompassError.COMPASS_INTERNAL_ERR){
                    return "COMPASS_INTERNAL_ERR";
                } else if(code == CompassError.COMPASS_NOT_SUPPORTED){
                    return "COMPASS_NOT_SUPPORTED";
                }
                return "";
            } 
      * @property code
      * @default null
      * @type Number
      * @platform Android, iOS
      * @since 3.0.0
      */
    this.code = (err !== undefined ? err : null);
};

/**
  * 设备内部错误 (Android, iOS).
  * @example
         CompassError.COMPASS_INTERNAL_ERR 
  * @property COMPASS_INTERNAL_ERR
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CompassError.COMPASS_INTERNAL_ERR = 0;

/**
  * 不支持compass (Android, iOS).
  * @example
         CompassError.COMPASS_NOT_SUPPORTED 
  * @property COMPASS_NOT_SUPPORTED
  * @type Number
  * @final
  * @platform Android, iOS
  * @since 3.0.0
  */
CompassError.COMPASS_NOT_SUPPORTED = 20;

module.exports = CompassError;
});

// file: lib/common/extension/CompassHeading.js
define("xFace/extension/CompassHeading", function(require, exports, module) {

/**
 * 用于描述获取的指南针信息（Android, iOS）<br/>
 * 由于磁场北极和地理北极有差别，就产生了磁差，地面和地图上是以真正的北极南极为基准的，而真航向指的是从地理北极顺时针转到当前位置的夹角，
 * 磁航向指的是从磁场北极顺时针转到当前位置的夹角，磁差就是真航向和磁航向之间的偏差<br/>
 * 在IOS系统版本高于4.0的设备上，如果设备旋转且应用支持该方向，则将返回相对于该方向的指南针朝向值
 * @class CompassHeading
 * @platform Android, iOS
 * @since 3.0.0
 */
var CompassHeading = function(magneticHeading, trueHeading, headingAccuracy, timestamp) {
  /**
   * 指南针的磁航向信息（从磁场北极顺时针转的夹角），单位度，取值范围0~359.99度(Android, iOS)
   * @example
          var success = function(heading){
              console.log("The heading in degree is: " + heading.magneticHeading);
          };
   * @property magneticHeading
   * @default null
   * @type Number
   * @platform Android, iOS
   * @since 3.0.0
   */
  this.magneticHeading = (magneticHeading !== undefined ? magneticHeading : null);
  /**
   * 指南针的真航向信息（从地理北极顺时针转的夹角），单位度，取值范围0~359.99度，如为负值则表明该参数不确定 (iOS)<br/>
   * 在iOS下，仅在位置定位服务开启的情况下才有效
   * @example
          var success = function(heading){
              console.log("The heading relative to the geographic North Pole is: " + heading.magneticHeading);
          };
   * @property trueHeading
   * @default null
   * @type Number
   * @platform iOS
   * @since 3.0.0
   */
  this.trueHeading = (trueHeading !== undefined ? trueHeading : null);
  /**
   * 真航向和磁航向之间的偏差，单位度，取值范围是0-359.99度(Android, iOS)<br/>
   * 在Android下，headingAccuracy的值始终为0
   * @example
          var success = function(heading){
             console.log("The deviation in degrees between the reported heading and the true heading is: " 
                    + heading.headingAccuracy);
          };
   * @property headingAccuracy
   * @default null
   * @type Number
   * @platform Android, iOS
   * @since 3.0.0
   */
  this.headingAccuracy = (headingAccuracy !== undefined ? headingAccuracy : null);
  /**
   * 获取指南针方向信息时的时间（距1970年1月1日之间的毫秒数） (Android, iOS)
   * @example
          var success = function(heading){
              console.log("The time at which this heading was determined is: " 
                    + heading.timestamp);
          };
   * @property timestamp
   * @default 1970年1月1日至今的毫秒数
   * @type Number
   * @platform Android, iOS
   * @since 3.0.0
   */
  this.timestamp = (timestamp !== undefined ? timestamp : new Date().getTime());
};

module.exports = CompassHeading;
});

// file: lib/common/extension/CompassOptions.js
define("xFace/extension/CompassOptions", function(require, exports, module) {
 
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
});

// file: lib/common/extension/ConfigurationData.js
define("xFace/extension/ConfigurationData", function(require, exports, module) {
function ConfigurationData() {
    // 小写的ASCII编码字符串，表示多媒体类型
    this.type = null;
    // height 属性表示图片或者视频的高度（像素）
    // 如果是音频，此属性为0
    this.height = 0;
    // width 属性表示图片或者视频的宽度（像素）
    // 如果是音频，此属性为0
    this.width = 0;
}

module.exports = ConfigurationData;
});

// file: lib/common/extension/Connection.js
define("xFace/extension/Connection", function(require, exports, module) {

/**
 * 定义网络连接类型常量 (Android, iOS).<br>
 * 相关参考： {{#crossLink "navigator.network.Connection"}}{{/crossLink}}
 * @class Connection
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
module.exports = {
        /**
        * 当前网络连接类型未知 (Android, iOS).
        * @example
              Connection.UNKNOWN
        * @property UNKNOWN
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        UNKNOWN: "unknown",
        /**
        * 当前网络连接类型为以太网 (Android, iOS).
        * @example
              Connection.ETHERNET
        * @property ETHERNET
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        ETHERNET: "ethernet",
        /**
        * 当前网络连接类型为wifi (Android, iOS).
        * @example
              Connection.WIFI
        * @property WIFI
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        WIFI: "wifi",
        /**
        * 当前网络连接类型为2g (Android, iOS).
        * @example
              Connection.CELL_2G
        * @property CELL_2G
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        CELL_2G: "2g",
        /**
        * 当前网络连接类型为3g (Android, iOS).
        * @example
              Connection.CELL_3G
        * @property CELL_3G
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        CELL_3G: "3g",
        /**
        * 当前网络连接类型为4g (Android, iOS).
        * @example
              Connection.CELL_4G
        * @property CELL_4G
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        CELL_4G: "4g",
        /**
        * 当前无网络连接 (Android, iOS).
        * @example
              Connection.NONE
        * @property NONE
        * @type String
        * @final
        * @platform Android, iOS
        * @since 3.0.0
        */
        NONE: "none"
};

});

// file: lib/common/extension/Contact.js
define("xFace/extension/Contact", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/extension/privateModule').getExecV2(),
    ContactError = require('xFace/extension/ContactError'),
    utils = require('xFace/utils');

/**
 * 将原始数据转换为复杂对象.
 * 当前仅应用于 Data 域
 * @param  contact  需要进行转换的 contact 信息
 */
function convertIn(contact) {
    var value = contact.birthday;
    try {
      contact.birthday = new Date(parseFloat(value));
    } catch (exception){
      console.log("xFace Contact convertIn error: exception creating date.");
    }
    return contact;
}

/**
 * 将复杂对象转换为原始数据，与 convertIn 对应
 * 当前仅应用于 Data 域
 * @param  contact  需要进行转换的 contact 信息
 */
function convertOut(contact) {
    var value = contact.birthday;
    if (value !== null) {
        // 如果 birthday 还不是一个 Data 对象，则将其生成
        if (!(value instanceof Date)){
            try {
                value = new Date(value);
            } catch(exception){
                value = null;
            }
        }

        if (value instanceof Date){
            value = value.valueOf(); // 转换为 milliseconds
        }

        contact.birthday = value;
    }
    return contact;
}

/**
 * 该类定义了单个联系人的一系列属性及方法（Android, iOS）<br/>
 * 相关参考： {{#crossLink "ContactField"}}{{/crossLink}},{{#crossLink "ContactAddress"}}{{/crossLink}},{{#crossLink "ContactName"}}{{/crossLink}},{{#crossLink "ContactOrganization"}}{{/crossLink}}
 * @class Contact
 * @constructor
 * @param {String} [id=null] 唯一标识符，仅在 Native端设置
 * @param {String} [displayName=null] 联系人显示名称
 * @param {ContactName} [name=null] 联系人全名
 * @param {String} [nickname=null] 昵称
 * @param {ContactField[]} [phoneNumbers=null] 电话号码
 * @param {ContactField[]} [emails=null] email地址
 * @param {ContactAddress[]} [addresses=null] 联系地址
 * @param {ContactField[]} [ims=null] 即时通讯id号
 * @param {ContactOrganization[]} [organizations=null] 所属组织
 * @param {String} [birthday=null] 生日
 * @param {String} [note=null] 用户对此联系人的备注
 * @param {ContactField[]} [photos=null] 照片
 * @param {ContactField[]} [categories=null]  用户自定义类别
 * @param {ContactField[]} [urls=null] 联系人的网站
 * @platform Android, iOS
 * @since 3.0.0
 */
var Contact = function (id, displayName, name, nickname, phoneNumbers, emails, addresses,
    ims, organizations, birthday, note, photos, categories, urls) {
    /**
     * 唯一标识符
     */
    this.id = id || null;

    this.rawId = null;
    /**
     * 联系人显示名称，适合向最终用户展示的联系人名称（Android, iOS）
     * @property displayName
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.displayName = displayName || null;
    /**
     * 联系人全名（Android, iOS）
     * @property name
     * @type ContactName
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.name = name || null; // ContactName
    /**
     * 昵称（Android, iOS）
     * @property nickname
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.nickname = nickname || null;
    /**
     * 电话号码（Android, iOS）
     * @property phoneNumbers
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.phoneNumbers = phoneNumbers || null; // ContactField[]
    /**
     * email地址（Android, iOS）
     * @property emails
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.emails = emails || null; // ContactField[]
    /**
     * 联系地址（Android, iOS）
     * @property addresses
     * @type ContactAddress[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.addresses = addresses || null; // ContactAddress[]
    /**
     * IM地址（Android, iOS）
     * @property ims
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.ims = ims || null; // ContactField[]
    /**
     * 所有所属组织（Android, iOS）
     * @property organizations
     * @type ContactOrganization[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.organizations = organizations || null; // ContactOrganization[]
    /**
     * 生日（Android, iOS）
     * @property birthday
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.birthday = birthday || null;
    /**
     * 用户对此联系人的备注（Android, iOS）
     * @property note
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.note = note || null;
    /**
     * 照片（Android, iOS）
     * @property photos
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.photos = photos || null; // ContactField[]
    /**
     * 用户自定义类别（Android, iOS）
     * @property categories
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.categories = categories || null; // ContactField[]
    /**
     * 相关网页（Android, iOS）
     * @property urls
     * @type ContactField[]
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.urls = urls || null; // ContactField[]
};

/**
 * 从设备存储中清除联系人（Android, iOS）<br/>
 * @example
        function onSuccess() {
            alert("Removal Success");   };

        function onError(contactError) {
            alert("Error = " + contactError.code);   };

        // remove the contact from the device
        contact.remove(onSuccess,onError);

 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @param {ContactError} errorCallback.error   错误码
 * @platform Android, iOS
 * @since 3.0.0
 */
Contact.prototype.remove = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'Contact.remove', arguments);
    
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new ContactError(code));
    };

    if (this.id === null) {
        fail(ContactError.UNKNOWN_ERROR);
    }
    else {
        exec(successCallback, fail, null, "Contacts", "remove", [this.id]);
    }
};

/**
 * 创建一个联系人的深拷贝.域中的 Id 均设置为 null.（Android, iOS）<br/>
 * @example
        var contact = navigator.contacts.create();
        var name = new ContactName();
        name.givenName = "Jane";
        name.familyName = "Doe";
        contact.name = name;

        var clone = contact.clone();
        clone.name.givenName = "John";
        console.log("Original contact name = " + contact.name.givenName);
        console.log("Cloned contact name = " + clone.name.givenName);

 * @method clone
 * @return {Contact}  拷贝成功后的一个新的Contact对象.
 * @platform Android, iOS
 * @since 3.0.0
 */
Contact.prototype.clone = function() {
    var clonedContact = utils.clone(this);
    var i;
    clonedContact.id = null;
    clonedContact.rawId = null;
    // 遍历并清空所有域中的 id
    if (clonedContact.phoneNumbers) {
        for (i = 0; i < clonedContact.phoneNumbers.length; i++) {
            clonedContact.phoneNumbers[i].id = null;
        }
    }
    if (clonedContact.emails) {
        for (i = 0; i < clonedContact.emails.length; i++) {
            clonedContact.emails[i].id = null;
        }
    }
    if (clonedContact.addresses) {
        for (i = 0; i < clonedContact.addresses.length; i++) {
            clonedContact.addresses[i].id = null;
        }
    }
    if (clonedContact.ims) {
        for (i = 0; i < clonedContact.ims.length; i++) {
            clonedContact.ims[i].id = null;
        }
    }
    if (clonedContact.organizations) {
        for (i = 0; i < clonedContact.organizations.length; i++) {
            clonedContact.organizations[i].id = null;
        }
    }
    if (clonedContact.categories) {
        for (i = 0; i < clonedContact.categories.length; i++) {
            clonedContact.categories[i].id = null;
        }
    }
    if (clonedContact.photos) {
        for (i = 0; i < clonedContact.photos.length; i++) {
            clonedContact.photos[i].id = null;
        }
    }
    if (clonedContact.urls) {
        for (i = 0; i < clonedContact.urls.length; i++) {
            clonedContact.urls[i].id = null;
        }
    }
    return clonedContact;
};

/**
 * 保存联系人信息到设备存储中（Android, iOS）<br/>
 * @example
        function onSuccess(contact) {
            alert("Save Success");   };

        function onError(contactError) {
            alert("Error = " + contactError.code);   };

        // create a new contact object
        var contact = navigator.contacts.create();
        contact.displayName = "Plumber";
        contact.nickname = "Plumber";

        // populate some fields
        var name = new ContactName();
        name.givenName = "Jane";
        name.familyName = "Doe";
        contact.name = name;

        // save to device
        contact.save(onSuccess,onError);

 * @method save
 * @param {Function} [successCallback] 成功回调函数
 * @param {Contact} successCallback.contact 保存成功的Contact对象
 * @param {Function} [errorCallback]   失败回调函数
 * @param {ContactError} errorCallback.error   错误码
 * @platform Android, iOS
 * @since 3.0.0
 */
Contact.prototype.save = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'Contact.save', arguments);
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new ContactError(code));
    };

    var success = function(result) {
      if (result) {
          if (typeof successCallback === 'function') {
              var fullContact = require('xFace/extension/contacts').create(result);
              successCallback(convertIn(fullContact));
          }
      }
      else {
          fail(ContactError.UNKNOWN_ERROR);
      }
  };
    var dupContact = convertOut(utils.clone(this));
    exec(success, fail, null, "Contacts", "save", [dupContact]);
};

module.exports = Contact;
});

// file: lib/common/extension/ContactAccountType.js
define("xFace/extension/ContactAccountType", function(require, exports, module) {
 
 /**
 * 该类定义一些常量，用于标识联系人项的帐号类型，在定义ContactFindOptions对象时会使用（Android）<br/>
 * 相关参考： {{#crossLink "Contacts"}}{{/crossLink}}，{{#crossLink "ContactFindOptions"}}{{/crossLink}}
 * @class ContactAccountType
 * @example
        var options = new ContactFindOptions();
        options.filter = "Jim";
        options.multiple = true;
        options.accountType = ContactAccountType.SIM;

 * @static
 * @platform Android
 * @since 3.0.0
 */
var ContactAccountType = function() {
};

/**
 * 所有的联系人，包括手机和sim卡等上的联系人（Android）
 * @property All
 * @type String
 * @final
 * @platform Android
 * @since 3.0.0
 */
ContactAccountType.All = "All";
/**
 * 手机自身的联系人信息（Android）
 * @property Phone
 * @type String
 * @final
 * @platform Android
 * @since 3.0.0
 */
ContactAccountType.Phone = "Phone";
/**
 * sim卡上的联系人信息（Android）
 * @property SIM
 * @type String
 * @final
 * @platform Android
 * @since 3.0.0
 */
ContactAccountType.SIM = "SIM";

module.exports = ContactAccountType;
});

// file: lib/common/extension/ContactAddress.js
define("xFace/extension/ContactAddress", function(require, exports, module) {
var ContactAddress = function(pref, type, formatted, streetAddress, locality, region, postalCode, country) {
    /**
     * 唯一标识符
     */
    this.id = null;
    /**
     * 首选项 
     */
    this.pref = (typeof pref != 'undefined' ? pref : false);
    /**
     * 标示该地址对应的类型,包括："work"、"home"、"other"、"custom"（Android, iOS）
     * @property type
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.type = type || null;
    /**
     * 完整的地址,综合 streetAddress、locality、region 和 country 后的全称（Android）
     * @property formatted
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.formatted = formatted || null;
    /**
     * 完整的街道地址（Android, iOS）
     * @property streetAddress
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.streetAddress = streetAddress || null;
    /**
     * 城市或地区（Android, iOS）
     * @property locality
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.locality = locality || null;
    /**
     * 州或省份（Android, iOS）
     * @property region
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
    */
    this.region = region || null;
    /**
     * 邮政编码（Android, iOS）
     * @property postalCode
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.postalCode = postalCode || null;
    /**
     * 国家（Android, iOS）
     * @property country
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.country = country || null;
};

module.exports = ContactAddress;
});

// file: lib/common/extension/ContactError.js
define("xFace/extension/ContactError", function(require, exports, module) {

var ContactError = function(err) {
    /**
     * 错误代码，其取值范围参考ContactError中定义的常量（Android, iOS）
     * @property code
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.code = (typeof err != 'undefined' ? err : null);
};

/**
 * 未知错误（Android, iOS）
 * @property UNKNOWN_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.UNKNOWN_ERROR = 0;
/**
 * 无效参数错误（Android, iOS）
 * @property INVALID_ARGUMENT_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.INVALID_ARGUMENT_ERROR = 1;
/**
 * 请求超时错误（Android, iOS）
 * @property TIMEOUT_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.TIMEOUT_ERROR = 2;
/**
 * 挂起操作错误（Android, iOS）
 * @property PENDING_OPERATION_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.PENDING_OPERATION_ERROR = 3;
/**
 * 输入输出错误（Android, iOS）
 * @property IO_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.IO_ERROR = 4;
/**
 * 平台不支持错误（Android, iOS）
 * @property NOT_SUPPORTED_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.NOT_SUPPORTED_ERROR = 5;
/**
 * 权限被拒绝错误（Android, iOS）
 * @property PERMISSION_DENIED_ERROR
 * @type Number
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ContactError.PERMISSION_DENIED_ERROR = 20;

module.exports = ContactError;
});

// file: lib/common/extension/ContactField.js
define("xFace/extension/ContactField", function(require, exports, module) {

 /**
 * 该类定义联系人的普通属性域，用于支持通用方式的联系人字段。（Android, iOS）<br/>
 * Contact对象的属性phoneNumbers、emails、ims、photos、categories、urls使用此类<br/>
 * 每个ContactField对象都包含一个值属性、一个类型属性和一个首选项属性信息的一系列属性.<br/>
 *  一个Contact对象将多个属性分别存储到多个ContactField[]数组中，例如电话号码与邮件地址等。<br/>
 * 在大多数情况下，ContactField对象中的type属性并没有事先确定值。例如，一个电话号码的type属性值可以是：“home”、“work”、“mobile”或其他相应特定设备平台的联系人数据库所支持的值。<br/>
 * 然而对于Contact对象的photos字段，xFace使用type字段来表示返回的图像格式。如果value属性包含的是一个指向照片图像的URL，xFace对于type会返回“url”；如果value属性包含的是图像的Base64编码字符串，xFace对于type会返回“base64”。<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @example
        // create a new contact
        var contact = navigator.contacts.create();

        // store contact phone numbers in ContactField[]
        var phoneNumbers = [];
        phoneNumbers[0] = new ContactField('work', '212-555-1234', false);
        phoneNumbers[1] = new ContactField('mobile', '917-555-5432', true); // preferred number
        phoneNumbers[2] = new ContactField('home', '203-555-7890', false);
        contact.phoneNumbers = phoneNumbers;

 * @class ContactField
 * @constructor
 * @param {String} [type=null] 字段类型
 * @param {String} [value=null] 字段的值
 * @param {Boolean} [pref=false] 首选项
 * @platform Android, iOS
 * @since 3.0.0
 */
var ContactField = function(type, value, pref) {
    /**
     * 唯一标识符
     */
    this.id = null;
    /**
     * 字段类型, PhoneNumber、Email、IM、URL的type包括："home"、"mobile"、"work"、"other"、"custom" （Android, iOS）
     * @property type
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.type = (type && type.toString()) || null;
    /**
     * 字段的值（Android, iOS）
     * @property value
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.value = (value && value.toString()) || null;
    /**
     * 首选项 
     */
    this.pref = (typeof pref != 'undefined' ? pref : false);
};

module.exports = ContactField;
});

// file: lib/common/extension/ContactFindOptions.js
define("xFace/extension/ContactFindOptions", function(require, exports, module) {
var ContactAccountType = require("xFace/extension/ContactAccountType");

 /**
 * 该类定义查询联系人时的一些选项（Android, iOS）<br/>
 * 相关参考： {{#crossLink "Contacts"}}{{/crossLink}}，{{#crossLink "ContactAccountType"}}{{/crossLink}}
 * @class ContactFindOptions
 * @example
        // specify contact search criteria
        var options = new ContactFindOptions();
        options.filter="";          // empty search string returns all contacts
        options.multiple=true;      // return multiple results
        options.accountType = ContactAccountType.SIM;  // find in sim card
        var fields = ["displayName", "name"];      // return contact.name and displayName field

        // find contacts
        navigator.contacts.find(fields, onSuccess, onError, options);

 * @constructor
 * @param {String} [filter=''] 查找联系人的搜索字符串,持通配符"*"
 * @param {Boolean} [multiple=false] 查找操作是否可以返回多条联系人记录
 * @param {String} [accountType=ContactAccountType.All] 联系人账户类型
 * @platform Android, iOS
 * @since 3.0.0
 */
var ContactFindOptions = function(filter, multiple, accountType) {
    /**
     * 查找联系人的搜索字符串，支持通配符"*"；为空时，返回所有联系人（Android, iOS）
     * @property filter
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.filter = filter || '';
    /**
     * 决定查找操作是否可以返回多条联系人记录（Android, iOS）
     * @property multiple
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.multiple = (typeof multiple != 'undefined' ? multiple : false);
    /**
     * 联系人账户类型，取值范围见{{#crossLink "ContactAccountType"}}{{/crossLink}}（Android）
     * @property accountType
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.accountType = accountType || ContactAccountType.All;
};

module.exports = ContactFindOptions;
});

// file: lib/common/extension/ContactName.js
define("xFace/extension/ContactName", function(require, exports, module) {

 /**
 * 该类定义了联系人姓名的一系列子属性（Android, iOS）<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @class ContactName
 * @constructor
 * @param {String} [formatted=null] 联系人的全名
 * @param {String} [familyName=null] 联系人的姓氏
 * @param {String} [givenName=null] 联系人的名字
 * @param {String} [middle=null] 联系人的中间名
 * @param {String} [prefix=null] 尊称的前缀，比如 “尊敬的”、“敬爱的”等
 * @param {String} [suffix=null] 尊称的后缀，比如 “先生”、“女士”等
 * @platform Android, iOS
 * @since 3.0.0
 */
var ContactName = function(formatted, familyName, givenName, middle, prefix, suffix) {
    /**
     * 联系人的全名（Android, iOS）
     * @property formatted
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.formatted = formatted || null;
    /**
     * 联系人的姓氏（Android, iOS）
     * @property familyName
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.familyName = familyName || null;
    /**
     * 联系人的名字（Android, iOS）
     * @property givenName
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.givenName = givenName || null;
    /**
     * 联系人的中间名（Android, iOS）
     * @property middleName
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.middleName = middle || null;
    /**
     * 尊称的前缀，比如 “尊敬的”、“敬爱的”等（Android, iOS）
     * @property honorificPrefix
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.honorificPrefix = prefix || null;
    /**
     * 尊称的后缀，比如 “先生”、“女士”等（Android, iOS）
     * @property honorificSuffix
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.honorificSuffix = suffix || null;
};

module.exports = ContactName;
});

// file: lib/common/extension/ContactOrganization.js
define("xFace/extension/ContactOrganization", function(require, exports, module) {

 /**
 * 该类定义了联系人的所属组织属性,Contact对象通过一个数组存储一个或多个ContactOrganization对象（Android, iOS）<br/>
 * 相关参考： {{#crossLink "Contact"}}{{/crossLink}}
 * @class ContactOrganization
 * @constructor
 * @param {Boolean} [pref=false] 首选项
 * @param {String} [type=null] 机构类型
 * @param {String} [name=null] 机构名称
 * @param {String} [dept=null] 部门名称
 * @param {String} [title=null] 职位名称
 * @platform Android, iOS
 * @since 3.0.0
 */
var ContactOrganization = function(pref, type, name, dept, title) {
    /**
     * 唯一标识符
     */	
    this.id = null;
    /**
     * 首选项 
     */
    this.pref = (typeof pref != 'undefined' ? pref : false);
    /**
     * 机构类型（Android, iOS）
     * @property type
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.type = type || null;
    /**
     * 机构名称（Android, iOS）
     * @property name
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.name = name || null;
    /**
     * 部门名称（Android, iOS）
     * @property department
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.department = dept || null;
    /**
     * 职位名称（Android, iOS）
     * @property title
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.title = title || null;
};

module.exports = ContactOrganization;
});

// file: lib/common/extension/DirectoryEntry.js
define("xFace/extension/DirectoryEntry", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    Entry = require('xFace/extension/Entry');

/**
 * 该对象表示一个文件系统的目录（Android, iOS）<br/>
 * @example
        var name = "test";
        var fullPath = "/test";
        var entry = new DirectoryEntry(name, fullPath);
 * @class DirectoryEntry
 * @constructor
 * @extends Entry
 * @param {String} [name] 目录名称
 * @param {String} [fullPath] 目录的完整路径
 * @platform Android, iOS
 * @since 3.0.0
 */
var DirectoryEntry = function(name, fullPath) {
    argscheck.checkArgs('SS', 'DirectoryEntry.DirectoryEntry', arguments);
    DirectoryEntry.__super__.constructor.apply(this, [false, true, name, fullPath]);
};

utils.extend(DirectoryEntry, Entry);

/**
 * 根据当前目录的绝对路径创建一个{{#crossLink "DirectoryReader"}}{{/crossLink}}对象（Android，iOS）<br/>
 * @example
        var directoryReader = DirectoryEntry.createReader();
 * @method createReader
 * @return {DirectoryReader} directoryReader
 * @platform Android, iOS
 * @since 3.0.0
 */
DirectoryEntry.prototype.createReader = function() {
    return new DirectoryReader(this.fullPath);
};

/**
 * 在当前目录下创建或者查找目录（Android，iOS）<br/>
 * 注意：如果要创建目录的父目录不存在，会报错
 * @example
        function success(parent) {
            console.log("Parent Name: " + parent.name);
        }
        function error(error) {
            alert("Unable to create new directory: " + error.code);
        }
        // 获取一个已存在的目录，如果该目录不存在的时候创建它
        entry.getDirectory("newDir", {create: true, exclusive: false}, success, error);
 * @method getDirectory
 * @param {String} path 需要创建或查找的目录路径（绝对路径或相对路径）
 * @param {Flags} options 该参数用于决定在目录不存在的时候是否创建该目录
 * @param {Function} successCallback 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 创建的或查找到的目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DirectoryEntry.prototype.getDirectory = function(path, options, successCallback, errorCallback) {
    argscheck.checkArgs('sofF', 'DirectoryEntry.getDirectory', arguments);
    var win = function(result) {
        var entry = new DirectoryEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getDirectory", [this.fullPath, path, options]);
};

/**
 * 从文件系统中递归删除当前目录（包含所有的子文件和子目录）（Android，iOS）<br/>
 * 如果有子文件（夹）无法删除时，部分子文件（夹）可能会被删掉，同时会回调报错<br/>
 * 注意：当删除一个文件系统的根目录时，会报错
 * @example
        function success() {
            console.log("Remove Recursively Succeeded");
        }
        function error(error) {
            alert("Failed to remove directory: " + error.code);
        }
        // 删除该目录下的所有内容
        entry.removeRecursively(success, error);
 * @method removeRecursively
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DirectoryEntry.prototype.removeRecursively = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'DirectoryEntry.removeRecursively', arguments);
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(successCallback, fail, null, "File", "removeRecursively", [this.fullPath]);
};

/**
 * 在当前目录下创建或者查找一个文件（Android，iOS）<br/>
 * 注意：如果要创建文件的父目录不存在，会报错
 * @example
        function success(entry) {
            console.log("Parent Name: " + entry.name);
        }
        function error(error) {
            alert("Failed to retrieve file: " + error.code);
        }
        // 获取一个已存在的文件，如果该文件不存在则创建它
        entry.getFile("test.txt", {create: true, exclusive: false}, success, error);
 * @method getFile
 * @param {String} path 需要创建或查找的文件路径（绝对路径或相对路径）
 * @param {Flags=null} options 该参数用于决定在文件不存在的时候是否创建该文件(传null等同于{create: false})
 * @param {Function} successCallback 成功回调函数
 * @param {FileEntry} successCallback.entry 创建的或查找到的文件对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DirectoryEntry.prototype.getFile = function(path, options, successCallback, errorCallback) {
    argscheck.checkArgs('s*fF', 'DirectoryEntry.getFile', arguments);
    var win = function(result) {
        var FileEntry = require('xFace/extension/FileEntry');
        var entry = new FileEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getFile", [this.fullPath, path, options]);
};
//复写基类Entry属性注释
/**
 * 用于标识是否是一个文件（固定为false）(Android, iOS)
 * @example
       entry.isFile
 * @property isFile
 * @type Boolean
 * @default false
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 用于标识是否是一个目录（固定为true）(Android, iOS)
 * @example
       entry.isDirectory
 * @property isDirectory
 * @type Boolean
 * @default true
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 目录的名称，不包含路径(Android, iOS)
 * @example
       entry.name
 * @property name
 * @type String
 * @default ""
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 目录的绝对路径(Android, iOS)
 * @example
       entry.fullPath
 * @property fullPath
 * @type String
 * @default ""
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 目录所在的文件系统(Android, iOS)
 * @example
       entry.filesystem
 * @property filesystem
 * @type FileSystem
 * @default null
 * @platform Android, iOS
 * @since 3.0.0
 */

//复写基类Entry的方法注释
/**
 * 移动目录（Android, iOS）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.移动一个目录到它自身目录，或者它的任意子目录下<br/>
 * 例如：目录结构如下/a/b/c，若要移动目录a到目录a，b或c下都会报错<br/>
 * 2.移动一个目录到它的父目录下，且该目录名称未修改<br/>
 * 例如：目录结构如下/b/a，若目录a要直接移动到目录b下，且目录a未修改名称会报错<br/>
 * 3.移动目录的目标路径已经被一个文件占用<br/>
 * 例如：在目录a下面有一个文件b，现将另外一个目录c移动a下面，并且目录c的新名称为b，这时会报错<br/>
 * 4.移动目录的目标路径已经被一个非空目录（包含文件或子文件）占用<br/>
 * 例如：文件目录结构为/a/b/c.txt，若将另一个目录d移动到a下面，并且目录d的新名称为b，这时会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function moveDir(entry) {
            var parent = document.getElementById('parent').value,
                parentName = parent.substring(parent.lastIndexOf('/')+1),
                newName = document.getElementById('newName').value,
                parentEntry = new DirectoryEntry(parentName, parent);
            //移动一个目录到新目录下并重命名
            entry.moveTo(parentEntry, newName, success, error);
        }
 * @method moveTo
 * @param {DirectoryEntry} parent  将要移动到的父目录对象
 * @param {String} [newName=this.name] 目录的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 移动后的目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 复制目录（Android, iOS）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.复制一个目录到它的自身目录，或者它的任意子目录下<br/>
 * 例如：目录结构如下/a/b/c，若要复制目录a到目录a，b或c下都会报错<br/>
 * 2.复制一个目录到它的父目录下，且该目录名称未修改<br/>
 * 例如：目录结构如下/b/a，若目录a要直接复制到目录b下，且目录a未修改名称会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function copyDir(entry) {
            var parent = document.getElementById('parent').value,
                parentName = parent.substring(parent.lastIndexOf('/')+1),
                newName = document.getElementById('newName').value,
                parentEntry = new DirectoryEntry(parentName, parent);
            //复制一个目录到新目录下
            entry.copyTo(parentEntry, newName, success, error);
        }
 * @method copyTo
 * @param {DirectoryEntry} parent  将要复制到的父目录对象
 * @param {String} [newName=this.name] 目录的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 复制后的目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 删除一个目录（Android, iOS）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.删除一个非空目录（即包含子文件）<br/>
 * 例如：目录结构如下/b/a/c.txt，要删除目录a时，会报错<br/>
 * 2.删除文件系统的根目录<br/>
 * 例如：如果文件系统的根目录是/root时，删除root会报错<br/>
 * @example
        function success(entry) {
            console.log("Removal succeeded");
        }
        function error(error) {
            alert('Error info: ' + error.code);
        }
        //删除目录
        entry.remove(success, error);
 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 返回当前目录的URL地址（Android, iOS）<br/>
 * @example
        var dirURL = entry.toURL();
 * @method toURL
 * @return {String} URL地址
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 获取当前目录的父目录（Android, iOS）<br/>
 * @example
        function success(parent) {
            console.log("Parent Name: " + parent.name);
        }
        function error(error) {
            alert('Failed to get parent directory: ' + error.code);
        }
        // 获取父目录
        entry.getParent(success, error);
 * @method getParent
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 当前目录的父目录
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 获取当前目录的元数据（Android, iOS）<br/>
 * @example
        function success(metadata) {
            console.log("Last Modified: " + metadata.modificationTime);
        }
        function error(error) {
            alert(error.code);
        }
        // 获取该entry对象的元数据
        entry.getMetadata(success, error);
 * @method getMetadata
 * @param {Function} [successCallback] 成功回调函数
 * @param {Metadata} successCallback.metadata 当前目录的元数据
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
module.exports = DirectoryEntry;
});

// file: lib/common/extension/DirectoryReader.js
define("xFace/extension/DirectoryReader", function(require, exports, module) {

 /**
  * 该类返回一个目录中的所有文件实体（Android, iOS）<br/>
  * 该类不能通过new来创建相应的对象，只能通过{{#crossLink "DirectoryEntry/createReader"}}{{/crossLink}}方法创建该类的对象
  * @class DirectoryReader
  * @platform Android, iOS
  * @since 3.0.0
  */

var exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry');

function DirectoryReader(path) {
    this.path = path || null;
}

/**
 * 返回一个目录中的所有文件实体（Android，iOS）<br/>
 * @example
        var directoryReader = DirectoryEntry.createReader();
        directoryReader.readEntries(success,fail);
        function success(entries) {
            var i;
            var s = "success，文件夹中所有文件的名字如下：<p/>";
            for (i=0; i<entries.length; i++) {
                s += entries[i].name + "<br />";
            }
            document.querySelector("#content").innerHTML = s;
        }
        function fail(error) {
            alert(error.code);
        }
 * @method readEntries
 * @param {Function} [successCallback] 成功回调函数
 * @param {File[]} successCallback.files 返回File对象数组
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 该参数接收FileError的对象，该对象表示函数调用中产生的错误信息，参考{{#crossLink "FileError"}}{{/crossLink}}
 * @platform Android, iOS
 */
DirectoryReader.prototype.readEntries = function(successCallback, errorCallback) {
    var win = typeof successCallback !== 'function' ? null : function(result) {
        var retVal = [];
        for (var i = 0; i < result.length; i++) {
            var entry = null;
            if (result[i].isDirectory) {
                entry = new DirectoryEntry();
            }
            else if (result[i].isFile) {
                entry = new FileEntry();
            }
            entry.isDirectory = result[i].isDirectory;
            entry.isFile = result[i].isFile;
            entry.name = result[i].name;
            entry.fullPath = result[i].fullPath;
            retVal.push(entry);
        }
        successCallback(retVal);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "readEntries", [this.path]);
};

module.exports = DirectoryReader;

});

// file: lib/common/extension/Entry.js
define("xFace/extension/Entry", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    Metadata = require('xFace/extension/Metadata'),
    FileError = require('xFace/extension/FileError');

/**
 * 表示文件系统中的一个文件（夹）对象，该类是{{#crossLink "DirectoryEntry"}}{{/crossLink}}
 * 和{{#crossLink "FileEntry"}}{{/crossLink}}的基类（Android, iOS）<br/>
 * @example
        var entry = new Entry();
 * @class Entry
 * @constructor
 * @param {Boolean} [isFile=false] 用于标识是否为文件（true代表文件）
 * @param {Boolean} [isDirectory=false] 用于标识是否为文件夹（true代表文件夹）
 * @param {String} [name=''] 文件（夹）的名字
 * @param {String} [fullPath=''] 文件（夹）的绝对路径
 * @param {FileSystem} [fileSystem=null] 文件（夹）所在的文件系统
 * @platform Android, iOS
 * @since 3.0.0
 */
function Entry(isFile, isDirectory, name, fullPath, fileSystem) {
    argscheck.checkArgs('BBSSO', 'Entry.Entry', arguments);
    /**
     * 是否是文件对象(Android, iOS)
     * @example
           entry.isFile
     * @property isFile
     * @type Boolean
     * @default false
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isFile = (typeof isFile != 'undefined'?isFile:false);

    /**
     * 是否是文件夹对象(Android, iOS)
     * @example
           entry.isDirectory
     * @property isDirectory
     * @type Boolean
     * @default false
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isDirectory = (typeof isDirectory != 'undefined'?isDirectory:false);

    /**
     * 文件（夹）的名称，不包含路径(Android, iOS)
     * @example
           entry.name
     * @property name
     * @type String
     * @default ""
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.name = name || '';

    /**
     * 文件（夹）的绝对路径(Android, iOS)
     * @example
           entry.fullPath
     * @property fullPath
     * @type String
     * @default ""
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.fullPath = fullPath || '';

    /**
     * 文件（夹）所在的文件系统(Android, iOS)
     * @example
           entry.filesystem
     * @property filesystem
     * @type FileSystem
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.filesystem = fileSystem || null;
}

/**
 * 移动文件（夹）（Android, iOS）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/moveTo"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/moveTo"}}{{/crossLink}}的实例
 * @method moveTo
 * @param {DirectoryEntry} parent 将要移动到的父目录
 * @param {String} [newName=this.name] 文件（夹）的新名字
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry|DirectoryEntry} successCallback.entry 移动后的文件（夹）对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.moveTo = function(parent, newName, successCallback, errorCallback) {
    argscheck.checkArgs('oSFF', 'Entry.moveTo', arguments);
    var fail = function(code) {
        if (typeof errorCallback === 'function') {
            errorCallback(new FileError(code));
        }
    };

    if (!parent) {
        fail(FileError.NOT_FOUND_ERR);
        return;
    }
    // 原路径
    var srcPath = this.fullPath,
        name = newName || this.name,
        success = function(entry) {
            if (entry) {
                if (typeof successCallback === 'function') {
                    var result = (entry.isDirectory) ? new (require('xFace/extension/DirectoryEntry'))(entry.name, entry.fullPath) : new (require('xFace/extension/FileEntry'))(entry.name, entry.fullPath);
                    try {
                        successCallback(result);
                    }
                    catch (e) {
                        console.log('Error invoking callback: ' + e);
                    }
                }
            }
            else {
                fail(FileError.NOT_FOUND_ERR);
            }
        };

    exec(success, fail, null, "File", "moveTo", [srcPath, parent.fullPath, name]);
};

/**
 * 复制文件（夹）（Android, iOS）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/copyTo"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/copyTo"}}{{/crossLink}}的实例
 * @method copyTo
 * @param {DirectoryEntry} parent  将要复制到的父目录对象
 * @param {String} [newName=this.name] 文件（夹）的新名字
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry|DirectoryEntry} successCallback.entry 复制后的文件（夹）对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.copyTo = function(parent, newName, successCallback, errorCallback) {
    argscheck.checkArgs('oSFF', 'Entry.copyTo', arguments);
    var fail = function(code) {
        if (typeof errorCallback === 'function') {
            errorCallback(new FileError(code));
        }
    };

    if (!parent) {
        fail(FileError.NOT_FOUND_ERR);
        return;
    }

    var srcPath = this.fullPath,
        name = newName || this.name,
        // success callback
        success = function(entry) {
            if (entry) {
                if (typeof successCallback === 'function') {
                    var result = (entry.isDirectory) ? new (require('xFace/extension/DirectoryEntry'))(entry.name, entry.fullPath) : new (require('xFace/extension/FileEntry'))(entry.name, entry.fullPath);
                    try {
                        successCallback(result);
                    }
                    catch (e) {
                        console.log('Error invoking callback: ' + e);
                    }
                }
            }
            else {
                fail(FileError.NOT_FOUND_ERR);
            }
        };

    exec(success, fail, null, "File", "copyTo", [srcPath, parent.fullPath, name]);
};

/**
 * 删除一个文件（夹）（Android, iOS）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/remove"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/remove"}}{{/crossLink}}的实例
 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.remove = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'Entry.remove', arguments);
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(successCallback, fail, null, "File", "remove", [this.fullPath]);
};

/**
 * 返回当前文件（夹）的URL地址（Android, iOS）
 * @example
        var dirURL = entry.toURL();
 * @method toURL
 * @return {String} URL地址
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.toURL = function() {
    // fullPath attribute contains the full URL
    return "file://" + this.fullPath;
};

/**
 * 返回当前文件（夹）的URI信息（Android, iOS）
 * @deprecated 该方法以后可能不支持，建议使用toURL方法
 * @method toURI
 * @param {String} mimeType 文件类型(常见的MIME类型:如"text/html"，"text/plain"，"image/gif"等)
 * @return {String} URI信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.toURI = function(mimeType) {
    argscheck.checkArgs('s', 'Entry.toURI', arguments);
    console.log("DEPRECATED: Update your code to use 'toURL'");
    return "file://" + this.fullPath;
};

/**
 * 获取当前文件（夹）的父目录（Android, iOS）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/getParent"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/getParent"}}{{/crossLink}}的实例
 * @method getParent
 * @param {Function} successCallback 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 父目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.getParent = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'Entry.getParent', arguments);
    var win = function(result) {
        var DirectoryEntry = require('xFace/extension/DirectoryEntry');
        var entry = new DirectoryEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getParent", [this.fullPath]);
};

/**
 * 获取当前文件（夹）的元数据（Android, iOS）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/getMetadata"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/getMetadata"}}{{/crossLink}}的实例
 * @method getMetadata
 * @param {Function} successCallback 成功回调函数
 * @param {Metadata} successCallback.metadata 目标对象的元数据
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Entry.prototype.getMetadata = function(successCallback, errorCallback) {
  argscheck.checkArgs('fF', 'Entry.getMetadata', arguments);
  var success = function(lastModified) {
      var metadata = new Metadata(lastModified);
      successCallback(metadata);
  };
  var fail = typeof errorCallback !== 'function' ? null : function(code) {
      errorCallback(new FileError(code));
  };

  exec(success, fail, null, "File", "getMetadata", [this.fullPath]);
};

module.exports = Entry;
});

// file: lib/common/extension/File.js
define("xFace/extension/File", function(require, exports, module) {

 var argscheck = require('xFace/argscheck');
 
 /**
  * File定义了单个文件的属性（Android, iOS）<br/>
  * @example
        var file = new File();
  * @param {String} [name=""] 文件的名称，不包含文件路径信息
  * @param {String} [fullPath=null] 文件的完整路径，包含文件名
  * @param {String} [type=null] 文件类型(常见的MIME类型:如text/html，text/plain，image/gif等)
  * @param {Date} [lastModifiedDate=null] 文件的最后修改时间
  * @param {Number} [size=0] 用bytes单位表示的文件大小
  * @class File
  * @constructor
  * @platform Android, iOS
  * @since 3.0.0
  */
var File = function(name, fullPath, type, lastModifiedDate, size){
    /**
     * 文件的名称，不包含文件路径信息(Android, iOS).
     * @example
        function success(file) {
            alert(file.name);
        }
     * @property name
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.name = name || '';

    /**
     * 文件的完整路径，包含文件名(Android, iOS).
     * @example
        function success(file) {
            alert(file.fullPath);
        }
     * @property fullPath
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.fullPath = fullPath || null;

    /**
     * 文件类型(mime)(Android, iOS).
     * @example
        function success(file) {
            alert(file.type);
        }
     * @property type
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.type = type || null;

    /**
     * 文件的最后修改时间(Android, iOS).
     * @example
        function success(file) {
            alert(file.lastModifiedDate);
        }
     * @property lastModifiedDate
     * @type Date
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.lastModifiedDate = lastModifiedDate || null;

    /**
     * 用bytes单位表示的文件大小(Android, iOS).
     * @example
        function success(file) {
            alert(file.size);
        }
     * @property size
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.size = size || 0;
    
    /**
     * 用来表示一个文件块的起始位置(Android).
     * @example
        function success(file) {
            alert(file.start);
        }
     * @property start
     * @type Number
     * @platform Android
     * @since 3.0.0
     */
     this.start = 0;
     
    /**
     * 用来表示一个文件块的结束位置(Android).
     * @example
        function success(file) {
            alert(file.end);
        }
     * @property end
     * @type Number
     * @platform Android
     * @since 3.0.0
     */
     this.end = this.size;
     
    /**
     * 返回一个指定文件块分块的文件对象，由于文件对象并不包含实际的内容，这个返回对象只是修改了start和end这2个属性（Android）<br/>
     * @example
            <!DOCTYPE html>
            <html>
              <head>
                <title>File slice Example</title>

                <script type="text/javascript" charset="utf-8" src="xface.js"></script>
                <script type="text/javascript" charset="utf-8">

                function onLoad() {
                    document.addEventListener("deviceready", onDeviceReady, false);
                }

                function onDeviceReady() {
                    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, fail);
                }

                function gotFS(fileSystem) {
                    fileSystem.root.getFile("readme.txt", null, gotFileEntry, fail);
                }

                function gotFileEntry(fileEntry) {
                    fileEntry.file(gotFile, fail);
                }

                function gotFile(file){
                    readDataUrl(file);
                    readAsText(file);
                }

                function readDataUrl(file) {
                    var reader = new FileReader();
                    reader.onloadend = function(evt) {
                        console.log("Read as data URL");
                        console.log(evt.target.result);
                    };
                    //设置分块的起始地址为2，结束地址默认为文件结尾
                    file.slice(2);
                    reader.readAsDataURL(file);
                }

                function readAsText(file) {
                    var reader = new FileReader();
                    reader.onloadend = function(evt) {
                        console.log("Read as text");
                        console.log(evt.target.result);
                    };
                    //设置分块的起始地址为2，结束地址为10
                    file.slice(2,10);
                    reader.readAsText(file);
                }

                function fail(evt) {
                    console.log(evt.target.error.code);
                }

                </script>
              </head>
              <body>
                <h1>Example</h1>
                <p>Read File</p>
              </body>
            </html>
     * @method slice
     * @param {Number} start 用于指定文件块的起始位置，可以为负数，表示从文件尾部开始向前几位
     * @param {Number} end   用于指定文件块的结束位置,可以不填，不填则结束位置默认为文件末尾
     * @return {Object} 一个指定文件块分块的文件对象
     * @platform Android
     * @since 3.0.0
     */
File.prototype.slice = function(start, end) {
    argscheck.checkArgs('nN', 'FileReader.readAsText', arguments);
    if(!arguments[1])
    {
        end = 0;
    }
    var newFile = new File(this.name, this.fullPath, this.type, this.lastModifiedData, this.size);
    newFile.start = start;
    newFile.end = end;
    return newFile;
};
};

module.exports = File;
});

// file: lib/common/extension/FileEntry.js
define("xFace/extension/FileEntry", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    utils = require('xFace/utils'),
    exec = require('xFace/exec');
    Entry = require('xFace/extension/Entry'),
    File = require('xFace/extension/File'),
    FileWriter = require('xFace/extension/FileWriter'),
    FileError = require('xFace/extension/FileError');

/**
 * 表示文件系统中的一个文件（Android, iOS）<br/>
 * @example
        var name = "test.txt";
        var fullPath = "/test.txt";
        var entry = new FileEntry(name, fullPath);
 * @class FileEntry
 * @constructor
 * @extends Entry
 * @param {String} [name] 文件名称
 * @param {String} [fullPath] 文件的完整路径
 * @platform Android, iOS
 * @since 3.0.0
 */
var FileEntry = function(name, fullPath) {
    argscheck.checkArgs('SS', 'FileEntry.FileEntry', arguments);
    FileEntry.__super__.constructor.apply(this, [true, false, name, fullPath]);
};

utils.extend(FileEntry, Entry);

/**
 * 根据当前文件信息创建{{#crossLink "FileWriter"}}{{/crossLink}}对象，用于对该文件进行写操作（Android, iOS）<br/>
 * @example
        fileEntry.createWriter (success, error);
        function success(writer) {
            writer.write("some text");
            writer.truncate(11);
        }
        function error(error) {
            alert(error.code);
        }
 * @method createWriter
 * @param {Function} successCallback 成功回调函数
 * @param {FileWriter} successCallback.writer 创建成功的{{#crossLink "FileWriter"}}{{/crossLink}}对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
FileEntry.prototype.createWriter = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'FileEntry.createWriter', arguments);
    this.file(function(filePointer) {
        var writer = new FileWriter(filePointer);

        if (writer.fileName === null || writer.fileName === "") {
            if (typeof errorCallback === "function") {
                errorCallback(new FileError(FileError.INVALID_STATE_ERR));
            }
        } else {
            successCallback(writer);
        }
    }, errorCallback);
};

/**
 * 获取一个{{#crossLink "File"}}{{/crossLink}}对象，用于描述当前文件的状态信息（Android, iOS）<br/>
 * @example
        fileEntry.file(success, error);
        function success(file) {
            alert(file.size);
            alert(file.name);
            alert(file.fullPath);
            alert(file.type);
            alert(file.lastModifiedDate);
        }
        function error(error) {
            alert(error.code);
        }
 * @method file
 * @param {Function} successCallback 成功回调函数
 * @param {File} successCallback.file 创建成功的{{#crossLink "File"}}{{/crossLink}}对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
FileEntry.prototype.file = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'FileEntry.file', arguments);
    var win = function(f) {
        var file = new File(f.name, f.fullPath, f.type, f.lastModifiedDate, f.size);
        successCallback(file);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getFileMetadata", [this.fullPath]);
};

//复写基类Entry属性注释
/**
 * 用于标识是否是一个文件（固定为true）(Android, iOS)
 * @example
       entry.isFile
 * @property isFile
 * @type Boolean
 * @default true
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 用于标识是否是一个目录（固定为false）(Android, iOS)
 * @example
       entry.isDirectory
 * @property isDirectory
 * @type Boolean
 * @default false
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 文件的名称，不包含路径(Android, iOS)
 * @example
       entry.name
 * @property name
 * @type String
 * @default ""
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 文件的绝对路径(Android, iOS)
 * @example
       entry.fullPath
 * @property fullPath
 * @type String
 * @default ""
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 文件所在的文件系统(Android, iOS)
 * @example
       entry.filesystem
 * @property filesystem
 * @type FileSystem
 * @default null
 * @platform Android, iOS
 * @since 3.0.0
 */

//复写基类Entry的方法注释
/**
 * 移动文件（Android, iOS）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.移动一个文件到它的父目录，且该文件未修改文件名<br/>
 * 例如：目录结构如下/a/b.txt，若要移动b.txt文件到目录a下，并且b.txt未修改文件名会报错<br/>
 * 2.移动文件的目标路径已经被一个目录占用<br/>
 * 例如：在目录a下面有一个目录b，现将另外一个文件c移动到a下面，并且文件c的新名称为b，这时会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function moveFile(entry) {
            var parent = document.getElementById('parent').value,
                parentName = parent.substring(parent.lastIndexOf('/')+1),
                parentEntry = new DirectoryEntry(parentName, parent);
            //移动一个文件到一个新目录，并且重命名该文件
            entry.moveTo(parentEntry, "test.txt", success, error);
        }
 * @method moveTo
 * @param {DirectoryEntry} parent  将要移动到的父目录
 * @param {String} [newName=this.name] 文件的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry} successCallback.entry 移动后的文件对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 复制文件（Android, iOS）<br/>
 * 注意以下的操作会报错：<br/>
 * 1.复制一个文件到它的父目录，且该文件未修改名称<br/>
 * 例如：目录结构如下/a/b.txt，若要复制b.txt文件到目录a下，并且b.txt未修改文件名会报错<br/>
 * @example
        function success(entry) {
            console.log("New Path: " + entry.fullPath);
        }
        function error(error) {
            alert(error.code);
        }
        function copyFile(entry) {
            var parent = document.getElementById('parent').value,
            parentName = parent.substring(parent.lastIndexOf('/')+1),
            parentEntry = new DirectoryEntry(parentName, parent);
            //复制一个文件到新目录下
            entry.copyTo(parentEntry, newName, success, error);
        }
 * @method copyTo
 * @param {DirectoryEntry} parent 将要复制到的父目录
 * @param {String} [newName=this.name] 文件的新名称
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry} successCallback.entry 复制后的文件对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 删除一个文件（Android, iOS）<br/>
 * @example
        function success(entry) {
            console.log("Removal succeeded");
        }
        function error(error) {
            alert('Error info: ' + error.code);
        }
        //删除一个文件
        entry.remove(success, error);
 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 返回当前文件的URL地址（Android, iOS）<br/>
 * @example
        var dirURL = entry.toURL();
 * @method toURL
 * @return {String} URL地址
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 获取当前文件的父目录（Android, iOS）<br/>
 * @example
        function success(parent) {
            console.log("Parent Name: " + parent.name);
        }
        function error(error) {
            alert('Failed to get parent directory: ' + error.code);
        }
        // 获取父目录
        entry.getParent(success, error);
 * @method getParent
 * @param {Function} [successCallback] 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 当前文件的父目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
/**
 * 获取当前文件的元数据（Android, iOS）<br/>
 * @example
        function success(metadata) {
            console.log("Last Modified: " + metadata.modificationTime);
        }
        function error(error) {
            alert(error.code);
        }
        // 获取该entry对象的元数据
        entry.getMetadata(success, error);
 * @method getMetadata
 * @param {Function} [successCallback] 成功回调函数
 * @param {Metadata} successCallback.metadata 当前文件的元数据
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
module.exports = FileEntry;
});

// file: lib/common/extension/FileError.js
define("xFace/extension/FileError", function(require, exports, module) {

/**
 * FileError用于表示文件操作出现的具体的错误（Android, iOS）<br/>
 * @class FileError
 * @platform Android, iOS
 * @since 3.0.0
 */
function FileError(error) {
  /**
   * 文件操作的错误码，用于表示具体的文件操作错误(Android, iOS)<br/>
   * 其取值范围参考{{#crossLink "FileError"}}{{/crossLink}}中定义的常量
   * @example
            function errorCallback(fileError) {
                if( fileError.code == FileError.PATH_EXISTS_ERR) {
                    print("File is already exists!");
                }
            }
   * @property code
   * @type Number
   * @platform Android, iOS
   * @since 3.0.0
   */
  this.code = error || null;
}

// File error codes
// Found in DOMException
/**
 * 表示没有找到相应的文件或者目录的错误（Android，iOS）
 * @example
            FileError.NOT_FOUND_ERR;
 * @property NOT_FOUND_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.NOT_FOUND_ERR = 1;

/**
 * 表示所有没被其他错误类型所涵盖的安全错误（Android，iOS）<br/>
 * 例如：当前文件在Web应用中被访问是不安全的；对文件资源过多的访问等
 * @example
           FileError.SECURITY_ERR;
 * @property SECURITY_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.SECURITY_ERR = 2;

/**
 * 表示文件操作被中止错误（Android，iOS）
 * @example
           FileError.ABORT_ERR;
 * @property ABORT_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.ABORT_ERR = 3;

// Added by File API specification
/**
 * 表示文件或目录无法读取的错误（Android，iOS）<br/>
 * 通常是由于另外一个应用已经获取了当前文件的引用并使用了并发锁（Android，iOS）
 * @example
           FileError.NOT_READABLE_ERR;
 * @property NOT_READABLE_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.NOT_READABLE_ERR = 4;

/**
 * 表示文件编码错误（Android，iOS）<br/>
 * 例如：在特殊的字符串中包含不合法的协议或者字符串无法被解析时，返回该错误码
 * @example
           FileError.ENCODING_ERR;
 * @property ENCODING_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.ENCODING_ERR = 5;

/**
 * 表示文件修改拒绝的错误（Android，iOS）<br/>
 * 例如：当试图写入一个文件或目录时（底层文件系统不允许修改该文件或目录，如存在访问权限等问题）会返回该错误码
 * @example
           FileError.NO_MODIFICATION_ALLOWED_ERR;
 * @property NO_MODIFICATION_ALLOWED_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.NO_MODIFICATION_ALLOWED_ERR = 6;

/**
 * 表示无效的文件操作状态错误（Android，iOS）<br/>
 * 例如：一个进程在写文件的时候又有个进程对同一个文件进行写的操作时会返回该错误码
 * @example
           FileError.INVALID_STATE_ERR;
 * @property INVALID_STATE_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.INVALID_STATE_ERR = 7;

/**
 * 表示文件格式错误（Android，iOS）<br/>
 * 例如：在请求一个文件来存储应用数据，被请求的文件格式不是临时文件或持久文件时，返回该错误码
 * @example
           FileError.SYNTAX_ERR;
 * @property SYNTAX_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.SYNTAX_ERR = 8;

/**
 * 表示非法的文件修改请求错误（Android，iOS）<br/>
 * 例如：同级移动（即移动到文件或目录所在目录）且没有提供和当前名称不同的名称时，会返回该错误码
 * @example
           FileError.INVALID_MODIFICATION_ERR;
 * @property INVALID_MODIFICATION_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.INVALID_MODIFICATION_ERR = 9;

/**
 * 表示文件操作越界错误（Android，iOS）<br/>
 * 例如：当向一个只有4kb的存储空间中存储超过它容量的文件时，会返回该错误码
 * @example
           FileError.QUOTA_EXCEEDED_ERR;
 * @property QUOTA_EXCEEDED_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.QUOTA_EXCEEDED_ERR = 10;

/**
 * 表示文件类型不匹配错误（Android，iOS）<br/>
 * 当试图查找文件或目录而查找的对象类型不是请求的对象类型时返回该错误码<br/>
 * 例如：当用户请求一个FileEntry对象，而该对象其实是一个DirectoryEntry对象时会返回该错误码
 * @example
           FileError.TYPE_MISMATCH_ERR;
 * @property TYPE_MISMATCH_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.TYPE_MISMATCH_ERR = 11;

/**
 * 表示文件或目录已存在错误（Android，iOS）<br/>
 * 例如：当试图创建路径已经存在的文件或目录时返回该错误码
 * @example
           FileError.PATH_EXISTS_ERR;
 * @property PATH_EXISTS_ERR
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileError.PATH_EXISTS_ERR = 12;

module.exports = FileError;
});

// file: lib/common/extension/FileReader.js
define("xFace/extension/FileReader", function(require, exports, module) {

var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

 /**
  * FileReader提供了读取文件的系列接口（Android，iOS）<br/>
  * 用户可以通过注册通知回调onloadstart、onprogress、onload、onloadend、onerror和onabort来分别监听
  * 开始读事件、读取进度事件、读取结束事件、读取成功完成事件、读取错误事件和读取被中止事件
  * @example
         var reader = new FileReader();
  * @class FileReader
  * @constructor
  * @platform Android, iOS
  * @since 3.0.0
  */
var FileReader = function() {
    /**
     * 文件名称（如果是String类型则表示文件的绝对路径，否则是File对象）（Android，iOS）
     * @example
        var reader = new FileReader();
        var name = reader.fileName;
     * @property fileName
     * @default ""
     * @type String|File
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.fileName = "";

    /**
     * 文件读取的状态(参考{{#crossLink "FileReader"}}{{/crossLink}}类的EMPTY,LOADING,DONE常量)（Android，iOS）
     * @example
        function fileReadyState(reader) {
            if(reader.readyState == FileReader.EMPTY) {
                print("current fileReader readyState is empty");
            }
            if(reader.readyState == FileReader.LOADING) {
                print("current fileReader readyState is loading");
            }
            if(reader.readyState == FileReader.DONE) {
                print("current fileReader readyState is done");
            }
        }
     * @property readyState
     * @default 0
     * @type number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.readyState = 0;

    /**
     * 读取的文件内容（Android，iOS）
     * @example
        var reader = new FileReader();
        reader.onloadend = function(evt) {
            console.log("Read as text");
            console.log(evt.target.result);
        };
        reader.readAsText(file);
     * @property result
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.result = null;

    /**
     * 读取文件时发生的错误信息（Android，iOS）
     * @example
        function errorInfo(error) {
            console.log(error.code);
        }
     * @property error
     * @default null
     * @type FileError
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.error = null;

    /**
     * 文件读取开始时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据读取的目标FileReader对象
     * @example
        var reader = new FileReader();
        reader.onloadstart = function(event) {
            alert("loading started");
        }
     * @property onloadstart
     * @default null
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onloadstart = null;    // When the read starts.

    /**
     * 当读取（或解码）一个文件或文件块数据时，或当报告部分文件数据时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据读取的目标FileReader对象
     * @example
        var reader = new FileReader();
        reader.onprogress = function(event) {
            alert("reading file");
        }
     * @property onprogress
     * @default null
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onprogress = null;     // While reading (and decoding) file or fileBlob data, and reporting partial file data (progess.loaded/progress.total)

    /**
     * 文件读取操作成功完成时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据读取的目标FileReader对象
     * @example
        var reader = new FileReader();
        reader.onload = function(event) {
            alert("file loaded");
            var text = event.target.result;
            alert(text);
        }
     * @property onload
     * @default null
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onload = null;         // When the read has successfully completed.

    /**
     * 文件读取操作失败时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性只有error属性有效<br/>
     *       error属性指向出错信息{{#crossLink "FileError"}}{{/crossLink}}对象
     * @example
        function reportError(reader) {
            reader.onerror = function fail(evt) {
                print("error info:" + evt.target.error.code);
            };
        }
     * @property onerror
     * @default null
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onerror = null;        // When the read has failed (see errors).

    /**
     * 文件读取操作完成后调用该通知回调函数（不管读取成功或者失败都会调用该通知回调函数）（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据读取的目标FileReader对象
     * @example
        function readAsText(file) {
            var reader = new FileReader();
            reader.onloadend = function(evt) {
                console.log("Read as text");
                console.log(evt.target.result);
            };
            reader.readAsText(file);
        }
     * @property onloadend
     * @default null
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onloadend = null;      // When the request has completed (either in success or failure).

    /**
     * 文件读取操作取消时调用该通知回调函数，如abort方法被调用时（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据读取的目标FileReader对象
     * @example
        var reader = new FileReader();
        reader.onabort = function(event) {
            alert("reading aborted");
        }
     * @property onabort
     * @default null
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onabort = null;        // When the read has been aborted. For instance, by invoking the abort() method.
};

// States
/**
 * 表示文件未开始读取状态（Android，iOS）
 * @example
        FileReader.EMPTY;
 * @property EMPTY
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileReader.EMPTY = 0;
/**
 * 表示文件正在进行读取状态（Android，iOS）
 * @example
        FileReader.LOADING;
 * @property LOADING
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileReader.LOADING = 1;
/**
 * 表示文件结束读取状态（Android，iOS）
 * @example
        FileReader.DONE;
 * @property DONE
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileReader.DONE = 2;

/**
 * 取消读取文件（Android, iOS）
 * @example
        var reader = new FileReader();
        reader.abort();
 * @method abort
 * @platform Android, iOS
 * @since 3.0.0
 */
FileReader.prototype.abort = function() {
    this.result = null;
    if (this.readyState == FileReader.DONE || this.readyState == FileReader.EMPTY) {
      return;
    }
    this.readyState = FileReader.DONE;
    if (typeof this.onabort === 'function') {
        this.onabort(new ProgressEvent('abort', {target:this}));
    }
    if (typeof this.onloadend === 'function') {
        this.onloadend(new ProgressEvent('loadend', {target:this}));
    }
};

/**
 * 读取文本文件（Android，iOS）<br/>
 * 用户可以注册FileReader的通知回调函数来接收读取的结果
 * @example
        function readAsText(file) {
            var reader = new FileReader();
            reader.onloadend = function(evt) {
                console.log("Read as text");
                console.log(evt.target.result);
            };
            reader.readAsText(file);
        }
 * @method readAsText
 * @param {File} file 要读取的文件对象
 * @param {String} [encoding="UTF-8"] 读取的编码格式 (编码格式请参考：http://www.iana.org/assignments/character-sets)
 * @platform Android, iOS
 * @since 3.0.0
 */
FileReader.prototype.readAsText = function(file, encoding) {
    argscheck.checkArgs('oS', 'FileReader.readAsText', arguments);
    this.fileName = '';
    if (typeof file.fullPath === 'undefined') {
        this.fileName = file;
    } else {
        this.fileName = file.fullPath;
    }
    if (this.readyState == FileReader.LOADING) {
        throw new FileError(FileError.INVALID_STATE_ERR);
    }
    this.readyState = FileReader.LOADING;
    if (typeof this.onloadstart === "function") {
        this.onloadstart(new ProgressEvent("loadstart", {target:this}));
    }
    //默认的编码格式为UTF-8
    var enc = encoding ? encoding : "UTF-8";
    var me = this;
    var execArgs = [this.fileName,enc];
    execArgs.push(file.start,file.end);
    exec(
        function(r) {
            if (me.readyState === FileReader.DONE) {
                return;
            }
            me.result = r;
            if (typeof me.onload === "function") {
                me.onload(new ProgressEvent("load", {target:me}));
            }
            me.readyState = FileReader.DONE;
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        },
        function(e) {
            if (me.readyState === FileReader.DONE) {
                return;
            }
            me.readyState = FileReader.DONE;
            me.result = null;
            me.error = new FileError(e);
            if (typeof me.onerror === "function") {
                me.onerror(new ProgressEvent("error", {target:me}));
            }
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        },
        null, "File", "readAsText", execArgs);
};

/**
 * 读取文件并以base64编码的URL字符串形式返回(URL的格式由IETF在RFC2397中定义)（Android，iOS）<br/>
 * 用户可以注册FileReader的通知回调函数来接收读取的结果
 * @example
        function readDataUrl(file) {
            var reader = new FileReader();
            reader.onloadend = function(evt) {
                console.log("Read as data URL");
                console.log(evt.target.result);
            };
            reader.readAsDataURL(file);
        }
 * @method readAsDataURL
 * @param {File} file 要读取的文件对象
 * @platform Android, iOS
 * @since 3.0.0
 */
FileReader.prototype.readAsDataURL = function(file) {
    argscheck.checkArgs('o', 'FileReader.readAsDataURL', arguments);
    this.fileName = "";
    if (typeof file.fullPath === "undefined") {
        this.fileName = file;
    } else {
        this.fileName = file.fullPath;
    }
    if (this.readyState == FileReader.LOADING) {
        throw new FileError(FileError.INVALID_STATE_ERR);
    }
    this.readyState = FileReader.LOADING;
    if (typeof this.onloadstart === "function") {
        this.onloadstart(new ProgressEvent("loadstart", {target:this}));
    }
    var me = this;
    var execArgs = [this.fileName];
    execArgs.push(file.start,file.end);
    exec(
        function(r) {
            if (me.readyState === FileReader.DONE) {
                return;
            }
            me.readyState = FileReader.DONE;
            me.result = r;
            if (typeof me.onload === "function") {
                me.onload(new ProgressEvent("load", {target:me}));
            }
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        },
        function(e) {
            if (me.readyState === FileReader.DONE) {
                return;
            }
            me.readyState = FileReader.DONE;
            me.result = null;
            me.error = new FileError(e);
            if (typeof me.onerror === "function") {
                me.onerror(new ProgressEvent("error", {target:me}));
            }
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        },
        null, "File", "readAsDataURL", execArgs);
};

/**
 * 读取文件并返回二进制数据
 * @param file          要读取的文件对象
 */
FileReader.prototype.readAsBinaryString = function(file) {
    argscheck.checkArgs('o', 'FileReader.readAsBinaryString', arguments);
    // TODO:目前不支持
    console.log('method "readAsBinaryString" is not supported at this time.');
};

/**
 * 读取文件并返回二进制数据
 * @param file          要读取的文件对象
 */
FileReader.prototype.readAsArrayBuffer = function(file) {
    argscheck.checkArgs('o', 'FileReader.readAsArrayBuffer', arguments);
    // TODO:目前不支持
    console.log('This method is not supported at this time.');
};

module.exports = FileReader;
});

// file: lib/common/extension/FileSystem.js
define("xFace/extension/FileSystem", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry');

/**
 * FileSystem对象表示文件系统的信息（Android，iOS）
 * @example
         function createFileSystem(systemName, fileName, fullPath) {
            var root = new DirectoryEntry(fileName, fullPath);
            var fileSystem = new FileSystem(systemName, root);
         }
 * @param {String} name 标识文件系统的名称
 * @param {DirectoryEntry} root 文件系统的根目录
 * @class FileSystem
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS
 */
var FileSystem = function(name, root) {
    argscheck.checkArgs('so', 'FileSystem.FileSystem', arguments);
    /**
     * 标识文件系统的名称,并且该名称在文件系统中是唯一的（Android，iOS）
     * @example
            function onSuccess(fileSystem) {
                console.log(fileSystem.name);
            }
     * @property name
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.name = name || null;
    if (root) {
        /**
         * 文件系统的根目录（Android，iOS）
         * @example
            function onSuccess(fileSystem) {
                console.log(fileSystem.root.name);
            }
         * @property root
         * @type DirectoryEntry
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.root = new DirectoryEntry(root.name, root.fullPath);
    }
};

module.exports = FileSystem;
});

// file: lib/common/extension/FileTransfer.js
define("xFace/extension/FileTransfer", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileTransferError = require('xFace/extension/FileTransferError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

function newProgressEvent(result) {
    var pe = new ProgressEvent();
    pe.lengthAvailable = result.lengthAvailable;
    pe.loaded = result.loaded;
    pe.total = result.total;
    return pe;
}

var idCounter = 0;

/**
 * 提供普通文件传输（非断点的文件传输），终止等功能（Android，iOS）<br/>
 * 该类通过new来创建相应的对象，然后根据对象来使用该类中定义的方法
 * @example
        var fileTransfer = new FileTransfer();
 * @class FileTransfer
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS
 */
var FileTransfer = function() {
    /**
     * 文件传输任务的id，只有提供了id，传输任务才会实时更新进度条，_id从0开始计数（Android, iOS）
     */
    this._id = ++idCounter;
    /**
     * 文件传输的进度回调函数，该回调函数包含一个类型为{{#crossLink "ProgressEvent"}}{{/crossLink}}的参数，该参数要用到以下属性：（Android，iOS）<br/>
     * loaded: 已经传输的文件块大小，单位byte<br/>
     * total: 要传输的文件总大小，单位byte
     * @property onprogress
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.onprogress = null; // optional callback
};

/**
 * 下载一个文件到指定的路径(Android, iOS)<br/>
 * 下载过程中会通过onprogress属性更新文件传输进度
 * @example
        var fileTransfer = new FileTransfer();
        var remoteFile = "http://192.168.2.245/develop/test/test.css";
        var localFileName = "test.css";
		fileTransfer.download(remoteFile,localFileName,success,fail);
        fileTransfer.onprogress = function(evt) {
            var progress  = evt.loaded / evt.total;
        };
        function success(entry) {
            alert("download succeeded");
            alert(entry.isDirectory);
            alert(entry.isFile);
            alert(entry.name);
            alert(entry.fullPath);
        }
        function fail(error) {
            alert("download failed" );
            alert(error.code);
            alert(error.source);
            alert(error.target);
            alert(error.http_status);
        }
 * @method download
 * @param {String} source     文件所在的服务器URL
 * @param {String} target     将要下载到的指定路径
 * @param {Function} successCallback 成功回调函数
 * @param {FileEntry} successCallback.fileEntry 成功回调返回下载得到的文件对象
 * @param {Function} [errorCallback] 失败回调函数
 * @param {Object} errorCallback.errorInfo 失败回调返回的错误信息
 * @param {Number} errorCallback.errorInfo.code 错误码（在<a href="FileTransferError.html">FileTransferError</a>中定义）
 * @param {String} errorCallback.errorInfo.source 下载源地址
 * @param {String} errorCallback.errorInfo.target 下载目标地址
 * @param {Number} errorCallback.errorInfo.http_status 文件传输的HTTP状态码（例如404：页面不存在或链接错误）
 * @param {Boolean} [trustAllHosts=false]  是否信任所有服务器 (仅支持Android平台,例如： 自签名认证服务器)
 * @platform Android, iOS
 * @since 3.0.0
 */
FileTransfer.prototype.download = function(source, target, successCallback, errorCallback, trustAllHosts) {
    argscheck.checkArgs('ssfFB', 'FileTransfer.download', arguments);
    //预先检查可能的错误
    if (!source || !target) throw new Error("FileTransfer.download requires source URI and target URI parameters at the minimum.");
    var self = this;
    var win = function(result) {
        if (typeof result.lengthAvailable != "undefined") {
            if (self.onprogress) {
                return self.onprogress(newProgressEvent(result));
            }
        }
        else {
            var entry = null;
            if (result.isDirectory) {
                entry = new DirectoryEntry();
            }
            else if (result.isFile) {
                entry = new FileEntry();
            }
            entry.isDirectory = result.isDirectory;
            entry.isFile = result.isFile;
            entry.name = result.name;
            entry.fullPath = result.fullPath;
            entry.start = result.start;
            entry.end = result.end;
            successCallback(entry);
        }
    };

    var fail = function(e) {
        var error = new FileTransferError(e.code, e.source, e.target, e.http_status);
        errorCallback(error);
    };

    exec(win, errorCallback, null, 'FileTransfer', 'download', [source, target, trustAllHosts, this._id]);
};

/**
 * 上传文件到服务器（Android，iOS）<br/>
 * 上传过程中会通过onprogress属性更新文件传输进度
 * @example
        var localFilePath = "file:///mnt/sdcard/upload.txt";
        var localFileName = "upload.txt";
        var remoteFile = "http://apollo.polyvi.com/index.php";
        var fileTransfer = new FileTransfer();
        var options = new FileUploadOptions();
        options.fileKey = "file";
        options.fileName = localFileName;
        options.mimeType = "text/plain";
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        fileTransfer.onprogress = function(evt) {
            var progress  = evt.loaded / evt.total;
        };
        // removing options cause Android to timeout
        fileTransfer.upload(localFilePath, remoteFile, uploadWin, uploadFail, options);
        function uploadWin(result) {
            alert("success");
            alert("Code = " + result.responseCode);
            alert("Response = " + result.response);
            alert("Sent = " + result.bytesSent);
        }
        function uploadFail(error) {
            alert("failed");
            alert("An error has occurred: Code = " + error.code);
            alert("upload error source " + error.source);
            alert("upload error target " + error.target);
        }
 * @method upload
 * @param {String} filePath 要上传的本地文件路径
 * @param {String} server 接收文件的服务器地址
 * @param {Function} successCallback 成功回调函数
 * @param {Number} successCallback.responseCode 服务器端返回的HTTP响应代码
 * @param {String} successCallback.response 服务器端返回的HTTP响应
 * @param {Number} successCallback.bytesSent 向服务器所发送的字节数
 * @param {Function} [errorCallback] 失败回调函数
 * @param {Object} errorCallback.errorInfo 失败回调返回的错误信息
 * @param {Number} errorCallback.errorInfo.code 错误码（在<a href="FileTransferError.html">FileTransferError</a>中定义）
 * @param {String} errorCallback.errorInfo.source 上传源地址
 * @param {String} errorCallback.errorInfo.target 上传目标地址
 * @param {FileUploadOptions} [options] 文件上传选项，参见{{#crossLink "FileUploadOptions"}}{{/crossLink}}。
 * @param {Boolean} [trustAllHosts=false]  是否信任所有服务器 (仅支持Android平台,例如： 自签名认证服务器)。
 * @platform Android, iOS
 * @since 3.0.0
*/
FileTransfer.prototype.upload = function(filePath, server, successCallback, errorCallback, options, trustAllHosts) {
    argscheck.checkArgs('ssfFOB', 'FileTransfer.upload', arguments);
    // 参数检查
    if (!filePath || !server) throw new Error("FileTransfer.upload requires filePath and server URL parameters at the minimum.");
    // 检查options
    var fileKey = null;
    var fileName = null;
    var mimeType = null;
    var params = null;
    var chunkedMode = true;
    var headers = null;
    if (options) {
        fileKey = options.fileKey;
        fileName = options.fileName;
        mimeType = options.mimeType;
        headers = options.headers;
        if (options.chunkedMode !== null || typeof options.chunkedMode != "undefined") {
            chunkedMode = options.chunkedMode;
        }
        if (options.params) {
            params = options.params;
        }
        else {
            params = {};
        }
    }

    var fail = function(e) {
        var error = new FileTransferError(e.code, e.source, e.target, e.http_status);
        errorCallback(error);
    };
    var self = this;
    var win = function(result) {
        if (typeof result.lengthAvailable != "undefined") {
            if (self.onprogress) {
                return self.onprogress(newProgressEvent(result));
            }
        } else {
            return successCallback(result);
        }
    };
    exec(win, fail, null, 'FileTransfer', 'upload', [filePath, server, fileKey, fileName, mimeType, params, trustAllHosts, chunkedMode, headers, this._id]);
};

/**
 * 取消该对象正在进行的文件传输任务（Android，iOS）<br/>
 * @example
        var localFilePath = "file:///mnt/sdcard/upload.txt";
        var localFileName = "upload.txt";
        var remoteFile = "http://apollo.polyvi.com/index.php";
        var fileTransfer = new FileTransfer();
        var options = new FileUploadOptions();
        options.fileKey = "file";
        options.fileName = localFileName;
        options.mimeType = "text/plain";
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        fileTransfer.onprogress = function(evt) {
            var progress  = evt.loaded / evt.total;
        };
        // removing options cause Android to timeout
        fileTransfer.upload(localFilePath, remoteFile, uploadWin, uploadFail, options);
        fileTransfer.abort();
        function uploadWin(result) {
            alert("success");
            alert("Code = " + result.responseCode);
            alert("Response = " + result.response);
            alert("Sent = " + result.bytesSent);
        }
        function uploadFail(error) {
            alert("failed");
            alert("An error has occurred: Code = " + error.code);
            alert("upload error source " + error.source);
            alert("upload error target " + error.target);
        }
        function abortWin() {
            alert("abort success");
        }
        function abortFail(errorMessage) {
            alert("abort failed");
            alert(errorMessage);
        }
 * @method abort
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @param {String} errorCallback.errorMessage 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
FileTransfer.prototype.abort = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'FileTransfer.abort', arguments);
    exec(successCallback, errorCallback, null, 'FileTransfer', 'abort', [this._id]);
};

module.exports = FileTransfer;
});

// file: lib/common/extension/FileTransferError.js
define("xFace/extension/FileTransferError", function(require, exports, module) {

 /**
 * 本构造方法用于构造文件传输错误信息类<br/>
 * 应用场景参考{{#crossLink "xFace.AdvancedFileTransfer"}}{{/crossLink}}和
 * {{#crossLink "FileTransfer"}}{{/crossLink}}
 * @example
        var error = new FileTransferError(1, "test.exe", "http://apollo.polyvi.com/404", 404);
 * @param {Number} code 文件传输的错误码
 * @param {String} source 文件传输的源文件地址（下载时为服务器地址，上传时为本地地址）
 * @param {String} target 文件传输的目标地址（下载时为本地地址，上传时为服务器地址）
 * @param {Number} status 文件传输的HTTP状态码（例如404：页面不存在或链接错误）
 * @since 3.0.0
 * @platform Android, iOS
 * @class FileTransferError
 * @private
 * @constructor
 */
var FileTransferError = function(code, source, target, status) {
    /**
     * 用于标识文件传输的错误码（Android, iOS）
     * @property code
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.code = code || null;
     /**
     * 用于标识文件传输的源文件地址（下载时为服务器地址，上传时为本地地址）（Android, iOS）
     * @property source
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.source = source || null;
     /**
     * 用于标识文件传输的目标地址（下载时为本地地址，上传时为服务器地址）（Android, iOS）
     * @property target
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.target = target || null;
     /**
     * 用于标识文件传输的HTTP状态码（例如404：页面不存在或链接错误）（Android, iOS）
     * @property status
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.http_status = status || null;
};

/**
 * 用于标识文件传输过程中文件找不到错误,对应错误码1（Android, iOS）
 * @property FILE_NOT_FOUND_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
FileTransferError.FILE_NOT_FOUND_ERR = 1;

/**
 * 用于标识文件传输过程中url地址无效错误,对应错误码2（Android, iOS）
 * @property INVALID_URL_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
FileTransferError.INVALID_URL_ERR = 2;

/**
 * 用于标识文件传输过程中连网错误,对应错误码3（Android, iOS）
 * @property CONNECTION_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
FileTransferError.CONNECTION_ERR = 3;

/**
 * 用于标识文件传输过程中文件传输被终止错误,对应错误码4（Android, iOS）
 * @property ABORT_ERR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
FileTransferError.ABORT_ERR = 4;

module.exports = FileTransferError;


});

// file: lib/common/extension/FileUploadOptions.js
define("xFace/extension/FileUploadOptions", function(require, exports, module) {
var argscheck = require('xFace/argscheck');
 /**
 * 文件上传选项设置（Android，iOS）<br/>
 * 应用场景参考{{#crossLink "FileTransfer/upload"}}{{/crossLink}}
 * @example
        var options = new FileUploadOptions();
        options.fileKey = "file";
        options.fileName = localFileName;
        options.mimeType = "text/plain";
        var params = new Object();
        params.value1 = "test";
        params.value2 = "param";
        options.params = params;
        var headers = new Object();
        headers.name = "Content-Length";
        headers.value = "10000";
 * @param {String} [fileKey="file"] 表单元素的name值。
 * @param {String} [fileName="image.jpg"] 希望文件存储到服务器所用的文件名。
 * @param {String} [mimeType="image/jpeg"] 正在上传数据所使用的mime类型。
 * @param {Object} [params]  通过HTTP请求发送到服务器的一系列可选键/值对。
 * @param {Object} [headers] 文件上传时的头部信息，如果一个头部有多个值，需要把这些值放在数组里面。
 * @class FileUploadOptions
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS
 */
var FileUploadOptions = function(fileKey, fileName, mimeType, params, headers) {
    argscheck.checkArgs('SSSOO', 'FileUploadOptions.FileUploadOptions', arguments);
    /**
     * 表单元素的name值（Android, iOS）
     * @property fileKey
     * @default "file"
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.fileKey = fileKey || null;
    /**
     * 文件存储到服务器所用的文件名（Android, iOS）
     * @property fileName
     * @default "image.jpg"
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.fileName = fileName || null;
    /**
     * 正在上传数据所使用的mime类型（Android, iOS）
     * @property mimeType
     * @default "image/jpeg"
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.mimeType = mimeType || null;
    /**
     * 通过HTTP请求发送到服务器的一系列可选键/值对（Android, iOS）
     * @property params
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.params = params || null;
    /**
     * 请求头键/值对,头的名字是请求头的键，头的值是请求头的值，多个请求头不能有相同的头名字（Android, iOS）
     * @property headers
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.headers = headers || null;
};

module.exports = FileUploadOptions;
});

// file: lib/common/extension/FileUploadResult.js
define("xFace/extension/FileUploadResult", function(require, exports, module) {
 
 /**
 * 文件上传成功时成功回调返回的相关信息（Android，iOS）<br/>
 * 应用场景参考{{#crossLink "FileTransfer/upload"}}{{/crossLink}}
 * @class FileUploadResult
 * @constructor
 * @since 3.0.0
 * @platform Android, iOS
 */
var FileUploadResult = function() {
    /**
     * 已经向服务器所上传的字节数（Android, iOS）
     * @property bytesSent
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.bytesSent = 0;
    /**
     * 服务器端返回的HTTP响应代码（Android, iOS）
     * @property responseCode
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.responseCode = null;
    /**
     * 服务器端返回的HTTP响应数据（Android, iOS）
     * @property response
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.response = null;
};

module.exports = FileUploadResult;
});

// file: lib/common/extension/FileWriter.js
define("xFace/extension/FileWriter", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

/**
 * FileWriter提供了写文件的系列接口（Android，iOS）<br/>
 * 用户可以通过注册通知回调onwritestart、onprogress、onwrite、onwriteend、onerror和onabort来分别监听<br/>
 * 开始写操作事件、写操作进度事件、写操作结束事件、写操作成功完成事件、写操作错误事件和写操作被中止事件<br/>
 * 一个FileWriter对应一个文件。用户可以用该对象对一个文件进行多次写操作。FileWriter保存了文件指针位置和长度的属性<br/>
 * 所以用户可以在一个文件的任何位置进行查询和写操作。默认情况下，FileWriter会从文件的开始进行写操作(会覆盖文件中已存在的数据)<br/>
 * @example
        var writer = new FileWriter(file);
 * @constructor
 * @param {File} file 文件对象
 * @class FileWriter
 * @platform Android, iOS
 * @since 3.0.0
 */
var FileWriter = function(file) {
    argscheck.checkArgs('o', 'FileWriter.FileWriter', arguments);
    //TODO:PhoneGap支持构造函数加参数，从文件尾部开始写
    /**
     * 文件名称（如果是String类型则表示文件的绝对路径，否则是File对象）（Android，iOS）
     * @example
        var filename = writer.filename;
     * @property fileName
     * @type String|File
     * @default ""
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.fileName = "";

    /**
     * 要写入的文件长度（Android，iOS）
     * @example
        var fileLength = writer.length;
     * @property length
     * @type Number
     * @default 0
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.length = 0;
    if (file) {
        this.fileName = file.fullPath || file;
        this.length = file.size || 0;
    }
    // 默认从开始位置写文件
    /**
     * 文件指针的当前位置（Android，iOS）
     * @example
        function getWriterPosition(writer) {
            console.log(writer.position);
        }
     * @property position
     * @type Number
     * @default 0
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.position = 0;

    /**
     * 文件写操作的状态(参考{{#crossLink "FileWriter"}}{{/crossLink}}类的INIT,WRITING,DONE常量)（Android，iOS）
     * @example
        function fileWriterState(writer) {
            if(writer.readyState == FileWriter.INIT) {
                print("current fileWriter state is initial");
            }
            if(writer.readyState == FileWriter.WRITING) {
                print("current fileWriter state is writing");
            }
            if(writer.readyState == FileWriter.DONE) {
                print("current fileWriter state is done");
            }
        }
     * @property readyState
     * @type Number
     * @default 0
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.readyState = 0;

    /**
     * 错误信息（Android，iOS）
     * @example
        function success(writer) {
            writer.truncate(10);
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
     * @property error
     * @type FileError
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.error = null;

    /**
     * 写文件开始时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据写操作的目标FileWriter对象
     * @example
        var writer = new FileWriter(file);
        writer.onloadstart = function(event) {
            alert("write file started");
        }
     * @property onwritestart
     * @type Function
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onwritestart = null;   // When writing starts

    /**
     * 在写文件时需要报告写文件进度时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据写操作的目标FileWriter对象
     * @example
        function success(writer) {
            writer.onprogress = function(evt) {
                console.log("write file loaded");
            };
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
     * @property onprogress
     * @type Function
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onprogress = null;     // While writing the file, and reporting partial file data

    /**
     * 当写文件请求成功完成时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据写操作的目标FileWriter对象
     * @example
        function success(writer) {
            writer.onwrite = function(evt) {
                console.log("write success");
            };
            writer.write("some text");
            writer.abort();
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
     * @property onwrite
     * @type Function
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onwrite = null;        // When the write has successfully completed.

    /**
     * 当写文件请求完成时调用该通知回调函数（不管写操作成功或者失败都会调用该通知回调函数）（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据写操作的目标FileWriter对象
     * @example
        function success(writer) {
            writer.onwriteend = function(evt) {
                console.log("write file completed");
            };
            writer.write("some text");
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
     * @property onwriteend
     * @type Function
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onwriteend = null;     // When the request has completed (either in success or failure).

    /**
     * 当写文件操作被中止时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性指向正在进行数据写操作的目标FileWriter对象
     * @example
        function success(writer) {
            writer.onabort = function(evt) {
                console.log("write file aborted!");
            };
            writer.write("some text");
            writer.abort();
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
     * @property onabort
     * @type Function
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     **/
    this.onabort = null;        // When the write has been aborted. For instance, by invoking the abort() method.

    /**
     * 当写文件操作出错时调用该通知回调函数（Android，iOS）<br/>
     * 参数描述：<br/>
     * event:{{#crossLink "ProgressEvent"}}{{/crossLink}}类型的对象，该对象只有target属性有效，target属性只有error属性有效<br/>
     *       error属性指向错误信息{{#crossLink "FileError"}}{{/crossLink}}对象
     * @example
        function fail(writer) {
             writer.onerror = function(event) {
                console.log("error info:" + event.target.error.code);
            };
        };
     * @property onerror
     * @type Function
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.onerror = null;        // When the write has failed (see errors).
};

// 状态
/**
 * 表示准备进行写文件操作，但是还未写（Android，iOS）
 * @example
        FileWriter.INIT;
 * @property INIT
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileWriter.INIT = 0;

/**
 * 表示正在进行写文件操作（Android，iOS）
 * @example
        FileWriter.WRITING;
 * @property WRITING
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileWriter.WRITING = 1;

/**
 * 表示已经完成写文件操作（Android，iOS）
 * @example
        FileWriter.DONE;
 * @property DONE
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
FileWriter.DONE = 2;

/**
 * 取消写文件操作（Android, iOS）
 * @example
        function abortWrite(writer) {
            writer.abort();
        }
 * @method abort
 * @platform Android, iOS
 * @since 3.0.0
 */
FileWriter.prototype.abort = function() {
    if (this.readyState === FileWriter.DONE || this.readyState === FileWriter.INIT) {
        throw new FileError(FileError.INVALID_STATE_ERR);
    }

    this.error = new FileError(FileError.ABORT_ERR);

    this.readyState = FileWriter.DONE;

    if (typeof this.onabort === "function") {
        this.onabort(new ProgressEvent("abort", {"target":this}));
    }

    if (typeof this.onwriteend === "function") {
        this.onwriteend(new ProgressEvent("writeend", {"target":this}));
    }
};

/**
 * 将数据写入到文件中（Android，iOS）<br/>
 * @example
        function success(writer) {
            writer.onwrite = function(evt) {
                console.log("write success");
            };
            writer.write("some text");
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
 * @method write
 * @param {String} text 要写入的内容
 * @platform Android, iOS
 * @since 3.0.0
 */
FileWriter.prototype.write = function(text) {
    argscheck.checkArgs('s', 'FileWriter.write', arguments);
    //TODO:PhoneGap支持以UTF-8格式进行写操作
    if (this.readyState === FileWriter.WRITING) {
        throw new FileError(FileError.INVALID_STATE_ERR);
    }
    this.readyState = FileWriter.WRITING;

    var me = this;

    if (typeof me.onwritestart === "function") {
        me.onwritestart(new ProgressEvent("writestart", {"target":me}));
    }

    // 写文件
    exec(
        function(r) {
            if (me.readyState === FileWriter.DONE) {
                return;
            }

            me.position += r;

            me.length = me.position;

            me.readyState = FileWriter.DONE;

            if (typeof me.onwrite === "function") {
                me.onwrite(new ProgressEvent("write", {"target":me}));
            }

            if (typeof me.onwriteend === "function") {
                me.onwriteend(new ProgressEvent("writeend", {"target":me}));
            }
        },
        function(e) {
            if (me.readyState === FileWriter.DONE) {
                return;
            }

            me.readyState = FileWriter.DONE;

            me.error = new FileError(e);

            if (typeof me.onerror === "function") {
                me.onerror(new ProgressEvent("error", {"target":me}));
            }

            if (typeof me.onwriteend === "function") {
                me.onwriteend(new ProgressEvent("writeend", {"target":me}));
            }
        }, null, "File", "write", [this.fileName, text, this.position]);
};

/**
 * 将文件指针移动到指定的以byte为单位的具体数值的位置（Android，iOS）<br/>
 * 如果offset为负值，则从后往前移动文件指针。如果offset大于文件的总大小，文件指针则在文件的末尾
 * @example
        function success(writer) {
            //快速的把文件指针指向到文件末尾
            writer.seek(writer.length);
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
 * @method seek
 * @param {Number} offset 文件指针要移动到的位置,以byte为单位
 * @platform Android, iOS
 * @since 3.0.0
 */
FileWriter.prototype.seek = function(offset) {
    argscheck.checkArgs('n', 'FileWriter.seek', arguments);
    if (this.readyState === FileWriter.WRITING) {
        throw new FileError(FileError.INVALID_STATE_ERR);
    }

    if (!offset) {
        return;
    }

    // 从后往前移动
    if (offset < 0) {
        this.position = Math.max(offset + this.length, 0);
    }
    // offset 大于文件的总大小
    else if (offset > this.length) {
        this.position = this.length;
    }
    else {
        this.position = offset;
    }
};

/**
 * 截取文件到指定大小，文件末尾超过指定大小的内容会被删掉（Android，iOS）<br/>
 * @example
        function success(writer) {
            writer.truncate(10);
        };
        var fail = function(error) {
            console.log(error.code);
        };
        entry.createWriter(success, fail);
 * @method truncate
 * @param {Number} size 截取后剩下的文件大小
 * @platform Android, iOS
 * @since 3.0.0
 */
FileWriter.prototype.truncate = function(size) {
    argscheck.checkArgs('n', 'FileWriter.truncate', arguments);
    if (this.readyState === FileWriter.WRITING) {
        throw new FileError(FileError.INVALID_STATE_ERR);
    }

    this.readyState = FileWriter.WRITING;

    var me = this;

    if (typeof me.onwritestart === "function") {
        me.onwritestart(new ProgressEvent("writestart", {"target":this}));
    }

    exec(
        function(r) {
            if (me.readyState === FileWriter.DONE) {
                return;
            }

            me.readyState = FileWriter.DONE;

            me.length = r;
            me.position = Math.min(me.position, r);

            if (typeof me.onwrite === "function") {
                me.onwrite(new ProgressEvent("write", {"target":me}));
            }

            if (typeof me.onwriteend === "function") {
                me.onwriteend(new ProgressEvent("writeend", {"target":me}));
            }
        },
        function(e) {
            if (me.readyState === FileWriter.DONE) {
                return;
            }

            me.readyState = FileWriter.DONE;

            me.error = new FileError(e);

            if (typeof me.onerror === "function") {
                me.onerror(new ProgressEvent("error", {"target":me}));
            }

            if (typeof me.onwriteend === "function") {
                me.onwriteend(new ProgressEvent("writeend", {"target":me}));
            }
        }, null, "File", "truncate", [this.fileName, size]);
};

module.exports = FileWriter;
});

// file: lib/common/extension/Flags.js
define("xFace/extension/Flags", function(require, exports, module) {
var argscheck = require('xFace/argscheck');
/**
 * 该对象用于为{{#crossLink "DirectoryEntry"}}{{/crossLink}}对象的{{#crossLink "DirectoryEntry/getFile"}}{{/crossLink}}和
 * {{#crossLink "DirectoryEntry/getDirectory"}}{{/crossLink}}方法提供参数（Android, iOS）<br/>
 * @example
        var flags = new Flags(true, false);
 * @constructor
 * @param {Boolean} [create=false] 用于指示如果文件或目录不存在时是否创建该文件或目录
 * @param {Boolean} [exclusive=false] 该属性表示是否强制创建文件或目录
 * @class Flags
 * @platform Android, iOS
 * @since 3.0.0
 */
function Flags(create, exclusive) {
    argscheck.checkArgs('BB', 'Flags.Flags', arguments);
    /**
     * 用于指示如果文件或目录不存在时是否创建该文件或目录(Android, iOS)<br/>
     * @example
        //获取test目录，如果该目录不存在则创建它
        testDir = fileSystem.root.getDirectory("test", {create: true});
     * @property create
     * @type Boolean
     * @default false
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.create = create || false;

    /**
     * 该属性表示是否强制创建文件或目录(Android, iOS)<br/>
     * 注意：当只用exclusive属性时，它没有效果，它需要和create属性一起使用<br/>
     * 例如：和create一起使用时且create为true，当要创建的目标路径已经存在并且exclusive设为false时，它会导致文件或目录创建失败<br/>
     * 和create一起使用时且create为true，当要创建的目标路径已经存在并且exclusive设为true时，它会强制性的创建该目标路径<br/>
     * @example
        //只有在test.txt不存在时才创建该文件
        testFile = dataDir.getFile("test.txt", {create: true, exclusive: true});
     * @property exclusive
     * @type Boolean
     * @default false
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.exclusive = exclusive || false;
}

module.exports = Flags;
});

// file: lib/common/extension/Geolocation.js
define("xFace/extension/Geolocation", function(require, exports, module) {

/**
 * Geolocation提供设备地理位置信息，例如经纬度。通常定位源来自于GPS，IP地址，蜂窝网络地址等。<br/>
 * Geolocation API完全基于W3C Geolocation规范，xFace使用各设备和平台原生实现，接口请参考 <a target="_blank" href="http://www.w3.org/TR/geolocation-API/">Geolocation API Specification</a>
 * @class Geolocation
 * @platform Android, iOS
 * @since 3.0.0
 */

});

// file: lib/common/extension/InAppBrowser.js
define("xFace/extension/InAppBrowser", function(require, exports, module) {
    var exec = require('xFace/exec');
    var argscheck = require('xFace/argscheck');

    /**
     * InAppBrowser提供内置浏览器的功能<br/>
     * 该类不能通过new来创建相应的对象，只能通过调用window.open方法返回该类的实例对象，<br/>
     * window.open与{{#crossLink "InAppBrowser/open"}}{{/crossLink}}函数用法一样
     * @class InAppBrowser
     * @static
     * @platform Android、iOS
     * @since 3.0.0
     */

     /**
     * 当页面开始加载时，该事件被触发（Android, iOS）<br/>
     * @example
            var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler(event) {
                updateEvent('loadstart' + ":" + event.url);
            }
            inAppBrowser.addEventListener("loadstart", handler);
     * @event loadstart
     * @param {Object} event 事件对象
     * @param {String} event.type 事件类型，值为loadstart
     * @param {String} event.url 加载的url
     * @platform Android, iOS
     * @since 3.0.0
     */
     
     /**
     * 当页面开始停止加载时，该事件被触发（Android, iOS）<br/>
     * @example
            var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler(event) {
                updateEvent('loadstop' + ":" + event.url);
            }
            inAppBrowser.addEventListener("loadstop", handler);
     * @event loadstop
     * @param {Object} event 事件对象
     * @param {String} event.type 事件类型，值为loadstop
     * @param {String} event.url 加载的url
     * @platform Android, iOS
     * @since 3.0.0
     */
     
     /**
     * 当退出InAppBrowser时，该事件被触发（Android, iOS）<br/>
     * @example
            var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler(event) {
                console.log("InAppBrowser exit!");
            }
            inAppBrowser.addEventListener("exit", handler);
     * @event exit
     * @param {Object} event 事件对象
     * @param {String} event.type 事件类型，值为exit
     * @platform Android, iOS
     * @since 3.0.0
     */
     
     
    function InAppBrowser()
    {
       var _channel = require('xFace/channel');
       this.channels = {
            'loadstart': _channel.create('loadstart'),
            'loadstop' : _channel.create('loadstop'),
            'exit' : _channel.create('exit')
       };
    }

    InAppBrowser.prototype._eventHandler = function(event)
    {
        if (event.type in this.channels) {
            this.channels[event.type].fire(event);
        }
    }
    /**
     * 打开一个网页，通过window.open调用该方法
     @example
          function openInAppBrowser() {
          var browser = window.open('http://baidu.com', 'random_string');
          updateStatus("opening in the in app browser");
          window.setTimeout(function() {
                                browser.close();
                                updateStatus("closed browser");
                            },3000);
          }

          function openInAppBrowserWithoutAddressbar() {
              var browser = open("http://www.baidu.com", '_blank', 'location=no');
              updateStatus("opening in the in app browser without address bar");
              window.setTimeout(function() {
                                    browser.close();
                                    updateStatus("closed browser");
                                },3000);
          }

          function openInSystemBrowser() {
                var inAppBrowser = open("http://www.baidu.com", '_system');
                updateStatus("opening in system browser");
          }

          function openInXFace() {
              updateStatus("opening in xface");
              var browser = open("http://www.baidu.com", '_self');
          }
     * @method open
     * @param {String} strUrl 要打开的网页地址
     * @param {String} [strWindowName="_self"] 打开网页的目标窗口。参数值说明: <br/>
                             "\_self":    表示在当前xface页面打开<br/>
                             "\_system":  表示在系统浏览器打开<br/>
                             "\_blank"或其他未定义的值: 表示在内置的浏览器打开，也就是在新的窗口打开<br/>
     * @param {String} [strWindowFeatures=""] 特性列表。不能包含空格，格式形如"location=yes,foo=no,bar=yes"。目前只支持location，表示显示地址栏与否。
     * @return 返回InAppBrowser实例对象
     * @platform Android、iOS
     * @since 3.0.0
     */
    InAppBrowser.open = function(strUrl, strWindowName, strWindowFeatures)
    {
        argscheck.checkArgs('sSS','InAppBrowser.open', arguments);
        var iab = new InAppBrowser();
        var cb = function(eventname) {
           iab._eventHandler(eventname);
        }
        exec(cb, null,null,"InAppBrowser", "open", [strUrl, strWindowName, strWindowFeatures]);
        return iab;
    }
    /**
     * 关闭一个已在内置浏览器打开的网页（iOS）
     @example
          见open方法的示例
     * @method close
     * @platform Android、iOS
     * @since 3.0.0
     */
    InAppBrowser.prototype.close = function()
    {
        exec(null, null, null, "InAppBrowser", "close", []);
    }
    
    /**
     * 为InAppBrowser增加一个事件监听器,注意只有在内置的浏览器打开，事件监听器才有效
     @example
          见loadstart、loadstop、exit 事件的示例
     * @method addEventListener
     * @param {String} eventname 需要监听的事件，参数说明：<br/>
                                    "loadstart": 表示页面开始加载 <br/>
                                    “loadstop":  表示页面停止加载 <br/>
                                    "exit":      表示InAppBrowser关闭 <br/>
     * @param {Function} eventHandler 事件处理函数
     * @platform Android、iOS
     * @since 3.0.0
     */
    InAppBrowser.prototype.addEventListener = function(eventname, f)
    {
        argscheck.checkArgs('sf','InAppBrowser.addEventListener', arguments);
        if (eventname in this.channels) {
            this.channels[eventname].subscribe(f);
        }
    }
    
    /**
     * 去除InAppBrowser一个事件监听器
     @example
          见loadstart、loadstop、exit 事件的示例
     * @method removeEventListener
     * @example 
          var inAppBrowser = window.open('http://baidu.com', 'random_string');
            function handler() {
                console.log("page load stop!");
            }
            inAppBrowser.removeEventListener("loadstop", handler);
     * @param {String} eventname  需要监听的事件，参数说明：<br/>
                                    "loadstart": 表示页面开始加载 <br/>
                                    “loadstop":  表示页面停止加载 <br/>
                                    "exit":      表示InAppBrowser关闭 <br/>
     * @param {Function} eventHandler 事件处理函数
     * @platform Android、iOS
     * @since 3.0.0
     */
    InAppBrowser.prototype.removeEventListener = function(eventname, f)
    {
        argscheck.checkArgs('sf','InAppBrowser.removeEventListener', arguments);
        if (eventname in this.channels) {
            this.channels[eventname].unsubscribe(f);
        }
    }

    module.exports = InAppBrowser.open;


});

// file: lib/common/extension/LocalFileSystem.js
define("xFace/extension/LocalFileSystem", function(require, exports, module) {

/**
 * 该对象提供了获取根文件系统的方法（Android, iOS）<br/>
 * @class LocalFileSystem
 * @platform Android, iOS
 * @since 3.0.0
 */
var LocalFileSystem = function() {

};

/**
 * 表示用于不需要保证持久化的存储类型（Android，iOS）
 * @example
        LocalFileSystem.TEMPORARY;
 * @property TEMPORARY
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
LocalFileSystem.TEMPORARY = 0;  //临时文件

/**
 * 表示用于不经过应用程序或者用户许可，就无法通过用户代理去移除的存储类型（Android，iOS）
 * @example
        LocalFileSystem.PERSISTENT;
 * @property PERSISTENT
 * @type Number
 * @final
 * @platform Android，iOS
 * @since 3.0.0
 */
LocalFileSystem.PERSISTENT = 1; //持久文件

module.exports = LocalFileSystem;
});

// file: lib/common/extension/Media.js
define("xFace/extension/Media", function(require, exports, module) {

/**
 * 该模块提供多媒体的功能，包括音频和视频
 * @module media
 * @main media
 */
var argscheck = require('xFace/argscheck'),
    utils = require('xFace/utils'),
    exec = require('xFace/exec');

var mediaObjects = {};

/**
 *  Media 扩展提供播放音频和录音的功能（Android, iOS）
 @example
      var src = "test.mp3";
      var localAudio = new Media(src, onSuccess, onError, onStatusChange);

      function onSuccess() {}

      function onError(error) {
          alert('Error : ' + ERROR_MSG[error.code]);
      }

      function onStatusChange(state) {
          alert("Status now is : " + Media.MEDIA_MSG[state]);
      }

 * @class Media
 * @constructor
 * @param {String} [src] 源文件地址
 * @param {Function} [successCallback]   成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @param {MediaError} errorCallback.error   error参数，详情请参见{{#crossLink "MediaError"}}{{/crossLink}}
 * @param {Function} [statusCallback]  状态变化回调
 * @param {Number} statusCallback.state 状态值，包括Media.MEDIA_STARTING、Media.MEDIA_RUNNING和Media.MEDIA_PAUSED等
 * @platform Android, iOS
 * @since 3.0.0
 */
var Media = function(src, successCallback, errorCallback, statusCallback) {
    argscheck.checkArgs('SFFF', 'Media.Media', arguments);
    this.id = utils.createUUID();
    mediaObjects[this.id] = this;
    this.src = src;
    this.successCallback = successCallback;
    this.errorCallback = errorCallback;
    this.statusCallback = statusCallback;
    this._duration = -1;
    this._position = -1;
};

Media.MEDIA_STATE = 1;
Media.MEDIA_DURATION = 2;
Media.MEDIA_POSITION = 3;
Media.MEDIA_ERROR = 4;

/**
 * 音频未知状态的常量 (Android, iOS).
 * @example
        Media.MEDIA_NONE
 * @property MEDIA_NONE
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.MEDIA_NONE = 0;

/**
 * 音频准备播放状态的常量 (Android, iOS).
 * @example
        Media.MEDIA_STARTING
 * @property MEDIA_STARTING
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.MEDIA_STARTING = 1;

/**
 * 音频正在播放状态的常量 (Android, iOS).
 * @example
        Media.MEDIA_RUNNING
 * @property MEDIA_RUNNING
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.MEDIA_RUNNING = 2;

/**
 * 音频暂停状态的常量 (Android, iOS).
 * @example
        Media.MEDIA_PAUSED
 * @property MEDIA_PAUSED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.MEDIA_PAUSED = 3;

/**
 * 音频停止状态的常量 (Android, iOS).
 * @example
        Media.MEDIA_STOPPED
 * @property MEDIA_STOPPED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.MEDIA_STOPPED = 4;

/**
 * 音频状态的对应字符串信息 (Android, iOS).
 * @example
       function onStatusChange(state) {
          alert("Status now is : " + Media.MEDIA_MSG[state]);
       }
 * @property MEDIA_MSG
 * @type Array
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.MEDIA_MSG = ["None", "Starting", "Running", "Paused", "Stopped"];

// "static" 函数返回已存在的对象.
Media.get = function(id) {
    return mediaObjects[id];
};

/**
 * 播放音频文件（Android, iOS）
 @example
      media.play();
 * @method play
 * @param {Object} [options] 可选参数（Android无效）<br/>
 * @param {boolean} [options.playAudioWhenScreenIsLocked=true] 表示是否允许锁屏时播放音频
 * @param {Number} [options.numberOfLoops=0] 播放循环次数
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.play = function(options) {
    argscheck.checkArgs('O', 'Media.play', arguments);
    exec(null, null, null, "Audio", "play", [this.id, this.src, options]);
};

/**
 * 停止正在播放的音频（Android, iOS）
 @example
      media.stop();
 * @method stop
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.stop = function() {
    var me = this;
    exec(
        function() {
            me._position = 0;
            me.successCallback();
        },
        this.errorCallback,
        null,
        "Audio", "stop", [this.id]
    );
};

/**
 * 跳转到指定时间点（Android, iOS）
 @example
      media.seekTo(50000);
 * @method seekTo
 * @param {Number} milliseconds 时间点，以毫秒为单位
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.seekTo = function(milliseconds) {
    argscheck.checkArgs('n', 'Media.seekTo', arguments);
    var me = this;
    exec(
        function(p) {
            me._position = p;
        },
        this.errorCallback,
        null,
        "Audio", "seekTo", [this.id, milliseconds]
    );
};

/**
 * 暂停正在播放的音频（Android, iOS）
 @example
      media.pause();
 * @method pause
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.pause = function() {
    exec(null, this.errorCallback, null, "Audio", "pause", [this.id]);
};

/**
 * 获取音频的片长（Android, iOS）<br/>
 * 该函数仅对处于下列播放状态的 audio 有效：playing, paused 或者 stopped.
 @example
      var duration = media.getDuration();
 * @method getDuration
 * @return {Number}    片长已知时则返回实际值，否则返回 -1，以秒为单位
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.getDuration = function() {
    return this._duration;
};

/**
 * 获取音频当前的播放位置（Android, iOS）
 @example
      media = new Media(src, onSuccess, onError, onStatusChange);
      // 获取音频的当前播放位置
      media.getCurrentPosition(
          // 成功回调
          function(position) {
              if (position > -1) {
                  setAudioPosition((position) + " sec");
              }
          },
          // 失败回调
          function() {
              console.log("Error getting pos");
              setAudioPosition("Error");
          }
      );
 * @method getCurrentPosition
 * @param {Function} successCallback 成功回调函数
 * @param {String} successCallback.position 当前的播放位置，以秒为单位
 * @param {Function} [errorCallback] 失败回调函数
 * @param {String} errorCallback.error 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.getCurrentPosition = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'Media.getCurrentPosition', arguments);
    var me = this;
    exec(
        function(position) {
            me._position = position;
            successCallback(position);
        },
        errorCallback,
        null,
        "Audio", "getCurrentPosition", [this.id]
    );
};

/**
 * 设置音频的播放音量（Android, iOS）
 @example
      media.setVolume();
 * @method setVolume
 * @param {Number} value 音量值(取值范围从0.0 到 1.0)
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.setVolume = function(value) {
    argscheck.checkArgs('n', 'Media.setVolume', arguments);
    exec(null,this.errorCallback,null,"Audio", "setVolume", [this.id,value]);
};

/**
 * 释放资源（Android, iOS）
 @example
      media.release();
 * @method release
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.release = function() {
    exec(null, this.errorCallback, null, "Audio", "release", [this.id]);
};

/**
 * 开始录音（Android, iOS）
 @example
      // 录音
      var mediaRec;
      function startRecord() {
          mediaRec = new Media("recording.mp3", onSuccess, onError);
          mediaRec.startRecord();
      }
 * @method startRecord
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.startRecord = function() {
    exec(this.successCallback, this.errorCallback, null, "Audio", "startRecording", [this.id, this.src]);
};

/**
 * 停止录音（Android, iOS）
 @example
      function stopRecord() {
          if (mediaRec != null) {
              mediaRec.stopRecord();
          }
      }
 * @method stopRecord
 * @platform Android, iOS
 * @since 3.0.0
 */
Media.prototype.stopRecord = function() {
    exec(this.successCallback, this.errorCallback, null, "Audio", "stopRecording", [this.id]);
};

/**
 * Audio 的状态回调.
 * PRIVATE
 *
 * @param id            audio 对象的 id (string)
 * @param status        状态码 (int)
 * @param msg           状态信息 (string)
 */
Media.onStatus = function(id, msg, value) {
    var media = mediaObjects[id];
    // 如果状态有更新
    if (msg === Media.MEDIA_STATE) {
        if (value === Media.MEDIA_STOPPED) {
            if (media.successCallback) {
                media.successCallback();
            }
        }

        if (media.statusCallback) {
            media.statusCallback(value);
        }
    } else if (msg === Media.MEDIA_DURATION) {
        media._duration = value;
    } else if (msg === Media.MEDIA_ERROR) {
        if (media.errorCallback) {
            media.errorCallback(value);
        }
    } else if (msg === Media.MEDIA_POSITION) {
        media._position = value;
    }
};

module.exports = Media;

});

// file: lib/common/extension/MediaError.js
define("xFace/extension/MediaError", function(require, exports, module) {

/**
 * 此类包含了所有 Media 错误类型的详细描述（Android, iOS）<br/>
 * 该类不能通过new来创建相应的对象，Media的失败回调会返回该对象的实例
 * @class MediaError
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */

/**
 * 此类包含了所有 Media errors 的相关信息.
 *
 * @constructor
 */
var MediaError = function(code, msg) {

/**
 * 错误码 (Android, iOS).<br/>
 * 所有的错误类型请参考 {{#crossLink "MediaError"}}{{/crossLink}}中定义的错误码
 * @example
        function errorCallBack(mediaError)
        {
            switch(mediaError.code)
            {
                case MediaError.MEDIA_ERR_NONE_ACTIVE:
                    //handle none atctive error
                    alert(mediaError.message);
                    break;
                case MediaError.MEDIA_ERR_ABORTED:
                    //
                    break;
                case MediaError.MEDIA_ERR_NETWORK:
                    //
                    break;
                case MediaError.MEDIA_ERR_DECODE:
                    //
                    break;
                case MediaError.MEDIA_ERR_NONE_SUPPORTED:
                    //
                    break;
            }
        }
 * @property code
 * @type Number
 * @platform Android, iOS
 * @since 3.0.0
 */
this.code = (code !== undefined ? code : null);

/**
 * 错误码对应的错误描述信息 (Android, iOS).<br/>
 * 具体用法请参见MediaError.code的示例
 * @property message
 * @type String
 * @platform Android, iOS
 * @since 3.0.0
 */
this.message = msg || "";

};

/**
 * 非活动状态的错误码 (Android, iOS).
 * @property MEDIA_ERR_NONE_ACTIVE
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_NONE_ACTIVE    = 0;

/**
 * 被中止的错误码 (Android, iOS).
 * @property MEDIA_ERR_ABORTED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_ABORTED        = 1;

/**
 * 网络连接失败的错误码 (Android, iOS).
 * @property MEDIA_ERR_NETWORK
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_NETWORK        = 2;

/**
 * 音频解码出错的错误码 (Android, iOS).
 * @property MEDIA_ERR_DECODE
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_DECODE         = 3;

/**
 * 文件格式不支持的错误码 (Android, iOS).
 * @property MEDIA_ERR_NONE_SUPPORTED
 * @type Number
 * @final
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
MediaError.MEDIA_ERR_NONE_SUPPORTED = 4;

module.exports = MediaError;
});

// file: lib/common/extension/MediaFile.js
define("xFace/extension/MediaFile", function(require, exports, module) {
var utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    File = require('xFace/extension/File'),
    CaptureError = require('xFace/extension/CaptureError'),
    argscheck = require('xFace/argscheck');
 /**
  * 封装了多媒体采集文件的属性（Android, iOS）<br/>
  * @class MediaFile
  * @constructor
  * @extends File
  * @param {String} name 文件名, 不包含路径信息
  * @param {String} fullPath  文件的绝对路径，包含文件名
  * @param {String} type  MIME类型，应该符合RFC2046规范，例如："video/3gpp"，"video/quicktime"，"image/jpeg"，"audio/amr"，"audio/wav"
  * @param {Date} lastModifiedDate 文件的最新修改时间
  * @param {Number} size 文件大小（以比特为单位）
  * @platform Android, iOS
  * @since 3.0.0
  */
var MediaFile = function(name, fullPath, type, lastModifiedDate, size){
    MediaFile.__super__.constructor.apply(this, arguments);
};

utils.extend(MediaFile, File);

/**
 * 请求一个指定路径和类型的文件的格式信息（Android, iOS）<br/>
 * @example
        function getFormatData() {
            mediaFile.getFormatData(successCallback, errorCallback);
        }
        function successCallback(media) {
            console.log("media.height = " + media.height);
            console.log("media.width = " + media.width);
        }
 * @method getFormatData
 * @param {Function} successCallback 成功回调函数
 * @param {MediaFileData} successCallback.media 多媒体文件的格式信息
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 错误信息
 * @platform Android, iOS
 * @since 3.0.0
 */
MediaFile.prototype.getFormatData = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'mediaFile.getFormatData', arguments);
    if (typeof this.fullPath === "undefined" || this.fullPath === null) {
        errorCallback(new CaptureError(CaptureError.CAPTURE_INVALID_ARGUMENT));
    } else {
        exec(successCallback, errorCallback, null, "Capture", "getFormatData", [this.fullPath, this.type]);
    }
};

module.exports = MediaFile;
});

// file: lib/common/extension/MediaFileData.js
define("xFace/extension/MediaFileData", function(require, exports, module) {

/**
 * 封装了多媒体文件的格式信息（Android, iOS）
 * @class MediaFileData
 * @platform Android, iOS
 * @since 3.0.0
 */
var MediaFileData = function(codecs, bitrate, height, width, duration){
    /**
      * 音频/视频文件内容的实际格式（两个平台都不支持）
      */
    this.codecs = codecs || null;
    /**
     * 文件内容的平均比特率(iOS)<br/>
     * 仅支持iOS4以上的设备，对于图像/视频文件，属性值为0
     * @example
            function getFormatData() {
                mediaFile.getFormatData(successCallback, errorCallback);
            }
            function successCallback(media) {
                console.log("media.bitrate = " + media.bitrate);
            }
     * @property bitrate
     * @type Number
     * @default 0
     * @platform iOS
     * @since 3.0.0
     */
    this.bitrate = bitrate || 0;
    /**
     * 图像/视频的高度，音频剪辑的该属性值为0（以像素为单位）(Android, iOS)<br/>
     * @example
            function successCallback(media) {
                console.log("media.height = " + media.height);
            }
     * @property height
     * @type Number
     * @default 0
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.height = height || 0;
    /**
     * 图像/视频的宽度，音频剪辑的该属性值为0（以像素为单位）(Android, iOS)<br/>
     * @example
            function successCallback(media) {
                console.log("media.width = "+media.width);
            }
     * @property width
     * @type Number
     * @default 0
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.width = width || 0;
    /**
     * 视频/音频剪辑时长，图像剪辑的该属性值为0（以秒为单位）(Android, iOS)<br/>
     * @example
            function successCallback(media) {
                console.log("media.duration = "+media.duration);
            }
     * @property duration
     * @type Number
     * @default 0
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.duration = duration || 0;
};

module.exports = MediaFileData;
});

// file: lib/common/extension/Message.js
define("xFace/extension/Message", function(require, exports, module) {

/**
 * 该类定义了信息的一系列属性（Android, iOS）<br/>
 * 相关参考： {{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @class Message
 * @namespace xFace
 * @constructor
 * @param {String} [messageId=null] 唯一标识符，仅在 Native端设置
 * @param {String} [subject=null] 信息的标题
 * @param {String} [body=null] 信息的内容
 * @param {String} [destinationAddresses=null] 目的地址
 * @param {String} [messageType=null] 信息的类型（短信，彩信，Email），取值范围见{{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @param {Date} [date=null] 信息的日期
 * @param {Boolean} [isRead=null] 信息是否已读
 * @platform Android, iOS
 * @since 3.0.0
 */
var Message = function(messageId, subject, body, destinationAddresses, messageType, date, isRead) {

/**
 * 唯一标识符，仅在 Native 端设置（Android, iOS）
 * @property messageId
 * @type String
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.messageId = messageId || null;
/**
 * 信息的标题（Android, iOS）
 * @property subject
 * @type String
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.subject = subject || null;
/**
 * 信息的内容（Android, iOS）
 * @property body
 * @type String
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.body = body || null;
/**
 * 目的地址（Android, iOS）
 * @property destinationAddresses
 * @type String
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.destinationAddresses = destinationAddresses || null;
/**
 * 信息的类型（短信，彩信，Email），目前支持短信和Email（Android, iOS），取值范围见 {{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @property messageType
 * @type String
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.messageType = messageType || null;
/**
 * 信息的日期（Android, iOS）
 * @property date
 * @type Date
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.date = date || null;
/**
 * 信息是否已读标志（Android, iOS）
 * @property isRead
 * @type Boolean
 * @platform Android, iOS
 * @since 3.0.0
 */
    this.isRead = isRead || null;
};

module.exports = Message;
});

// file: lib/common/extension/MessageTypes.js
define("xFace/extension/MessageTypes", function(require, exports, module) {

var MessageTypes = function() {
};

/**
 * 邮件（Android, iOS）
 * @property EmailMessage
 * @type String
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
MessageTypes.EmailMessage = "Email";
/**
 * 彩信（Android, iOS）
 * @property MMSMessage
 * @type String
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
MessageTypes.MMSMessage = "MMS";
/**
 * 短信（Android, iOS）
 * @property SMSMessage
 * @type String
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
MessageTypes.SMSMessage = "SMS";

module.exports = MessageTypes;
});

// file: lib/common/extension/Messaging.js
define("xFace/extension/Messaging", function(require, exports, module) {

/**
 * 该类实现了对短信的一系列操作，包括新建短信，发送短信，查找短信等（Android, iOS）<br/>
 * 该类不能通过new来创建相应的对象，只能通过xFace.Messaging对象来直接使用该类中定义的方法<br/>
 * 相关参考： {{#crossLink "xFace.Message"}}{{/crossLink}}, {{#crossLink "xFace.MessageTypes"}}{{/crossLink}}, {{#crossLink "xFace.MessageFolderTypes"}}{{/crossLink}}
 * @class Messaging
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    Message = require('xFace/extension/Message');

var Messaging = function() {
};

/**
 * 新建信息，根据messageType新建信息，目前支持短息和Email类型（Android, iOS）<br/>
 * @example
        xFace.Messaging.createMessage(xFace.MessageTypes.SMSMessage, successCallback, errorCallback);
        function successCallback(message){alert(message.type);}
        function errorCallback(){alert("failed");}
 * @method createMessage
 * @param {String} messageType 信息类型（如MMS,SMS,Email），取值范围见{{#crossLink "xFace.MessageTypes"}}{{/crossLink}}
 * @param {Function} successCallback 成功回调函数
 * @param {Message} successCallback.message 生成的信息对象，参见 {{#crossLink "xFace.Message"}}{{/crossLink}}
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
Messaging.prototype.createMessage = function(messageType, successCallback, errorCallback) {
    argscheck.checkArgs('sfF', 'xFace.Messaging.createMessage', arguments);
    //TODO:根据messageType创建不同类型的信息，目前只处理了短消息
    var MessageTypes = require('xFace/extension/MessageTypes');
    if((messageType != MessageTypes.EmailMessage&&
       messageType != MessageTypes.MMSMessage&&
       messageType != MessageTypes.SMSMessage)){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    var result = new Message();
    result.messageType = messageType;
    successCallback(result);
};

/**
 * 发送信息，目前支持发送短信和Email（Android, iOS）<br/>
 * @example
        xFace.Messaging.sendMessage (message, success, errorCallback);
        function success(statusCode) {alert("success : " + statusCode);}
        function errorCallback(errorCode){alert("fail : " + errorCode);

 * @method sendMessage
 * @param {Message} message 要发送的信息对象，参见{{#crossLink "xFace.Message"}}{{/crossLink}}
 * @param {Function} [successCallback] 成功回调函数
 * @param {Number} successCallback.code   状态码: 0：发送成功；
 * @param {Function} [errorCallback]   失败回调函数
 * @param {Number} errorCallback.code   状态码: 1：通用错误；2：无服务；3：没有PDU提供；4：天线关闭；
 * @platform Android, iOS
 * @since 3.0.0
 */
Messaging.prototype.sendMessage = function(message, successCallback, errorCallback){
    argscheck.checkArgs('oFF', 'xFace.Messaging.sendMessage', arguments);
    exec(successCallback, errorCallback, null, "Messaging", "sendMessage", [message.messageType, message.destinationAddresses, message.body, message.subject]);
};

module.exports = new Messaging();
});

// file: lib/common/extension/Metadata.js
define("xFace/extension/Metadata", function(require, exports, module) {

/**
 * 该接口提供了文件或目录的状态信息（Android, iOS）<br/>
 * 可以通过{{#crossLink "DirectoryEntry"}}{{/crossLink}}对象或者
 * {{#crossLink "FileEntry"}}{{/crossLink}}对象的getMetadata方法获取Metadata的实例
 * @class Metadata
 * @platform Android, iOS
 * @since 3.0.0
 */
var Metadata = function(time) {
    /**
     * 文件或目录的最后修改时间(Android, iOS)<br/>
     * @example
        function success(metadata) {
            console.log("Last Modified Time: " + metadata.modificationTime);
        }
        //请求此目录的metadata对象
        dirEntry.getMetadata(success, null);
     * @property modificationTime
     * @type Date
     * @default null
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.modificationTime = (typeof time != 'undefined'?new Date(time):null);
};

module.exports = Metadata;
});

// file: lib/common/extension/Notification.js
define("xFace/extension/Notification", function(require, exports, module) {

  /**
  * 该类提供一系列基础api，用于发出系统通知信息和弹出系统提示框（Android, iOS）<br/>
  * 该类不能通过new来创建相应的对象，只能通过navigator.notification对象来直接使用该类中定义的方法
  * @class Notification
  * @platform Android, iOS
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
    var notification = function() {};

/**
 * 弹出一个本地的alert对话框，开发者可以设定对话框的标题（Android, iOS）<br/>
 * @example
        function alertCallback(){
            console.log("Alert dismissed.");
        }
        var message = "You pressed alert.";
        var title = "Alert Dialog";
        var button = "Continue";
        navigator.notification.alert(message, alertCallback, title, button);
 * @method alert
 * @param {String} [message] 对话框要显示的消息
 * @param {Function} [alertCallback] 用户点击按钮后的回调函数
 * @param {String} [title="Alert"] 对话框的标题
 * @param {String} [buttonLabel="OK"] 对话框的按钮名
 * @platform Android, iOS
 * @since 3.0.0
 */
notification.prototype.alert = function(message, alertCallback, title, buttonLabel){
    argscheck.checkArgs('SFSS', 'navigator.notification.alert', arguments);
    var _title = (title || "Alert");
    var _buttonLabel = (buttonLabel || "OK");
    exec(alertCallback, null, null, "Notification", "alert", [message, _title, _buttonLabel]);
};

 /**
 * 弹出一个本地的confirm对话框，开发者可以设定对话框的标题和按钮，用户点击结果会返回给回调函数（Android, iOS）<br/>
 * @example
        var message = "You pressed confirm.";
        var title = "Confirm Dialog";
        var buttons = "Yes,No,Maybe";
        function alertCallback(r) {
            console.log("You selected " + r);
            alert("You selected " + (buttons.split(","))[r-1]);
        }
        navigator.notification.confirm(message, alertCallback, title, buttons);
 * @method confirm
 * @param {String} [message] 对话框要显示的消息
 * @param {Function} [alertCallback] 用户点击按钮后的回调函数
 * @param {Number} alertCallback.selectedIndex 用户选择的按钮索引号（从1开始）
 * @param {String} [title="Confirm"] 对话框的标题
 * @param {String} [buttonLabel="OK,Cancel"] 对话框上所有按钮标签，用逗号隔开，与对话框上的按钮名一一对应
 * @platform Android, iOS
 * @since 3.0.0
 */
notification.prototype.confirm = function(message, alertCallback, title, buttonLabels){
    argscheck.checkArgs('SFSS', 'navigator.notification.confirm', arguments);
    var _title = (title || "Confirm");
    var _buttonLabels = (buttonLabels || "OK,Cancel");
    exec(alertCallback, null, null, "Notification", "confirm", [message, _title, _buttonLabels]);
};

 /**
 * 调用系统接口使设备发出震动提示（Android, iOS）<br/>
 * @example
        navigator.notification.vibrate(1000);
 * @method vibrate
 * @param {Number} millseconds 震动的毫秒数，在iOS上该参数无效
 * @platform Android, iOS
 * @since 3.0.0
 */
notification.prototype.vibrate = function(millseconds) {
    argscheck.checkArgs('n', 'navigator.notification.vibrate', arguments);
    exec(null, null, null, "Notification", "vibrate", [millseconds]);
};

 /**
 * 调用系统接口使设备将发出蜂鸣声.（Android, iOS）<br/>
 * @example
        navigator.notification.beep(3);
 * @method beep
 * @param {Number} counts 蜂鸣声的重复次数，在iOS上该参数无效
 * @platform Android, iOS
 * @since 3.0.0
 */
notification.prototype.beep = function(counts) {
    argscheck.checkArgs('n', 'navigator.notification.beep', arguments);
    exec(null, null, null, "Notification", "beep", [counts]);
};

module.exports = new notification();

});

// file: lib/common/extension/ProgressEvent.js
define("xFace/extension/ProgressEvent", function(require, exports, module) {
 
  /**
  * 该类用于表示进度事件信息（Android, iOS）<br/>
  * 应用场景参考{{#crossLink "FileTransfer"}}{{/crossLink}},{{#crossLink "xFace.AdvancedFileTransfer"}}{{/crossLink}},{{#crossLink "FileReader"}}{{/crossLink}},{{#crossLink "FileWriter"}}{{/crossLink}}
  * @class ProgressEvent
  * @platform Android, iOS
  * @since 3.0.0
  */
 var ProgressEvent = (function() {
    return function ProgressEvent(type, dict) {
        /**
         * 事件类型（Android, iOS）<br/>
         * @property type
         * @type String
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.type = type;
        this.bubbles = false;
        this.cancelBubble = false;
        /**
         * 用于标识报进度的操作是否能够被取消（Android, iOS）
         * @property cancelable
         * @default false
         * @type Boolean
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.cancelable = false;
        /**
         * 用于标识数据总长度是否可获取（Android, iOS）
         * @property lengthAvailable
         * @default false
         * @type Boolean
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.lengthAvailable = false;
        /**
         * 已经处理/加载的数据长度，单位byte（Android, iOS）
         * @property loaded
         * @default 0
         * @type Number
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.loaded = dict && dict.loaded ? dict.loaded : 0;
        /**
         * 要处理/加载的数据总长度，单位byte（lengthAvailable为true时有效）（Android, iOS）
         * @property total
         * @default 0
         * @type Number
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.total = dict && dict.total ? dict.total : 0;
        /**
         * 进度事件的目标对象（Android, iOS）
         * @property target
         * @default null
         * @type Object
         * @platform Android, iOS
         * @since 3.0.0
         */
        this.target = dict && dict.target ? dict.target : null;
    };
})();

module.exports = ProgressEvent;
});

// file: lib/common/extension/PushNotification.js
define("xFace/extension/PushNotification", function(require, exports, module) {

/**
* 该类提供向手机推送消息的功能(Android, iOS)<br/>
* 该类不能通过new来创建相应的对象,只能通过xFace.PushNotification对象来直接使用该类定义的方法
* @class PushNotification
* @static
* @platform Android,iOS
* @since 3.0.0
*/
var exec = require('xFace/exec');
var argscheck = require('xFace/argscheck');
var PushNotification = function() {
    this.onReceived = null;
};

/**
* 当收到推送通知的回调函数
*/
PushNotification.prototype.fire = function(pushString) {
    if (this.onReceived) {
        this.onReceived(pushString);
    }
};

/**
* 注册一个监听器, 当手机收到推送消息时，该监听器会被回调(Android, iOS)<br/>
* @example
        xFace.PushNotification.registerOnReceivedListener(printPushData);
        function printPushData(info){
                alert(info);
            }
*@method registerOnReceivedListener
*@param {Function} listener 收到通知的监听
*@param {String} listener.message 收到通知的内容
*@platform Android, iOS
*@since 3.0.0
*/
PushNotification.prototype.registerOnReceivedListener = function(listener) {

    argscheck.checkArgs('f', 'PushNotification.registerOnReceivedListener', arguments);
    this.onReceived = listener;
    exec(null, null, null, "PushNotification", "registerOnReceivedListener", []);

};

/**
* 获取手机设备的唯一标识符(以UUID作为唯一标识符)(Android, iOS)<br/>
* @example
        xFace.PushNotification.getDeviceToken(success, error);
        function success(deviceToken){
                alert(deviceToken);
            };
        function error(err){
                alert(err);
            };
*@method getDeviceToken
*@param {Function} [successCallback] 成功回调函数
*@param {String} successCallback.deviceToken 手机的唯一标识符
*@param {Function} [errorCallback] 失败回调函数
*@param {String} errorCallback.err 失败的描述信息
*@platform Android, iOS
*@since 3.0.0
*/
PushNotification.prototype.getDeviceToken = function(successCallback, errorCallback) {
    if (typeof successCallback !== "function") {
       console.log("PushNotification Error: successCallback is not a function");
       return;
    }

    if (errorCallback && (typeof errorCallback !== "function")) {
       console.log("PushNotification Error: errorCallback is not a function");
       return;
    }
    exec(successCallback, errorCallback, null, "PushNotification", "getDeviceToken", []);
};

module.exports = new PushNotification();
});

// file: lib/common/extension/Security.js
define("xFace/extension/Security", function(require, exports, module) {

 /**
  * 该类提供一系列基础api，用于字符串或者文件的加解密操作（Android, iOS）<br/>
  * 该类不能通过new来创建相应的对象，只能通过xFace.Security对象来直接使用该类中定义的方法
  * @class Security
  * @platform Android, iOS
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var Security = function() {};

/**
 * 根据传入的密钥对明文字符串加密，并返回加密后的密文（Android, iOS）<br/>
 * @example
        xFace.Security.encrypt(key, plainText, encryptSuccess, encryptError);
        function encryptSuccess(encryptedText) {
            alert("encryptedContent:" + encryptedText);
        }
        function encryptError(errorcode) {
            alert("Encrypt file error:" + errorcode);
        }
 * @method encrypt
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} plainText 需要加密的明文
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.encryptedText 该参数用于返回加密后的密文内容
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回加密错误码
 * <ul>返回的加密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @platform Android, iOS
 */
Security.prototype.encrypt = function(key, plainText, successCallback, errorCallback){
    argscheck.checkArgs('ssFF', 'xFace.Security.encrypt', arguments);
    if(key.length < 8 ||  plainText.length == 0){
        if(errorCallback) {
            errorCallback("Wrong parameter of encrypt! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "encrypt", [key, plainText]);
};

/**
 * 根据传入的密钥对密文解密，并返回解密后的明文（Android, iOS）<br/>
 * @example
        xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError);
        function decryptSuccess(decryptedText) {
            alert("decryptedContent:" + decryptedText);
        }
        function decryptError(errorcode) {
            alert("Decrypt file error:" + errorcode);
        }
 * @method decrypt
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} encryptedText 需要解密的密文
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.decryptedText 该参数用于返回解密后的明文内容
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回解密错误码
 * <ul>返回的解密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @platform Android, iOS
 */
Security.prototype.decrypt = function(key, encryptedText, successCallback, errorCallback){
    argscheck.checkArgs('ssFF', 'xFace.Security.decrypt', arguments);
    if(key.length < 8 || encryptedText.length == 0){
        if(errorCallback) {
            errorCallback("Wrong parameter of decrypt! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "decrypt", [key, encryptedText]);
};

/**
 * 根据传入的密钥加密文件，并返回新生成加密文件的路径（Android，iOS）<br/>
 * @example
        var sourceFilePath = "encrypt_source.txt";
        var targetFilePath = "encrypt_target.txt";
        xFace.Security.encryptFile(key, sourceFilePath, targetFilePath, success, error);
        function success(entry) {
            alert("Encrypt file path:" + entry);
        }
        function error(errorcode) {
            alert("Encrypt file error:" + errorcode);
        }
 * @method encryptFile
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} sourceFilePath 要加密的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {String} targetFilePath 用户指定加密后生成的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.path 该参数用于返回新生成加密文件的路径
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回加密错误码
 * <ul>返回的加密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @platform Android, iOS
 */
Security.prototype.encryptFile = function(key, sourceFilePath, targetFilePath, successCallback, errorCallback){
    argscheck.checkArgs('sssFF', 'xFace.Security.decrypt', arguments);
    if(key.length < 8){
        if(errorCallback) {
            errorCallback("Wrong parameter of encryptFile! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "encryptFile", [key, sourceFilePath,targetFilePath]);
};

/**
 * 根据传入的密钥解密文件，返回解密后的新生成文件的路径（Android，iOS）<br/>
 * @example
        var sourceFilePath = "decrypt_source.txt";
        var targetFilePath = "decrypt_target.txt";
        xFace.Security.decryptFile(key, sourceFilePath,targetFilePath, success, error);
        function success(entry) {
            alert("Decrypt file path:" + entry);
        }
        function error(errorcode) {
            alert("Decrypt file error:" + errorcode);
        }
 * @method decryptFile
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} sourceFilePath 要解密的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {String} targetFilePath 用户指定解密后生成的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.path 该参数用于返回新生成解密文件的路径
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回解密错误码
 * <ul>返回的解密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @platform Android, iOS
 */
Security.prototype.decryptFile = function(key, sourceFilePath, targetFilePath, successCallback, errorCallback){
    argscheck.checkArgs('sssFF', 'xFace.Security.decrypt', arguments);
    if(key.length < 8) {
        if(errorCallback) {
            errorCallback("Wrong parameter of decryptFile! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "decryptFile", [key, sourceFilePath,targetFilePath]);
};

module.exports = new Security();
});

// file: lib/common/extension/Setting.js
define("xFace/extension/Setting", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    xFace = require('xFace');
var utils = require("xFace/utils");
var gstorage = require('xFace/localStorage');


 /**
 * 此类用于保存app之间静态共享的数据，如xFace.Setting.setPreference("key","value")用来保存一个键值对。
 * 此类不能通过new来创建相应的对象，只能通过xFace.Setting对象来直接使用该类中定义的方法(Android,iOS)
 * @class Setting
 * @static
 * @platform Android,iOS
 * @since 3.0.0
 */
var Setting  = function() {};

var m_localStorage_setItem = gstorage.getOriginalLocalStorage().setItem;
var m_localStorage_getItem = gstorage.getOriginalLocalStorage().getItem;
var m_localStorage_removeItem = gstorage.getOriginalLocalStorage().removeItem;

var keyPrefix = "_";
var keySeparator = ",";

var id = "settingPreference";

function getNewKey(id, key){
    var newKey = id + keyPrefix + key;
    return newKey;
}

/**
 * 存储一个键值对(Android,iOS)
 * @example
        xFace.Setting.setPreference("key", "value");
 * @method setPreference
 * @param {String} key         键值对的键
 * @param {String} value       键值对的键所对应的数据
 * @platform Android,iOS
 * @since 3.0.0
 */
Setting.prototype.setPreference = function(key, value){
    argscheck.checkArgs('ss', 'xFace.Setting.setPreference', arguments);
    var newKey = getNewKey(id, key);
    m_localStorage_setItem.call(localStorage, newKey, value);
    //更新以id为键值的数据，其中存储的是所有属于Setting的key值
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null === keyList || "" === keyList){
        keyList = key;
        m_localStorage_setItem.call(localStorage, id, keyList);
    }else{
        var isNewKey = true;
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                isNewKey = false;
                break;
            }
        }
        if(isNewKey){
            keyList = keyList + keySeparator + key;
            m_localStorage_setItem.call(localStorage, id, keyList);
        }
    }
};

/**
 * 获取一个键对应的值(Android,iOS)
 * @example
        xFace.Setting.getPreference("key");
 * @method getPreference
 * @param {String} key         键值对的键
 * @return {String}         返回指定键所对应的键值
 * @platform Android,iOS
 * @since 3.0.0
 */
Setting.prototype.getPreference = function(key){
    argscheck.checkArgs('s', 'xFace.Setting.getPreference', arguments);
    var newKey = getNewKey(id, key);
    var value = m_localStorage_getItem.call(localStorage, newKey);
    return value;
};

/**
 * 删除配置中的一个键及其对应的值(Android,iOS)
 * @example
        xFace.Setting.removePreference("key");
 * @method removePreference
 * @param {String} key         键值对的键
 * @platform Android,iOS
 * @since 3.0.0
 */
Setting.prototype.removePreference = function(key){
    argscheck.checkArgs('s', 'xFace.Setting.removePreference', arguments);
    var newKey = getNewKey(id, key);
    m_localStorage_removeItem.call(localStorage, newKey);
    //更新保存的keyList，删除相应的key
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null !== keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                keyArray.splice(index, 1);
                break;
            }
        }
        m_localStorage_setItem.call(localStorage, id, keyArray.join(keySeparator));
    }
};

/**
 * 获取指定下标所在位置的键(Android,iOS)
 * @examle
        xFace.Setting.key(1);
 * @method key
 * @param {String} index 键所在位置的下标
 * @return {String}  返回指定位置的键的名称
 * @platform Android,iOS
 * @since 3.0.0
 */
Setting.prototype.key = function(index){
    argscheck.checkArgs('s', 'xFace.Setting.key', arguments);
    var nonNegative = /^\d+(\.\d+)?$/;
    if(nonNegative.test(index)){
        var realIndex = Math.floor(index);
        var keyList = m_localStorage_getItem.call(localStorage, id);
        if((null !== keyList) && ("" !== keyList)){
            var keyArray = keyList.split(keySeparator);
            if(realIndex < keyArray.length){
                var key = keyArray[realIndex];
                return key;
            }
        }
    }
    return null;
};

/**
 * 删除配置中存储的所有键值对(Android,iOS)
 * @example
        xFace.Setting.clear();
 * @method clear
 * @platform Android,iOS
 * @since 3.0.0
 */
Setting.prototype.clear = function(){
    //删除setting的数据，keyList保存了所有属于Setting的key值，根据它的信息
    //可以删除全部的数据
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null !== keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var key = keyArray[index];
            var newKey = getNewKey(id, key);
            m_localStorage_removeItem.call(localStorage, newKey);
        }
    }
    m_localStorage_removeItem.call(localStorage, id);
};

module.exports = new Setting();
});

// file: lib/common/extension/Telephony.js
define("xFace/extension/Telephony", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 提供拨打电话和操作通话记录相关的功能（Android, iOS）<br/>
 * 该类不能通过new来创建相应的对象，只能通过xFace.Telephony对象来直接使用该类中定义的方法
 * @class Telephony
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
var Telephony = function(){
};

/**
 * 拨打电话 (Android, iOS)
 * @example
        function call() {
            xFace.Telephony.initiateVoiceCall("114",callSuccess, callFail);
        }
        function success() {
            alert("success");
        }
        function fail() {
            alert("fail to scanner barcode" );
        }
 * @method initiateVoiceCall
 * @param {String} phoneNumber 电话号码
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
Telephony.prototype.initiateVoiceCall = function(phoneNumber,successCallback,errorCallback){
    argscheck.checkArgs('sFF', 'xFace.Telephony.initiateVoiceCall', arguments);
    exec(successCallback, errorCallback, null, "Telephony", "initiateVoiceCall", [phoneNumber]);
};
module.exports = new Telephony();

});

// file: lib/common/extension/Zip.js
define("xFace/extension/Zip", function(require, exports, module) {

/**
 * 该类定义了压缩与解压缩相关接口,路径都是相对于app workSpace的路径（Android, iOS）<br/>
 * 该类不能通过new来创建相应的对象，只能通过xFace.Zip对象来直接使用该类中定义的方法
 * 相关参考： {{#crossLink "ZipError"}}{{/crossLink}}
 * @class Zip
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var ZipError = require('xFace/extension/ZipError');
var Zip = function() {};

/**
 * 将指定路径的文件或文件夹压缩成zip文件（Android, iOS）<br/>
 * 成功回调函数不带参数<br/>
 * 错误回调函数带有一个Number类型的参数，用于返回错误码，错误码的定义参见{{#crossLink "ZipError"}}{{/crossLink}}<br/>
 * @example
        var filePath ="MyFile.txt";
        var zipFilePath ="MyZip.zip";
        var zipFilePath2 ="mypath/MyZip.zip";
        function Success() {
                alert("zip file success" );
            }
        function Error(errorcode) {
                alert("zip file error: errorcode = " + errorcode);
            }

        xFace.Zip.zip(filePath, zipFilePath, Success, Error, {password:"test"}); //表明将文件压缩到当前目录，压缩文件的名字为MyZip.zip
        xFace.Zip.zip(filePath, zipFilePath2, Success, Error); //表明将文件压缩到当前目录的mypath文件夹下,压缩文件的名字为MyZip.zip
 * @method zip
 * @param {String} filePath 待压缩的文件路径
 * @param {String} dstFilePath 指定目标文件路径(含 .zip 后缀)
 * @param {Object} [options]     压缩文件时采用的配置选项（目前仅ios支持），属性包括：<br/>
        password：类型为String，用于指定压缩时的密码
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
Zip.prototype.zip = function(filePath, dstFilePath, successCallback, errorCallback,options){
    argscheck.checkArgs('ssFFO', 'xFace.Zip.zip', arguments);
    exec(successCallback, errorCallback, null, "Zip", "zip", [filePath,dstFilePath,options]);
};

/**
 * 将指定路径的zip文件解压（Android, iOS）<br/>
 * 成功回调函数不带参数<br/>
 * 错误回调函数带有一个Number类型的参数，用于返回错误码，错误码的定义参见{{#crossLink "ZipError"}}{{/crossLink}}<br/>
 * @example
        var dstFolderPath = "MyDstFolder";
        var zipFilePath ="MyZip.zip";
        function Success() {
                alert("zip file success" );
            }
        function Error(errorcode) {
                alert("zip file error: errorcode = " + errorcode);
            }

        xFace.Zip.unzip(zipFilePath, dstFolderPath, Success, Error, {password:"test"});
 * @method unzip
 * @param {String} zipFilePath 待解压的指定路径的zip文件
 * @param {String} dstFolderPath 指定目标文件夹（如果为空串的话，就解压到当前app workspace目录；Android不支持路径为空）
 * @param {Object} [options]  解压文件时采用的配置选项（目前仅ios支持），属性包括：<br/>
        password：类型为String，用于指定解压时的密码
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
 //TODO:Android支持路径为空
Zip.prototype.unzip = function(zipFilePath, dstFolderPath, successCallback, errorCallback,options){
    argscheck.checkArgs('ssFFO', 'xFace.Zip.unzip', arguments);
    //zip文件类型检查（zip/xpa/xspa）
    var arr = zipFilePath.split(".");
    var suffix = arr[arr.length -1];
    console.log("file type: "+ suffix);
    if("zip" == suffix || "xpa" == suffix || "xspa" == suffix) {
        exec(successCallback, errorCallback, null, "Zip", "unzip", [zipFilePath,dstFolderPath,options]);
    }
    else {
        if( errorCallback && (typeof errorCallback == 'function') ) {
            errorCallback(ZipError.FILE_TYPE_ERROR);
        }
    }
};

/**
 * 将多个指定路径的文件或文件夹压缩成zip文件（Android, iOS）<br/>
 * 成功回调函数不带参数<br/>
 * 错误回调函数带有一个Number类型的参数，用于返回错误码，错误码的定义参见{{#crossLink "ZipError"}}{{/crossLink}}<br/>
 * @example
        var zipFilePath ="MyZip.zip";
        function Success() {
                alert("zip file success" );
            }
        function Error(errorcode) {
                alert("zip file error: errorcode = " + errorcode);
            }

        xFace.Zip.zipFiles(["MyZip", "test.apk", "index.html"],
                        zipFilePath, Success, Error, {password:"test"});
 * @method zipFiles
 * @param {Array} srcEntries  待压缩文件或文件夹的路径数组，String类型的Array
 * @param {String} dstFilePath  指定目标文件路径(含 .zip 后缀)
 * @param {Object} [options]      压缩文件时采用的配置选项（目前仅ios支持），属性包括：<br/>
        password：类型为String，用于指定压缩时的密码
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
Zip.prototype.zipFiles = function(srcEntries, dstFilePath, successCallback, errorCallback, options){
    argscheck.checkArgs('asFFO', 'xFace.Zip.zipFiles', arguments);
    exec(successCallback, errorCallback, null, "Zip", "zipFiles", [srcEntries, dstFilePath, options]);
};

module.exports = new Zip();

});

// file: lib/common/extension/ZipError.js
define("xFace/extension/ZipError", function(require, exports, module) {

/**
 * 该类定义一些常量，用于标识压缩和解压失败的错误信息（Android, iOS）<br/>
 * 相关参考： {{#crossLink "Zip"}}{{/crossLink}}
 * @class ZipError
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */

var ZipError = function() {
};

/**
 * 待压缩的文件或文件夹不存在（Android, iOS）
 * @property FILE_NOT_EXIST
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ZipError.FILE_NOT_EXIST = 1;

/**
 * 压缩文件出错.（Android, iOS）
 * @property COMPRESS_FILE_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ZipError.COMPRESS_FILE_ERROR = 2;

/**
 * 解压文件出错.（Android, iOS）
 * @property UNZIP_FILE_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ZipError.UNZIP_FILE_ERROR = 3;

/**
 * 文件路径错误(相应的文件(夹)不在APP的workspace下)（Android, iOS）
 * @property FILE_PATH_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ZipError.FILE_PATH_ERROR = 4;

/**
 * 文件类型错误,不支持的文件类型（Android, iOS）
 * @property FILE_TYPE_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS
 * @since 3.0.0
 */
ZipError.FILE_TYPE_ERROR = 5;

module.exports = ZipError;

});

// file: lib/common/extension/ZipOptions.js
define("xFace/extension/ZipOptions", function(require, exports, module) {
var ZipOptions = function(){
        this.password = null;
    };

module.exports = ZipOptions;
});

// file: lib/common/extension/accelerometer.js
define("xFace/extension/accelerometer", function(require, exports, module) {

/**
 * 该类提供基础的API,用于捕捉x,y,z三个方向的加速度（Android, iOS）<br/>
 * 该类的对象实例是唯一的，只能通过navigator.accelerometer进行引用
 * @class Accelerometer
 * @static
 * @platform Andriod,iOS
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
     * 获取当前的重力加速度数据，重力加速度数据说明参考{{#crossLink "Acceleration"}}{{/crossLink}}(Andriod,iOS)
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
     * @platform Andriod,iOS
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
     * 监视{{#crossLink "Acceleration"}}{{/crossLink}}的变化,若未指定frequency则默认采用10s(Andriod,iOS)
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
     * @platform Android, iOS
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
     * 取消指定的监视器(Andriod,iOS)
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
     * @platform Android, iOS
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
});

// file: lib/common/extension/ams.js
define("xFace/extension/ams", function(require, exports, module) {


/**
  * 该类定义了xFace应用管理的基础api，包括应用的安装、卸载、启动、关闭、更新等（Android, iOS）<br/>
  * 该类不能通过new来创建相应的对象，可以通过xFace.AMS来直接使用该类中定义的方法
  * @class AMS
  * @platform Android, iOS
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck');
var exec = require('xFace/exec');
var xFace = require('xFace');
var localStorage = require('xFace/localStorage');
var AMS = function(){
};

/**
 * 安装一个app
 * @example
        function successCallback(info){
            console.log(info.appid);
            console.log(info.type);
        };
        function errorCallback(error){
            console.log(error.appid);
            console.log(error.type);
            console.log(error.errorcode);
        };
        xFace.AMS.installApplication ("geolocation.zip",successCallback，errorCallback);
 * @method installApplication
 * @param {String} packagePath              app安装包所在相对路径（相对于当前app的工作空间）
 * @param {Function} [successCallback]        成功时的回调函数
 * @param {Object} successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {Number} successCallback.info.type   操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String} successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          失败时的回调函数
 * @param {Object} errorCallback.error   包含错误信息的对象，每个object包含如下属性：
 * @param {Number} errorCallback.error.type  发生错误的ams操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String} errorCallback.error.appid  发生错误的app的id号
 * @param {Number} errorCallback.error.errorcode  错误码，具体错误码参考<a href="../classes/AmsError.html" class="crosslink">AmsError</a>
 * @param {Function} [statusChangedCallback]  安装过程的状态回调函数
 * @param {Object} statusChangedCallback.progress 安装状态，类型为json，格式为{"progress"：type},type为安装状态码，具体安装状态码参考{{#crossLink "AmsState"}}{{/crossLink}}
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.installApplication = function( packagePath, successCallback, errorCallback, statusChangedCallback)
{
   argscheck.checkArgs('sFFF', 'AMS.installApplication', arguments);
   if(!packagePath || typeof packagePath  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, statusChangedCallback, "AMS", "installApplication",[packagePath]);
};

/**
 * 卸载app
 * @example
        function successCallback(info){
            console.log(info.appid);
            console.log(info.type);
        };
        function errorCallback(error){
            console.log(error.appid);
            console.log(error.type);
            console.log(error.errorcode);
        };
        xFace.AMS.uninstallApplication ("mengfGeolocation",successCallback，errorCallback);
 * @method uninstallApplication
 * @param {String} appId                    用于标识待卸载app的id
 * @param {Function} [successCallback]         卸载成功时的回调函数
 * @param {Object}  successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {Number}  successCallback.info.type   操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          卸载失败时的回调函数
 * @param {Object}  errorCallback.error      包含错误信息的对象，每个object包含如下属性：
 * @param {Number}  errorCallback.error.type  发生错误的ams操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  errorCallback.error.appid  发生错误的app的id号
 * @param {Object}  errorCallback.error.errorcode  错误码，具体错误码参考<a href="../classes/AmsError.html" class="crosslink">AmsError</a>
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.uninstallApplication = function( appId, successCallback, errorCallback)
{
   argscheck.checkArgs('sFF', 'AMS.uninstallApplication', arguments);
   if(!appId || typeof appId  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback();
        }
        return;
    }
    exec(
    //Success callback
    function(s)
    {
        //删除app存储的数据
        localStorage.clearAppData(appId);
        successCallback(s);
    }, errorCallback, null, "AMS", "uninstallApplication",[appId]);
};

/**
 * 启动app
 * @example
        function successCallback(info){
            console.log(info.appid);
        };
        function errorCallback(error){
            console.log(error.appid);
        };
        xFace.AMS.startApplication(successCallback，errorCallback);
 * @method startApplication
 * @param {String} appId                    用于标识待启动app的id
 * @param {Function} [successCallback]        成功时的回调函数
 * @param {Object}  successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {String}  successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          失败时的回调函数
 * @param {Object}  errorCallback.error     包含错误信息的对象，每个object包含如下属性:
 * @param {String}  errorCallback.error.appid  发生错误的app的id号
 * @param {String}  [params] 程序启动参数，默认值为空
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.startApplication = function(appId, successCallback, errorCallback, params)
{
    argscheck.checkArgs('s**S', 'AMS.startApplication', arguments);
    //appId check
    if(!appId || typeof appId  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback("noId");
        }
        return;
    }
    var temp = arguments[1];

    //params check 1
    if( arguments.length == 2 && typeof arguments[1] === "string")
    {
        successCallback = null;
        errorCallback = null;
        params = temp;
    }

    //params check 2
    if(params === null || params === undefined)
    {
        params = "";
    }


    exec(successCallback, errorCallback, null, "AMS", "startApplication",[appId,params]);
};

/**
 * 关闭当前应用app
 * 如果当前只有一个app,在android平台上则退出xFace;在iOS平台上由于系统限制不退出xFace!!
 * @example
        xFace.AMS.closeApplication();
 * @method closeApplication
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.closeApplication = function()
{
    require('xFace/extension/privateModule').execCommand("xFace_close_application:", []);
};

/**
 * 列出系统已经安装的app列表
 * @example
         function successCallback(apps) {
            var count = apps.length;
            alert(count + " InstalledApps.");
            for(var i = 0; i < count; i++) {
                console.log(apps[i].appid);
                console.log(apps[i].name);
                console.log(apps[i].icon);
                console.log(apps[i].icon_background_color);
                console.log(apps[i].version);
                console.log(apps[i].type);
            }
        };
        function errorCallback() {
            alert("list fail!");
        };
       xFace.AMS.listInstalledApplications(successCallback，errorCallback);
 * @method listInstalledApplications
 * @param {Function} successCallback       获取列表成功时的回调函数
 * @param {Array}  successCallback.app 包含当前已经安装的app列表，每个app对象包含如下属性,
 * @param {String} successCallback.app.appid App的唯一id
 * @param {String} successCallback.app.name  App的名字
 * @param {String} successCallback.app.icon  App的图标的url
 * @param {String} successCallback.app.icon_background_color  App的图标背景颜色
 * @param {String} successCallback.app.version  App的版本
 * @param {String} successCallback.app.type  App的类型(nativeApp: napp; webApp:xapp或app)
 * @param {Function} [errorCallback]         获取列表失败时的回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.listInstalledApplications = function(successCallback, errorCallback)
{
    argscheck.checkArgs('fF', 'AMS.listInstalledApplications', arguments);
    exec(successCallback, errorCallback, null, "AMS", "listInstalledApplications",[]);
};
/**
 * 获取默认app可以安装的预设app安装包列表
 * 列表中每一项为一个app安装包的相对路径，可以直接安装/更新
 * @example
        function successCallback(packages){
            var count = packages.length;
            alert(count + " pre set app(s).");
            for(var i = 0; i < count; i++){
                alert(packages[i]);
            }
        }
        function errorCallback(){
            alert("list fail!");
        };
       xFace.AMS.listPresetAppPackages(successCallback，errorCallback);
 * @method listPresetAppPackages
 * @param {Function} successCallback     成功时的回调函数
 * @param {Array} successCallback.packages  预置包名数组对象，每一项均为预置包名
 * @param {Function} [errorCallback]           失败时的回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.listPresetAppPackages = function(successCallback, errorCallback)
{
    argscheck.checkArgs('fF', 'AMS.listPresetAppPackages', arguments);
    exec(successCallback, errorCallback, null, "AMS", "listPresetAppPackages", []);
};

/**
 * 重启默认app
 * 场景描述：
 * 1) 用户首先自行判断默认app是否需要更新，如果需要更新，则下载相应的更新包
 * 2) 默认app更新包下载成功后，调用updateApplication进行更新
 * 3) 默认app更新成功后，调用reset接口重启默认app
 * @example
       xFace.AMS.reset();
 * @method reset
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.reset = function()
{
    exec(null, null, null, "AMS", "reset", []);
};


/**
 * 更新app
 * @example
        function successCallback(info){
            console.log(info.appid);
            console.log(info.type);
        };
        function errorCallback(error){
            console.log(error.appid);
            console.log(error.type);
            console.log(error.errorcode);
        };
       xFace.AMS.updateApplication("geolocation.zip",successCallback，errorCallback);
 * @method updateApplication
 * @param {String} packagePath              app更新包所在相对路径（相对于当前app的工作空间）
 * @param {Function} [successCallback]        更新成功时的回调函数
 * @param {Object}  successCallback.info   与app相关信息object,每个object包含如下属性：
 * @param {Number}  successCallback.info.type   操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  successCallback.info.appid  app的id号
 * @param {Function} [errorCallback]          更新失败时的回调函数
 * @param {Object}  errorCallback.error     包含错误信息的对象，每个object包含如下属性：
 * @param {Number}  errorCallback.error.type  发生错误的ams操作类型,具体类型参考<a href="../classes/AmsOperationType.html" class="crosslink">AmsOperationType</a>
 * @param {String}  errorCallback.error.appid  发生错误的app的id号
 * @param {Object}  errorCallback.error.errorcode  错误码，具体错误码参考<a href="../classes/AmsError.html" class="crosslink">AmsError</a>
 * @param {Function} [statusChangedCallback]  更新过程的状态回调函数
 * @param {Object}  statusChangedCallback.progress 安装状态，类型为json，格式为{"progress"：type},type为安装状态码，具体状态码参考{{#crossLink "AmsState"}}{{/crossLink}}
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.updateApplication = function( packagePath, successCallback, errorCallback, statusChanged)
{
   argscheck.checkArgs('sFFF', 'AMS.updateApplication', arguments);
   if(!packagePath || typeof packagePath  != "string"){
        if(typeof errorCallback === "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, statusChanged,"AMS", "updateApplication",[packagePath]);

};

/**
 * 获取startApp的app描述信息
 * @example
       function successCallback(app){
            console.log(app.appid);
            console.log(app.name);
            console.log(app.icon);
            console.log(app.icon_background_color);
            console.log(app.version);
            console.log(app.type);
        };
        function errorCallback(){
            alert("failed");
        };
       xFace.AMS.getStartAppInfo(successCallback，errorCallback);
 * @method getStartAppInfo
 * @param {Function} successCallback      成功时的回调函数
 * @param {Object} successCallback.app    当前启动的app的信息，每个app对象包含如下属性,
 * @param {String} successCallback.app.appid,  App的唯一id
 * @param {String} successCallback.app.name,  App的名字
 * @param {String} successCallback.app.icon  App的图标的url
 * @param {String} successCallback.app.icon_background_color  App的图标背景颜色
 * @param {String} successCallback.app.version  App的版本
 * @param {String} successCallback.app.type  App的类型(nativeApp:napp; webApp:xapp或app)
 * @param {Function} [errorCallback]        失败时的回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
AMS.prototype.getStartAppInfo = function(successCallback, errorCallback)
{
    argscheck.checkArgs('fF', 'AMS.getStartAppInfo', arguments);
    exec(successCallback, errorCallback, null, "AMS", "getStartAppInfo", []);
};

module.exports = new AMS();

});

// file: lib/common/extension/app.js
define("xFace/extension/app", function(require, exports, module) {

 /**
  * 提供引擎的退出，打开url链接，清除历史/缓存，启动/安装本地应用等功能（Android，iOS）<br/>
  * 该类不能通过new来创建相应的对象，只能通过navigator.app对象来直接使用该类中定义的方法
  * @class App
  * @platform Android, iOS
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var app = function() {
};

/**
 * 调用系统默认程序（浏览器）打开一个url链接，如pdf，word，http地址等（Android, iOS）
  @example
        var url = "http://www.baidu.com/index.html";
        function error(msg) {
            console.log("Error info: " + msg);
        }
        navigator.app.openUrl(url, success, error);

        url = "a/b/c/test.pdf";
        navigator.app.openUrl(url, success, error);
 * @method openUrl
 * @param {String} url 要打开文件的路径或链接地址
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]   失败回调函数
 * @param {String} errorCallback.msg 失败描述信息
 * @platform Android, iOS
 * @since 3.0.0
 */
app.prototype.openUrl = function(url, successCallback, errorCallback){
    argscheck.checkArgs('sFF', 'app.openUrl', arguments);
    exec(successCallback, errorCallback, null, "App", "openUrl", [url]);
};

/**
 * 获取渠道信息（Android, iOS）
  @example
        function error() {
            console.log("getChannel error”);
        }
        function success(channel) {
            console.log("channel id: " + channel.id);
            console.log("channel name: " + channel.name);
        }
        navigator.app.getChannel(success, error);
 * @method getChannel
 * @param {Function} successCallback 成功回调函数
 * @param {object} successCallback.channel 渠道信息对象
 * @param {String} successCallback.channel.id 渠道唯一标识符
 * @param {String} successCallback.channel.name 渠道名称
 * @param {Function} [errorCallback]   失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
app.prototype.getChannel = function(successCallback, errorCallback){
    argscheck.checkArgs('fF', 'app.getChannel', arguments);
    exec(successCallback, errorCallback, null, "App", "getChannel", []);
};
module.exports = new app();
});

// file: lib/common/extension/battery.js
define("xFace/extension/battery", function(require, exports, module) {
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
       * 当xFace应用监测到电池电量改变了至少1%的时候或者充电器插拔的时候会触发该事件（Android, iOS）<br/>
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
       * @platform Android, iOS
       * @since 3.0.0
       */
      batterystatus:xFace.addWindowEventHandler("batterystatus"),
      /**
       * 当xFace应用监测到手机的电池达到低电量值(20%)的时候会触发该事件（Android, iOS）<br/>
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
        * @platform Android, iOS
        * @since 3.0.0
       */
      batterylow:xFace.addWindowEventHandler("batterylow"),
      /**
       * 当xFace应用监测到手机的电池达到临界值(5%)的时候会触发该事件（Android, iOS）<br/>
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
       * @platform Android, iOS
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

});

// file: lib/common/extension/capture.js
define("xFace/extension/capture", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    MediaFile = require('xFace/extension/MediaFile');

/**
 * 根据不同类型启动一个capture
 * @param (String} type 媒体文件格式类型，类型包括:captureImage、captureAudio和captureVideo
 * @param {Function} successCallback 成功回调函数
 * @param {Function} errorCallback 失败回调函数
 * @param {CaptureImageOptions | CaptureAudioOptions | CaptureVideoOptions} options
 */
function captureMedia(type, successCallback, errorCallback, options) {
    var win = function(result) {
        var mediaFiles = [];
        for (var i = 0; i < result.length; i++) {
            var mediaFile = new MediaFile();
            mediaFile.name = result[i].name;
            mediaFile.fullPath = result[i].fullPath;
            mediaFile.type = result[i].type;
            mediaFile.lastModifiedDate = result[i].lastModifiedDate;
            mediaFile.size = result[i].size;
            mediaFiles.push(mediaFile);
        }
        successCallback(mediaFiles);
    };
    exec(win, errorCallback, null, "Capture", type, [options]);
}
  /**
  * 该类提供对设备音频、图像和视频采集功能的访问（Android, iOS）<br/>
  * 只能通过navigator.device.capture来使用该类中定义的方法
  * @class Capture
  * @static
  * @platform Android, iOS
  * @since 3.0.0
  */
function Capture() {
    this.supportedAudioModes = [];
    this.supportedImageModes = [];
    this.supportedVideoModes = [];
}

/**
 * 启动照相机应用进行拍照操作（Android, iOS）<br/>
 * @example
        function captureImage() {
            navigator.device.capture.captureImage(successCallback , errorCallback, {limit: 1});
        }
        function successCallback (mediaFiles) {
            console.log("The name of media file is " + mediaFiles[0].name);
            console.log("The full path of media file is " + mediaFiles[0].fullPath);
            console.log("The size of media file is " + mediaFiles[0].size);
        }
        function errorCallback(error) {
            var msg = 'An error occurred during capture: ' + error.code;
            console.log(msg);
        }
 * @method captureImage
 * @param {Function} [successCallback] 成功回调函数
 * @param {MediaFile[]} successCallback.mediaFiles 返回采集到的图像文件集合
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 返回错误信息
 * @param {CaptureImageOptions} [options] 封装图像采集的配置选项
 * @platform Android, iOS
 * @since 3.0.0
 */
Capture.prototype.captureImage = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureImage', arguments);
    captureMedia("captureImage", successCallback, errorCallback, options);
};

/**
 * 启动照相机应用进行录音操作（Android, iOS）<br/>
 * @example
        function captureAudio() {
            navigator.device.capture.captureAudio(successCallback , errorCallback, {limit: 1});
        }
        function successCallback (mediaFiles) {
            console.log("The name of media file is " + mediaFiles[0].name);
            console.log("The full path of media file is " + mediaFiles[0].fullPath);
            console.log("The size of media file is " + mediaFiles[0].size);
        }
        function errorCallback(error) {
            var msg = 'An error occurred during capture: ' + error.code;
            console.log(msg);
        }
 * @method captureAudio
 * @param {Function} [successCallback] 成功回调函数
 * @param {MediaFile[]} successCallback.mediaFiles 返回采集到的音频文件集合
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 返回错误信息
 * @param {CaptureAudioOptions} [options] 封装音频采集的配置选项
 * @platform Android, iOS
 * @since 3.0.0
 */
Capture.prototype.captureAudio = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureAudio', arguments);
    captureMedia("captureAudio", successCallback, errorCallback, options);
};

/**
 * 启动照相机应用进行摄像操作（Android, iOS）<br/>
 * @example
        function captureVideo() {
            navigator.device.capture.captureVideo(successCallback , errorCallback, {limit: 1});
        }
        function successCallback (mediaFiles) {
            console.log("The name of media file is " + mediaFiles[0].name);
            console.log("The full path of media file is " + mediaFiles[0].fullPath);
            console.log("The size of media file is " + mediaFiles[0].size);
        }
        function errorCallback(error) {
            var msg = 'An error occurred during capture: ' + error.code;
            console.log(msg);
        }
 * @method captureVideo
 * @param {Function} [successCallback] 成功回调函数
 * @param {MediaFile[]} successCallback.mediaFiles 返回采集到的视频文件集合
 * @param {Function} [errorCallback] 失败回调函数
 * @param {CaptureError} errorCallback.error 返回错误信息
 * @param {CaptureVideoOptions} [options] 封装视频采集的配置选项
 * @platform Android, iOS
 * @since 3.0.0
 */
Capture.prototype.captureVideo = function(successCallback, errorCallback, options){
    argscheck.checkArgs('FFO', 'capture.captureVideo', arguments);
    captureMedia("captureVideo", successCallback, errorCallback, options);
};

module.exports = new Capture();
});

// file: lib/common/extension/compass.js
define("xFace/extension/compass", function(require, exports, module) {

var argscheck = require('xFace/argscheck'),
exec = require('xFace/exec'),
utils = require('xFace/utils'),
CompassHeading = require('xFace/extension/CompassHeading'),
CompassError = require('xFace/extension/CompassError'),
CompassOptions = require('xFace/extension/CompassOptions'),
timers = {},
/**
 * 该类用于获取指南针的方向信息（Android, iOS）<br/>
 * 只能通过navigator.compass对象来使用该类中定义的方法
 * @class Compass
 * @platform Android, iOS
 * @since 3.0.0
 */

compass = {
    /**
     * 获取指南针当前的方向信息，指南针可以测量的角度为0到359.99（Android, iOS）<br/>
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
     * @platform Android, iOS
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
     * 监视指南针，根据指定的间隔时间循环获取指南针的方向信息，指南针可以测量的角度为0到359.99（Android, iOS）<br/>
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
     * @platform Android, iOS
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
     * 消除指定的指南针监视器（Android, iOS）
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
     * @platform Android, iOS
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
});

// file: lib/common/extension/console.js
define("xFace/extension/console", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/extension/privateModule').getExecV2();

/**
 * 该类向控制台输出log信息，如果没有调用setLevel函数，则默认打印所有类型log信息（Android, iOS）<br/>
 * 只能通过console对象来直接使用该类中定义的方法
 * @class Console
 * @platform Android, iOS
 * @since 3.0.0
 */
var DebugConsole = function() {
    this.winConsole = window.console;
    this.logLevel = DebugConsole.INFO_LEVEL;
};

/**
 * 能成功打印所有类型log信息,和INFO_LEVEL相同
 */
DebugConsole.ALL_LEVEL    = 1;

/**
 * 能成功打印所有类型log信息
 */
DebugConsole.INFO_LEVEL   = 1;

/**
 * 能成功打印警告、错误log信息
 */
DebugConsole.WARN_LEVEL   = 2;

/**
 * 只能成功打印错误log信息
 */
DebugConsole.ERROR_LEVEL  = 4;

/**
 * 所有打印log信息的api都不能正常输出log信息
 */
DebugConsole.NONE_LEVEL   = 8;

/**
 * 设置当前log信息输出的最高级别（Android, iOS）
 * @example
        console.setLevel(1);
 * @method setLevel
 * @param {Number} level 表示当前log信息输出的最高级别,有四个等级:<br/>
                         1: 所有log信息；2：警告、错误log信息；4：错误log信息；8：不输出log信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DebugConsole.prototype.setLevel = function(level) {
    argscheck.checkArgs('n', 'console.setLevel', arguments);
    this.logLevel = level;
};

/**
 * 返回输入的Object对象的String类型
 */
var stringify = function(message) {
    try{
       if(typeof message === "object" && JSON && JSON.stringify) {
           return JSON.stringify(message);
       } else {
           return message.toString();
       }
    } catch (e) {
       return e.toString;
    }
};

/**
 * 向控制台打印一条普通log信息（Android, iOS）
 * @example
        var str = "This is just a log information! ";
        console.log(str);
 * @method log
 * @param {Object} message 需要打印的log信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DebugConsole.prototype.log = function(message) {
    argscheck.checkArgs('*', 'console.log', arguments);
    if (this.logLevel <= DebugConsole.INFO_LEVEL) {
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'INFO' } ]);
    } else {
       this.winConsole.log(message);
    }
 };

/**
 * 向控制台打印一条警告log信息（Android, iOS）
 * @example
        var str = "This is just a warn information! ";
        console.warn(str);
 * @method warn
 * @param {Object} message 需要打印的log信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DebugConsole.prototype.warn = function(message) {
    argscheck.checkArgs('*', 'console.warn', arguments);
    if (this.logLevel <= DebugConsole.WARN_LEVEL)
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'WARN' } ]);
    else
        this.winConsole.error(message);
};

/**
 * 向控制台打印一条错误log信息（Android, iOS）
 * @example
        var str = "This is just an error information! ";
        console.error(str);
 * @method error
 * @param {Object} message 需要打印的log信息
 * @platform Android, iOS
 * @since 3.0.0
 */
DebugConsole.prototype.error = function(message) {
    argscheck.checkArgs('*', 'console.error', arguments);
    if (this.logLevel <= DebugConsole.ERROR_LEVEL)
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'ERROR' }]);
    else
        this.winConsole.error(message);
};

module.exports = new DebugConsole();
});

// file: lib/common/extension/contacts.js
define("xFace/extension/contacts", function(require, exports, module) {
var exec = require('xFace/extension/privateModule').getExecV2(),
    argscheck = require('xFace/argscheck'),
    ContactError = require('xFace/extension/ContactError'),
    Contact = require('xFace/extension/Contact');
/**
 * 该模块提供对设备通讯录数据库的访问.
 * @module contacts
 * @main contacts
 */

/**
 * 该类定义了设备通讯录数据库的访问相关接口（Android, iOS）<br/>
 * 该类不能通过new来创建相应的对象，只能通过navigator.contacts对象来直接使用该类中定义的方法<br/>
 * 相关参考： {{#crossLink "ContactError"}}{{/crossLink}}，{{#crossLink "Contact"}}{{/crossLink}},{{#crossLink "ContactField"}}{{/crossLink}},{{#crossLink "ContactFindOptions"}}{{/crossLink}}
 * @class Contacts
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */

var contacts = {
    /**
     * 查询设备通讯录（Android, iOS）<br/>
     * @example
            function onSuccess(contacts) {
                alert('Found ' + contacts.length + ' contacts.'); };

            function onError(contactError) {
                alert('onError!')+ contactError.code;  };

            // find all contacts with 'Bob' in any name field
            var options = new ContactFindOptions();
            options.filter="Bob";
            options.multiple=true;
            var fields = ["displayName", "name"];
            navigator.contacts.find(fields, onSuccess, onError, options);

     * @method find
     * @param {String[]} fields 需要查询的域。在返回的Contact对象中只有这些字段有值，支持的项参见 {{#crossLink "Contact"}}{{/crossLink}}的属性
     * @param {Function} successCallback 成功回调函数
     * @param {Contact[]} successCallback.contacts 满足查询条件的Contact对象数组
     * @param {Function} [errorCallback]   失败回调函数
     * @param {ContactError} errorCallback.error   错误码
     * @param {ContactFindOptions} [options] 过滤通讯录的搜索选项
     * @platform Android, iOS
     * @since 3.0.0
     */
    find:function(fields, successCallback, errorCallback, options) {
        argscheck.checkArgs('afFO', 'contacts.find', arguments);
        if (!fields.length) {
            if (typeof errorCallback === "function") {
                errorCallback(new ContactError(ContactError.INVALID_ARGUMENT_ERROR));
            }
        } else {
            var win = function(result) {
                var cs = [];
                for (var i = 0, l = result.length; i < l; i++) {
                    cs.push(contacts.create(result[i]));
                }
                successCallback(cs);
            };
            var fail = function(errorCode) {
                errorCallback(new ContactError(errorCode));
            };
            exec(win, fail, null, "Contacts", "search", [fields, options]);
        }
    },


    /**
     * 创建一个新的联系人，但此函数不将其保存在设备存储上（Android, iOS）<br/>
     * 要持久保存在设备存储上，可调用Contact.save()。
     * @example
            var myContact = navigator.contacts.create({"displayName": "Test User"});

     * @method create
     * @param {Object} [properties] 创建新对象所包含的属性，支持的属性项参见 {{#crossLink "Contact"}}{{/crossLink}}的属性
     * @return {Contact} 包含了指定的properties的一个新Contact对象，如果未指定properties，则该Contact对象中所有属性均为null.
     * @platform Android, iOS
     * @since 3.0.0
     */
    create:function(properties) {
        argscheck.checkArgs('O', 'contacts.create', arguments);
        var contact = new Contact();
        for (var i in properties) {
            if (typeof contact[i] !== 'undefined' && properties.hasOwnProperty(i)) {
                contact[i] = properties[i];
            }
        }
        return contact;
    }
};

module.exports = contacts;

});

// file: lib/common/extension/device.js
define("xFace/extension/device", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    channel = require('xFace/channel'),
    exec = require('xFace/exec');

// Tell xFace channel to wait on the onxFaceInfoReady event
channel.waitForInitialization('onxFaceInfoReady');

/**
 * 用于提供设备及其能力等相关信息（Android，iOS）<br/>
 * 该类不能通过new来创建相应的对象，只能通过device对象来直接访问其属性<br/>
 *（该类中定义的设备信息由引擎自动初始化，开发人员在deviceready事件触发之后可以访问）
 * @example
        function init() {
            document.addEventListener("deviceready", deviceInfo, true);
        }
        var deviceInfo = function() {
            console.log("OS platform = " + device.platform);
            console.log("OS version = " + device.version);
            console.log("device model = " + device.model);
            console.log("device uuid = " + device.uuid);
            console.log("device imsi = " + device.imsi);
            console.log("device userAgent = " + navigator.userAgent);
            console.log("device name = " + device.name);
            console.log("device availWidth = " + screen.availWidth);
            console.log("device availHeight = " + screen.availHeight);
            console.log("device width = " + device.width);
            console.log("device height = " + device.height);
            console.log("device colorDepth = " + screen.colorDepth);
            console.log("isCameraAvailable = " + device.isCameraAvailable);
            console.log("isFrontCameraAvailable = " + device.isFrontCameraAvailable);
            console.log("isCompassAvailable = " + device.isCompassAvailable);
            console.log("isAccelerometerAvailable = " + device.isAccelerometerAvailable);
            console.log("isLocationAvailable = " + device.isLocationAvailable);
            console.log("isWiFiAvailable = " + device.isWiFiAvailable);
            console.log("isTelephonyAvailable = " + device.isTelephonyAvailable);
            console.log("isSmsAvailable = " + device.isSmsAvailable);
        };
 * @class Device
 * @since 3.0.0
 * @platform Android, iOS
 */
function Device() {
    /**
     * 用于标识设备的操作系统平台（Android, iOS）
     * @property platform
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.platform = null;
    /**
     * 用于标识设备的操作系统版本（Android, iOS）
     * @property version
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.version = null;
    /**
     * 用于标识设备的名字（Android, iOS）
     * @property name
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.name = null;
    /**
     * 用于标识设备的Universally Unique Identifier (UUID).（Android, iOS）
     * @property uuid
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.uuid = null;
    /**
     * 用于标识设备的International Mobile Equipment Identity(IMEI)（Android）
     * @property imei
     * @default null
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.imei = null;
    /**
     * 用于标识设备的国际移动用户识别码(IMSI)（Android）
     * @property imsi
     * @default null
     * @type String
     * @platform Android
     * @since 3.0.0
     */
    this.imsi = null;
    /**
     * 用于标识xFace的版本号（Android, iOS）
     * @property xFaceVersion
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.xFaceVersion = null;
    /**
     * 用于标识程序包的产品名称，其值就是<manifest> 的标签versionName属性值（Android, iOS）
     * @property productVersion
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.productVersion = null;
    /**
     * 设备的屏幕宽度(单位像素)（Android, iOS）
     * @property width
     * @default 0
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.width = 0;
    /**
     * 设备的物理高度(单位像素)（Android, iOS）
     * @property height
     * @default 0
     * @type Number
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.height = 0;
    /**
     * 用于标识设备的照相机功能是否可用（Android, iOS）
     * @property isCameraAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isCameraAvailable = false;
    /**
     * 用于标识设备的前置摄像头功能是否可用（Android, iOS）
     * @property isFrontCameraAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isFrontCameraAvailable = false;
    /**
     * 用于标识设备的指南针功能是否可用（Android, iOS）
     * @property isCompassAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isCompassAvailable = false;
    /**
     * 用于标识设备的加速计功能是否可用（Android, iOS）
     * @property isAccelerometerAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isAccelerometerAvailable = false;
    /**
     * 用于标识设备的定位功能是否可用（Android, iOS）
     * @property isLocationAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isLocationAvailable = false;
    /**
     * 用于标识设备的WIFI功能是否可用（Android, iOS）
     * @property isWiFiAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isWiFiAvailable = false;
    /**
     * 用于标识设备的电话功能是否可用（Android, iOS）
     * @property isTelephonyAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isTelephonyAvailable = false;
    /**
     * 用于标识设备的短信功能是否可用（Android, iOS）
     * @property isSmsAvailable
     * @default false
     * @type Boolean
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.isSmsAvailable = false;
    /**
     * 用于标识设备的设备型号(model)（Android, iOS）
     * @property model
     * @default null
     * @type String
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.model = null;

    var me = this;

    channel.onxFaceReady.subscribe(function() {
        me.getInfo(function(info) {
            me.platform = info.platform;
            me.version = info.version;
            me.model  = info.model;
            me.name = info.name;
            me.uuid = info.uuid;
            /**ios不支持获取IMEI*/
            me.imei = info.imei === undefined ? "not support" : info.imei;
            /**ios不支持获取IMSI*/
            me.imsi = info.imsi === undefined ? "not support" : info.imsi;
            me.xFaceVersion = info.xFaceVersion;
            me.productVersion = info.productVersion;
            me.width = info.width;
            me.height = info.height;
            /** 获取设备能力*/
            me.isCameraAvailable = info.isCameraAvailable;
            me.isFrontCameraAvailable = info.isFrontCameraAvailable;
            me.isCompassAvailable = info.isCompassAvailable;
            me.isAccelerometerAvailable = info.isAccelerometerAvailable;
            me.isLocationAvailable = info.isLocationAvailable;
            me.isWiFiAvailable = info.isWiFiAvailable;
            me.isTelephonyAvailable = info.isTelephonyAvailable;
            me.isSmsAvailable = info.isSmsAvailable;

            channel.onxFaceInfoReady.fire();
        },function(e) {
            console.log("Error initializing xFace: " + e);
        });
    });
}

/**
 * 获得设备的相关属性（Android, iOS）<br/>
 * @example
        var errorCallback = function(){};
        var successCallback = function(deviceInfo) {
            console.log("OS platform = " + deviceInfo.platform);
            console.log("OS version = " + deviceInfo.version);
            console.log("device model = " + deviceInfo.model);
            console.log("device uuid = " + deviceInfo.uuid);
            console.log("device imsi = " + deviceInfo.imsi);
            console.log("device userAgent = " + navigator.userAgent);
            console.log("device name = " + deviceInfo.name);
            console.log("device availWidth = " + screen.availWidth);
            console.log("device availHeight = " + screen.availHeight);
            console.log("device width = " + device.width);
            console.log("device height = " + device.height);
            console.log("device colorDepth = " + screen.colorDepth);
            console.log("isCameraAvailable = " + deviceInfo.isCameraAvailable);
            console.log("isFrontCameraAvailable = " + deviceInfo.isFrontCameraAvailable);
            console.log("isCompassAvailable = " + deviceInfo.isCompassAvailable);
            console.log("isAccelerometerAvailable = " + deviceInfo.isAccelerometerAvailable);
            console.log("isLocationAvailable = " + deviceInfo.isLocationAvailable);
            console.log("isWiFiAvailable = " + deviceInfo.isWiFiAvailable);
            console.log("isTelephonyAvailable = " + deviceInfo.isTelephonyAvailable);
            console.log("isSmsAvailable = " + deviceInfo.isSmsAvailable);
        }
        device.getInfo(successCallback, errorCallback);
 * @method getInfo
 * @deprecated 该类中定义的设备信息由引擎自动初始化，开发人员在deviceready事件触发之后可以访问。
 * @param {Function} [successCallback] 成功回调函数.
 * @param {String} successCallback.uuid 设备的Universally Unique Identifier (UUID).（Android, iOS）
 * @param {String} successCallback.imei 设备的International Mobile Equipment Identity(IMEI).（Android）
 * @param {String} successCallback.imsi 设备的的国际移动用户识别码(IMSI)（Android）
 * @param {String} successCallback.version 设备的os version.（Android, iOS）
 * @param {String} successCallback.platform 设备的操作系统平台如android或iOS.（Android, iOS）
 * @param {String} successCallback.name 设备的product name.（Android, iOS）
 * @param {String} successCallback.xFaceVersion 设备的xFace的版本号.（Android, iOS）
 * @param {String} successCallback.productVersion 程序包的产品名称，其值就是<manifest> 的标签versionName属性值.（Android, iOS）
 * @param {String} successCallback.model 设备的的设备型号(model).（Android, iOS）
 * @param {Number} successCallback.width 设备的屏幕宽度(单位像素).（Android, iOS）
 * @param {Number} successCallback.height 设备的的屏幕高度(单位像素).（Android, iOS）
 * @param {Boolean} successCallback.isCameraAvailable 设备的照相机功能是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isFrontCameraAvailable 设备的前置摄像头是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isCompassAvailable 设备的指南针功能是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isAccelerometerAvailable 设备的加速度计功能是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isTelephonyAvailable 设备的电话功能是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isSmsAvailable 设备的短信功能是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isLocationAvailable 设备的定位功能是否可用.（Android, iOS）
 * @param {Boolean} successCallback.isWiFiAvailable 设备的WIFI功能是否可用.（Android, iOS）
 * @param {Function} [errorCallback] 失败回调函数.
 * @platform Android, iOS
 * @since 3.0.0
 */
Device.prototype.getInfo = function(successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'Device.getInfo', arguments);
    exec(successCallback, errorCallback, null, "Device", "getDeviceInfo", []);
};

module.exports = new Device();
});

// file: lib/common/extension/echo.js
define("xFace/extension/echo", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 将消息通过exec()传给echo扩展, 然后由echo扩展将消息传回成功回调。
 * @param successCallback   成功回调
 * @param errorCallback     失败回调
 * @param message           传给echo扩展的消息.
 * @param forceAsync        是否采用异步方式传值(用于测试js桥).
 */
module.exports = function(successCallback, errorCallback, message, forceAsync) {
    argscheck.checkArgs('ffsB', 'echo.echo', arguments);
    var action = forceAsync ? 'echoAsync' : 'echo';
    exec(successCallback, errorCallback, null, "Echo", action, [message]);
};

});

// file: lib/ios/extension/ios/Camera.js
define("xFace/extension/ios/Camera", function(require, exports, module) {
var cameraExport = {};

/**
 * 用于清除使用相机拍照存储在程序中的temp文件夹下的照片（iOS）<br/>
 * @example
        function onSuccess() {
             alert('Success!');
        }
        function onError() {
            alert('failed!');
        }

        navigator.camera.cleanup(onSuccess, onError);

 * @method cleanup
 * @for Camera
 * @param {Function} [successCallback] 成功回调方法
 * @param {Function} [errorCallback]   失败回调函数
 * @platform iOS
 * @since 3.0.0
 */
cameraExport.cleanup = function(successCallback, errorCallback) {
    var argscheck = require('xFace/argscheck');
    argscheck.checkArgs('FF', 'Camera.cleanup', arguments);
    exec(successCallback, errorCallback, null, "Camera", "cleanup", []);
};

module.exports = cameraExport;

});

// file: lib/ios/extension/ios/Contact.js
define("xFace/extension/ios/Contact", function(require, exports, module) {
var exec = require('xFace/exec'),
    argscheck = require('xFace/argscheck'),
    ContactError = require('xFace/extension/ContactError');

/**
 * Provides iOS Contact.display API.
 */
module.exports = {
    /**
     * 弹出系统联系人界面，并显示该条记录,并可以根据options参数来决定是否可以修改该记录（iOS）<br/>
     * @example
            function onSaveSuccess(contact) {
                contact.display(onError,{allowsEditing:"true"});
            }
            function onError(contactError) {
                alert('failed!');
            }

            var contact = navigator.contacts.create();
            contact.displayName = "Bob Gates";
            contact.nickname = "BG";
            contact.note = "Good Friend";
            contact.save(onSaveSuccess);

     * @method display
     * @for Contact
     * @param {Function} [errorCallback]   失败回调函数
     * @param {ContactError} errorCallback.error   错误码
     * @param {object} [options] 可选参数<br/>
     * @param {Boolean} options.allowsEditing    表示是否可以修改显示的联系人
     * @platform iOS
     * @since 3.0.0
     */
    display : function(errorCB, options) {
        argscheck.checkArgs('FO', 'contact.display', arguments);
        if (this.id === null) {
            if (typeof errorCB === "function") {
                var errorObj = new ContactError(ContactError.UNKNOWN_ERROR);
                errorCB(errorObj);
            }
        }
        else {
            exec(null, errorCB, null, "Contacts","displayContact", [this.id, options]);
        }
    }
};
});

// file: lib/ios/extension/ios/Entry.js
define("xFace/extension/ios/Entry", function(require, exports, module) {
module.exports = {
    toURL:function() {
        return "file://localhost" + this.fullPath;
    },
    toURI: function() {
        console.log("DEPRECATED: Update your code to use 'toURL'");
        return "file://localhost" + this.fullPath;
    },
    /**
    * 设置entry对象的Metadata属性.
    */
    setMetadata: function(successCallback, errorCallback, metadataObject) {
        var argscheck = require('xFace/argscheck');
        argscheck.checkArgs('fFO', 'FileEntry.setMetadata', arguments);
        exec(successCallback, errorCallback, null, "File", "setMetadata", [this.fullPath, metadataObject]);
    }
};

});

// file: lib/ios/extension/ios/FileReader.js
define("xFace/extension/ios/FileReader", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    FileReader = require('xFace/extension/FileReader'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

module.exports = {
    readAsText:function(file, encoding) {
    argscheck.checkArgs('oS', 'FileReader.readAsText', arguments);
        this.fileName = '';
        if (typeof file.fullPath === 'undefined') {
            this.fileName = file;
        } else {
            this.fileName = file.fullPath;
        }

        if (this.readyState == FileReader.LOADING) {
            throw new FileError(FileError.INVALID_STATE_ERR);
        }

        this.readyState = FileReader.LOADING;

        if (typeof this.onloadstart === "function") {
            this.onloadstart(new ProgressEvent("loadstart", {target:this}));
        }

        var enc = encoding ? encoding : "UTF-8";

        var me = this;
        exec(
            function(r) {
                if (me.readyState === FileReader.DONE) {
                    return;
                }

                me.result = decodeURIComponent(r);

                if (typeof me.onload === "function") {
                    me.onload(new ProgressEvent("load", {target:me}));
                }

                me.readyState = FileReader.DONE;

                if (typeof me.onloadend === "function") {
                    me.onloadend(new ProgressEvent("loadend", {target:me}));
                }
            },

            function(e) {
                if (me.readyState === FileReader.DONE) {
                    return;
                }

                me.readyState = FileReader.DONE;

                me.result = null;

                me.error = new FileError(e);

                if (typeof me.onerror === "function") {
                    me.onerror(new ProgressEvent("error", {target:me}));
                }

                if (typeof me.onloadend === "function") {
                    me.onloadend(new ProgressEvent("loadend", {target:me}));
                }
            },
            null, "File", "readAsText", [this.fileName, enc]);
    }
};
});

// file: lib/ios/extension/ios/contacts.js
define("xFace/extension/ios/contacts", function(require, exports, module) {
var exec = require('xFace/exec');
    argscheck = require('xFace/argscheck');

/**
 * Provides iOS enhanced contacts API.
 */
module.exports = {
     /**
     * 启动系统ui界面用于创建一个新的联系人（iOS）<br/>
     * @example
            navigator.contacts.newContactUI (onSuccess);

            function onSuccess(contactId) {
                alert("success!");
            }

     * @method newContactUI
     * @for Contacts
     * @param {Function} [successCallback]   成功回调函数
     * @param {String} successCallback.contactId   新生成的Contact的id
     * @platform iOS
     * @since 3.0.0
     */
    newContactUI : function(successCallback) {
        argscheck.checkArgs('f', 'contacts.newContactUI', arguments);
        exec(successCallback, null, null, "Contacts","newContact", []);
    },

     /**
     * 启动系统ui界面选择需要的联系人，并可以根据options参数来决定是否可以修改选择的记录（iOS）<br/>
     * @example
            navigator.contacts.chooseContact(onSuccess,{allowsEditing:"true"});

            function onSuccess(contactId) {
                alert("success!");
            }

     * @method chooseContact
     * @for Contacts
     * @param {Function} [successCallback]   成功回调函数
     * @param {String} successCallback.contactId   选择的contact的id
     * @param {object} [options] 可选参数
     * @param {Boolean} options.allowsEditing    表示是否可以修改显示的联系人
     * @platform iOS
     * @since 3.0.0
     */
    chooseContact : function(successCallback, options) {
        argscheck.checkArgs('fO', 'contacts.chooseContact', arguments);
        exec(successCallback, null, null, "Contacts","chooseContact", [options]);
    }
};
});

// file: lib/common/extension/network.js
define("xFace/extension/network", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    xFace = require('xFace'),
    channel = require('xFace/channel');

/**
 * 此对象用于获取网络连接信息，如当前的网络连接类型 (Android, iOS).<br>
 * 该类不能通过new来创建相应的对象，只能通过navigator.network.connection来使用该类定义的属性.<br>
 * 相关参考： {{#crossLink "Connection"}}{{/crossLink}}
 * @class Connection
 * @namespace navigator.network
 * @static
 * @platform Android, iOS
 * @since 3.0.0
 */
var NetworkConnection = function () {
    /**
     * 当前的网络连接类型 (Android, iOS).<br/>
     * 只读属性，其取值范围参考{{#crossLink "Connection"}}{{/crossLink}}中定义的常量
     * @example
           function checkConnection() {
               var networkState = navigator.network.connection.type;

               var states = {};
               states[Connection.UNKNOWN]  = 'Unknown connection';
               states[Connection.ETHERNET] = 'Ethernet connection';
               states[Connection.WIFI]     = 'WiFi connection';
               states[Connection.CELL_2G]  = 'Cell 2G connection';
               states[Connection.CELL_3G]  = 'Cell 3G connection';
               states[Connection.CELL_4G]  = 'Cell 4G connection';
               states[Connection.NONE]     = 'No network connection';

               alert('Connection type: ' + states[networkState]);
           }

           checkConnection();
     * @property type
     * @type String
     * @default Connection.UNKNOWN
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.type = 'unknown';
    this._firstRun = true;
    this._timer = null;
    this.timeout = 500;

    var me = this;

    channel.onxFaceReady.subscribe(function() {
        me.getInfo(function (info) {
            me.type = info;
            if (info === "none") {
                // 如果在定时器触发时仍然为offline状态，则触发offline事件
                me._timer = setTimeout(function(){
                    xFace.fireDocumentEvent("offline");
                    me._timer = null;
                    }, me.timeout);
            } else {
                // 如果有一个正在处理的offline事件，则清除之
                if (me._timer !== null) {
                    clearTimeout(me._timer);
                    me._timer = null;
                }
                xFace.fireDocumentEvent("online");
            }

            // 确保事件只被触发一次
            if (me._firstRun) {
                me._firstRun = false;
                channel.onxFaceConnectionReady.fire();
            }
        },
        function (e) {
            // 即使获取网络连接信息失败，仍然需要触发ConnectionReady事件，这样deviceready事件才有机会被触发
            if (me._firstRun) {
                me._firstRun = false;
                channel.onxFaceConnectionReady.fire();
            }
            console.log("Error initializing Network Connection: " + e);
        });
    });
};

/**
 * 获得网络连接信息
 *
 * @param successCallback 网络连接数据可用时的回调函数
 * @param errorCallback   在获取网络连接数据时出错后的回调函数（可选）
 */
NetworkConnection.prototype.getInfo = function (successCallback, errorCallback) {
    argscheck.checkArgs('fF', 'NetworkConnection.getInfo', arguments);
    exec(successCallback, errorCallback, null, "NetworkConnection", "getConnectionInfo", []);
};

module.exports = new NetworkConnection();

});

// file: lib/ios/extension/privateModule.js
define("xFace/extension/privateModule", function(require, exports, module) {
 var exec = require('xFace/exec');
 var privateModule = function(){};

 /**
  * 该接口用于js调用native功能（没有返回值）
  */
 privateModule.prototype.execCommand = function(type, args) {
    if(type === "xFace_close_application:") {
        exec(null, null, null, null, "closeApplication", args);
    } else if(type === "xFace_app_send_message:") {
        exec(null, null, null, null, "appSendMessage", args);
    } else {
        console.log("Command[" + type + "] is not supported in privateModule.js! ");
    }
 };

 privateModule.prototype.getExecV2 = function() {
    return exec;
 };

 module.exports = new privateModule();
});

// file: lib/common/extension/requestFileSystem.js
define("xFace/extension/requestFileSystem", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    FileError = require('xFace/extension/FileError'),
    FileSystem = require('xFace/extension/FileSystem'),
    exec = require('xFace/exec');

/**
 * 请求一个文件系统来存储应用数据
 * @param type  文件系统的类型
 * @param size  指示应用期望的存储大小（bytes）
 * @param successCallback  成功的回调函数
 * @param [errorCallback]    失败的回调函数
 */
var requestFileSystem = function(type, size, successCallback, errorCallback) {
    argscheck.checkArgs('nnfF', 'requestFileSystem', arguments);
    var fail = function(code) {
        if (typeof errorCallback === 'function') {
            errorCallback(new FileError(code));
        }
    };

    //TODO:目前只支持两个文件类型，以后可能会增加如APPLICATION这样的类型
    var LocalFileSystem_TEMPORARY = 0;  //临时文件
    var LocalFileSystem_PERSISTENT = 1; //持久文件
    if (type < LocalFileSystem_TEMPORARY || type > LocalFileSystem_PERSISTENT) {
        fail(FileError.SYNTAX_ERR);
    } else {
        // 如果成功，返回FileSystem对象
        var success = function(fileSystem) {
            if (fileSystem) {
                if (typeof successCallback === 'function') {

                    var result = new FileSystem(fileSystem.name, fileSystem.root);
                    successCallback(result);
                }
            }
            else {
                fail(FileError.NOT_FOUND_ERR);
            }
        };
        exec(success, fail, null, "File", "requestFileSystem", [type, size]);
    }
};

module.exports = requestFileSystem;
});

// file: lib/common/extension/resolveLocalFileSystemURI.js
define("xFace/extension/resolveLocalFileSystemURI", function(require, exports, module) {
var argscheck = require('xFace/argscheck'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry'),
    exec = require('xFace/exec');

var resolveLocalFileSystemURI = function(uri, successCallback, errorCallback) {
    argscheck.checkArgs('sfF', 'resolveLocalFileSystemURI', arguments);
    var fail = function(error) {
        if (typeof errorCallback === 'function') {
            errorCallback(new FileError(error));
        }
    };
    var success = function(entry) {
        var result;

        if (entry) {
            if (typeof successCallback === 'function') {
                result = (entry.isDirectory) ? new DirectoryEntry(entry.name, entry.fullPath) : new FileEntry(entry.name, entry.fullPath);
                try {
                    successCallback(result);
                }
                catch (e) {
                    console.log('Error invoking callback: ' + e);
                }
            }
        }
        else {
            fail(FileError.NOT_FOUND_ERR);
        }
    };

    exec(success, fail, null, "File", "resolveLocalFileSystemURI", [uri]);

};

module.exports = resolveLocalFileSystemURI;
});

// file: lib/common/extension/splashscreen.js
define("xFace/extension/splashscreen", function(require, exports, module) {

 /**
  * 该类提供splash界面的显示和隐藏功能（Android, iOS）<br/>
  * 该类只能通过navigator.splashscreen来直接使用该类中定义的方法
  * @class SplashSreen
  * @platform Android, iOS
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var SplashScreenExport = {};

/**
 * 显示splash界面（Android, iOS）
 * @example
        var imageName = "SpalshScreen.jpg";
        navigator.splashscreen.show(
            function() {
                document.getElementById('status').innerHTML = "Success";
            },
            function() {
                console.log("Error show SplashScreen ");
                document.getElementById('status').innerHTML = "Error show splashscreen.";
            },
            imageName);
 * @method show
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @param {String} [imagePath] 相对于workspace的图片路径，如果该路径无效则显示系统默认图片
 * @platform Android, iOS
 * @since 3.0.0
 */
SplashScreenExport.show = function(successCallback, errorCallback, imagePath) {
    argscheck.checkArgs('FFS', 'navigator.splashscreen.show', arguments);
    exec(successCallback, errorCallback, null, "SplashScreen", "show", [imagePath]);
};

/**
 * 隐藏splash界面（Android, iOS）
 * @example
        navigator.splashscreen.hide(
            function() {
                document.getElementById('status').innerHTML = "Success";
            },
            function() {
                console.log("Error show SplashScreen ");
                document.getElementById('status').innerHTML = "Error show splashscreen."});
 * @method hide
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback] 失败回调函数
 * @platform Android, iOS
 * @since 3.0.0
 */
SplashScreenExport.hide = function(successCallback, errorCallback) {
    argscheck.checkArgs('FF', 'navigator.splashscreen.hide', arguments);
    exec(successCallback, errorCallback, null, "SplashScreen", "hide", []);
};
module.exports = SplashScreenExport;
});

// file: lib/common/localStorage.js
define("xFace/localStorage", function(require, exports, module) {
var xFace = require('xFace');
var privateModule = require('xFace/privateModule');

var m_window_addEventListener = window.addEventListener;
var m_window_removeEventListener = window.removeEventListener;

var m_localStorage_setItem = localStorage.setItem;
var m_localStorage_getItem = localStorage.getItem;
var m_localStorage_removeItem = localStorage.removeItem;

var localstorageFunMap = {};
var keyPrefix = "_";
var keySeparator = ",";

function getNewKey(appId, key){
    var newKey = appId + keyPrefix + key;
    return newKey;
}

window.addEventListener = function(evt, handler, capture) {
    var evtLowCase = evt.toLowerCase();
    if("storage" == evtLowCase){
            var storageCallback = function(storageEvent){
            var key = storageEvent.key;
            var endAppIdIndex = key.indexOf(keyPrefix);
            var eventAppId = key.substr(0, endAppIdIndex);
            if(privateModule.getAppId() == eventAppId){
                handler.call(window, evt, capture);
            }
        };
        localstorageFunMap[handler] = storageCallback;
        m_window_addEventListener.call(window, evt, storageCallback, capture);
    } else {
        m_window_addEventListener.call(window, evt, handler, capture);
    }
};

window.removeEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    if("storage" == e){
        m_document_removeEventListener.call(window, evt, localstorageFunMap[handler], capture);
    } else {
        m_window_removeEventListener.call(window, evt, handler, capture);
    }
};

localStorage.setItem = function(key, value){
    var currentAppId = privateModule.getAppId();
    var newKey = getNewKey(currentAppId, key);
    m_localStorage_setItem.call(localStorage, newKey, value);
    //更新以appId为键值的数据，其中存储的是所有属于该app的key值
    var keyList = m_localStorage_getItem.call(localStorage, currentAppId);
    if(null === keyList || "" === keyList){
        keyList = key;
        m_localStorage_setItem.call(localStorage, currentAppId, keyList);
    }else{
        var isNewKey = true;
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                isNewKey = false;
                break;
            }
        }
        if(isNewKey){
            keyList = keyList + keySeparator + key;
            m_localStorage_setItem.call(localStorage, currentAppId, keyList);
        }
    }
};

localStorage.getItem = function(key){
    var newKey = getNewKey(privateModule.getAppId(), key);
    var value = m_localStorage_getItem.call(localStorage, newKey);
    return value;
};

localStorage.removeItem = function(key){
    var currentAppId = privateModule.getAppId();
    var newKey = getNewKey(currentAppId, key);
    m_localStorage_removeItem.call(localStorage, newKey);
    //更新保存的keyList，删除相应的key
    var keyList = m_localStorage_getItem.call(localStorage, currentAppId);
    if(null !== keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var tempKey = keyArray[index];
            if(key == tempKey){
                keyArray.splice(index, 1);
                break;
            }
        }
        m_localStorage_setItem.call(localStorage, currentAppId, keyArray.join(keySeparator));
    }
};

localStorage.key = function(index){
    var nonNegative = /^\d+(\.\d+)?$/;
    if(nonNegative.test(index)){
        var realIndex = Math.floor(index);
        var keyList = m_localStorage_getItem.call(localStorage, privateModule.getAppId());
        if((null !== keyList) && ("" !== keyList)){
            var keyArray = keyList.split(keySeparator);
            if(realIndex < keyArray.length){
                var key = keyArray[realIndex];
                return key;
            }
        }
    }
    return null;
};

localStorage.clear = function(){
    //删除当前的app所有的数据，keyList保存了所有属于该app的key值，根据它的信息
    //可以删除全部的数据
    self.clearAppData(privateModule.getAppId());
};

var self = {
    //删除指定的appId所对应的应用的数据。
    clearAppData : function(appId) {
        var keyList = m_localStorage_getItem.call(localStorage, appId);
        if(null !== keyList){
            var keyArray = keyList.split(keySeparator);
            for ( var index = 0; index < keyArray.length; index++){
                var key = keyArray[index];
                var newKey = getNewKey(appId, key);
                m_localStorage_removeItem.call(localStorage, newKey);
            }
        }
        m_localStorage_removeItem.call(localStorage, appId);
    },
    getOriginalLocalStorage : function() {
        return {'setItem': m_localStorage_setItem, 'getItem': m_localStorage_getItem, 'removeItem': m_localStorage_removeItem};
    }
};

module.exports = self;
});

// file: lib/ios/platform.js
define("xFace/platform", function(require, exports, module) {
module.exports = {
    id: "ios",
    initialize:function() {
        var channel = require('xFace/channel');
        var xFace = require('xFace');
        var privateModule = require('xFace/privateModule');

        channel.onVolumeDownKeyDown = xFace.addDocumentEventHandler('volumedownbutton');
        channel.onVolumeUpKeyDown = xFace.addDocumentEventHandler('volumeupbutton');
        // TODO:处理geolocation

        //重写window.openDatabase接口
        // 给每个app的数据库的名字加appId，以避免不同的app使用同名字的数据库
        var currentAppId = privateModule.getAppId();
        var originalOpenDatabase = window.openDatabase;
        window.openDatabase = function(name, version, desc, size) {
            var db = null;
            var newname = currentAppId + name;
            db = originalOpenDatabase(newname, version, desc, size);
            return db;
        };
    },
    objects: {
        File: { // exists natively, override
            path: 'xFace/extension/File'
        },
        FileReader:{
            path: 'xFace/extension/FileReader'
        },
        console: {
            path: 'xFace/extension/console'
        },
        localStorage : {
            path : 'xFace/localStorage'
        },
        MediaError: {
            path: 'xFace/extension/MediaError'
        },
        open: { // exists natively, override
            path: 'xFace/extension/InAppBrowser'
        }
    },
    merges:{
        Entry:{
            path: 'xFace/extension/ios/Entry'
        },
        FileReader:{
            path: 'xFace/extension/ios/FileReader'
        },
        Contact:{
            path: 'xFace/extension/ios/Contact'
        },
        navigator:{
            children:{
                contacts:{
                    path: 'xFace/extension/ios/contacts'
                },
                camera:{
                    path: 'xFace/extension/ios/Camera'
                }
            }
        }
    }
};

});

// file: lib/common/privateModule.js
define("xFace/privateModule", function(require, exports, module) {
var channel = require('xFace/channel');
//该变量用于保存当前应用的ID
var currentAppId = null;
var securityMode = false;
var privateModule = function() {
};

channel.waitForInitialization('onPrivateDataReady');

/**
 * 由引擎初始化数据
 */
privateModule.prototype.initPrivateData = function(initData) {
    currentAppId = initData[0];
    securityMode = initData[1];
    channel.onPrivateDataReady.fire();
};

privateModule.prototype.getAppId = function() {
    return currentAppId;
};

privateModule.prototype.isSecurityMode = function() {
    return securityMode;
};

module.exports = new privateModule();
});

// file: lib/common/utils.js
define("xFace/utils", function(require, exports, module) {
var utils = exports;

/**
 * Returns an indication of whether the argument is an array or not
 */
utils.isArray = function(a) {
    return Object.prototype.toString.call(a) == '[object Array]';
};

/**
 * Returns an indication of whether the argument is a Date or not
 */
utils.isDate = function(d) {
    return Object.prototype.toString.call(d) == '[object Date]';
};

/**
 * Does a deep clone of the object.
 */
utils.clone = function(obj) {
    if(!obj || typeof obj == 'function' || utils.isDate(obj) || typeof obj != 'object') {
        return obj;
    }

    var retVal, i;

    if(utils.isArray(obj)){
        retVal = [];
        for(i = 0; i < obj.length; ++i){
            retVal.push(utils.clone(obj[i]));
        }
        return retVal;
    }

    retVal = {};
    for(i in obj){
        if(!(i in retVal) || retVal[i] != obj[i]) {
            retVal[i] = utils.clone(obj[i]);
        }
    }
    return retVal;
};

/**
 * 返回一个函数的封装版本
 */
utils.close = function(context, func, params) {
    if (typeof params == 'undefined') {
        return function() {
            return func.apply(context, arguments);
        };
    } else {
        return function() {
            return func.apply(context, params);
        };
    }
};

/**
 * Create a UUID
 */
utils.createUUID = function() {
    return UUIDcreatePart(4) + '-' +
        UUIDcreatePart(2) + '-' +
        UUIDcreatePart(2) + '-' +
        UUIDcreatePart(2) + '-' +
        UUIDcreatePart(6);
};

/**
 * 经典的原型链集成方法
 */
utils.extend = (function() {
    // proxy used to establish prototype chain
    var F = function() {};
    // extend Child from Parent
    return function(Child, Parent) {
        F.prototype = Parent.prototype;
        Child.prototype = new F();
        Child.__super__ = Parent.prototype;
        Child.prototype.constructor = Child;
    };
}());

/**
 * Alert 一个消息，但没有alert的时候，console会被调用.
 */
utils.alert = function(msg) {
    if (alert) {
        alert(msg);
    } else if (console && console.log) {
        console.log(msg);
    }
};

/**
 * Formats a string and arguments following it ala sprintf()
 *
 * see utils.vformat() for more information
 */
utils.format = function(formatString /* ,... */) {
    var args = [].slice.call(arguments, 1);
    return utils.vformat(formatString, args);
};

/**
 * 格式化一个字符串,类似于vsprintf
 */
utils.vformat = function(formatString, args) {
    if (formatString === null || formatString === undefined) return "";
    if (arguments.length == 1) return formatString.toString();

    var pattern = /(.*?)%(.)(.*)/;
    var rest    = formatString.toString();
    var result  = [];

    while (args.length) {
        var arg   = args.shift();
        var match = pattern.exec(rest);

        if (!match) break;

        rest = match[3];

        result.push(match[1]);

        if (match[2] == '%') {
            result.push('%');
            args.unshift(arg);
            continue;
        }

        result.push(formatted(arg, match[2]));
    }

    result.push(rest);

    return result.join('');
};

//------------------------------------------------------------------------------
function UUIDcreatePart(length) {
    var uuidpart = "";
    for (var i=0; i<length; i++) {
        var uuidchar = parseInt((Math.random() * 256), 10).toString(16);
        if (uuidchar.length == 1) {
            uuidchar = "0" + uuidchar;
        }
        uuidpart += uuidchar;
    }
    return uuidpart;
}

//------------------------------------------------------------------------------
function formatted(object, formatChar) {

    switch(formatChar) {
        case 'j':
        case 'o': return JSON.stringify(object);
        case 'c': return '';
    }

    if (null === object) return Object.prototype.toString.call(object);

    return object.toString();
}
});


window.xFace = require('xFace');

// file: lib/scripts/bootstrap.js
(function (context) {
    var channel = require("xFace/channel"),
        _self = {
            boot: function (data) {

                /**
                 * Create all xFace objects once page has fully loaded and native side is ready.
                 */
                channel.join(function() {
                    var builder = require('xFace/builder'),
                        base = require('xFace/common'),
                        platform = require('xFace/platform');

                    // Drop the common globals into the window object, but be nice and don't overwrite anything.
                    builder.build(base.objects).intoButDontClobber(window);

                    // Drop the platform-specific globals into the window object
                    // and clobber any existing object.
                    builder.build(platform.objects).intoAndClobber(window);
                    // Merge the platform-specific overrides/enhancements into
                    // the window object.
                    if (typeof platform.merges !== 'undefined') {
                      builder.build(platform.merges).intoAndMerge(window);
                   }
                    // Call the platform-specific initialization
                    platform.initialize();
                    // Fire event to notify that all objects are created
                    channel.onxFaceReady.fire();

                    // Fire onDeviceReady event once all constructors have run and
                    // xFace info has been received from native side.
                    channel.join(function() {
                        require('xFace').fireDocumentEvent('deviceready',  {"data":data});
                    }, channel.deviceReadyChannelsArray);

                }, [ channel.onDOMContentLoaded, channel.onNativeReady ]);
            }
        };

    // boot up once native side is ready
    channel.onNativeReady.subscribe(_self.boot);

    // _nativeReady is global variable that the native side can set
    // to signify that the native code is ready. It is a global since
    // it may be called before any xFace JS is ready.
    if (window._nativeReady) {
        channel.onNativeReady.fire();
    }

}(window));


})();