// File generated at :: Thu Nov 22 2012 11:08:33 GMT+0800 (CST)


;(function() {

// file: lib/scripts/require.js
var require,
    define;

(function () {
    var modules = {};

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
        }
        return modules[id].factory ? build(modules[id]) : modules[id].exports;
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
if (document.readyState == 'complete') {
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
    windowEventHandlers = {}

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
    // If unsubcribing from an event that is handled by an extension
    if (typeof documentEventHandlers[e] != "undefined") {
        documentEventHandlers[e].unsubscribe(handler);
    } else {
        m_document_removeEventListener.call(document, evt, handler, capture);
    }
};

window.removeEventListener = function(evt, handler, capture) {
    var e = evt.toLowerCase();
    // If unsubcribing from an event that is handled by an extension
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
    addWindowEventHandler:function(event, opts) {
      return (windowEventHandlers[event] = channel.create(event, opts));
    },
    addDocumentEventHandler:function(event, opts) {
      return (documentEventHandlers[event] = channel.create(event, opts));
    },
    removeWindowEventHandler:function(event) {
      delete windowEventHandlers[event];
    },
    removeDocumentEventHandler:function(event) {
      delete documentEventHandlers[event];
    },
    /**
     * Retreive original event handlers that were replaced by xFace
     *
     * @return object
     */
    getOriginalHandlers: function() {
        return {'document': {'addEventListener': m_document_addEventListener, 'removeEventListener': m_document_removeEventListener},
        'window': {'addEventListener': m_window_addEventListener, 'removeEventListener': m_window_removeEventListener}};
    },
    /**
     * Method to fire event from native code
     */
    fireDocumentEvent: function(type, data) {
      var evt = createEvent(type, data);
      if (typeof documentEventHandlers[type] != 'undefined') {
        documentEventHandlers[type].fire(evt);
      } else {
        document.dispatchEvent(evt);
      }
    },
    fireWindowEvent: function(type, data) {
      var evt = createEvent(type,data);
      if (typeof windowEventHandlers[type] != 'undefined') {
        windowEventHandlers[type].fire(evt);
      } else {
        window.dispatchEvent(evt);
      }
    },
    // TODO: this is Android only; think about how to do this better
    shuttingDown:false,
    UsePolling:false,
    // END TODO

    // TODO: iOS only
    // This queue holds the currently executing command and all pending
    // commands executed with xFace.exec().
    commandQueue:[],
    // Indicates if we're currently in the middle of flushing the command
    // queue on the native side.
    commandQueueFlushing:false,
    // END TODO
    /**
     * Extension callback mechanism.
     */
    callbackId: 0,
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

    /**
     * Called by native code when returning successful result from an action.
     *
     * @param callbackId
     * @param args
     */
       callbackSuccess: function(callbackId, args) {
        if (xFace.callbacks[callbackId]) {

            // If result is to be sent to callback
            if (args.status == xFace.callbackStatus.OK) {
                try {
                    if (xFace.callbacks[callbackId].success) {
                        xFace.callbacks[callbackId].success(args.message);
                    }
                }
                catch (e) {
                    console.log("Error in success callback: "+callbackId+" = "+e);
                }
            }

            // Clear callback if not expecting any more results
            if (!args.keepCallback) {
                delete xFace.callbacks[callbackId];
            }
        }
    },
    /**
     * Called by native code when returning error result from an action.
     *
     * @param callbackId
     * @param args
     */
    callbackError: function(callbackId, args) {
        if (xFace.callbacks[callbackId]) {
            try {
                if (xFace.callbacks[callbackId].fail) {
                    xFace.callbacks[callbackId].fail(args.message);
                }
            }
            catch (e) {
                console.log("Error in error callback: "+callbackId+" = "+e);
            }

            // Clear callback if not expecting any more results
            if (!args.keepCallback) {
                delete xFace.callbacks[callbackId];
            }
        }
    },

     /**
     * Called by native code when status changed from an async action.
     *
     * @param callbackId
     * @param args
     */
    callbackStatusChanged : function(callbackId, args){
        if(xFace.callbacks[callbackId]){
            if(args.status == xFace.callbackStatus.PROGRESS_CHANGING){
                try{
                    if(xFace.callbacks[callbackId].statusChanged){
                        xFace.callbacks[callbackId].statusChanged(args.message);
                    }
                }catch(e){
                    console.log("Error in statuschageed callback: " + callbackId + "=" + e);
                }
            }
        }
        // Clear callback if not expecting any more results
        if(!args.keepCallback){
            delete xFace.callbacks[callbackId];
        }
    },

    addConstructor: function(func) {
        channel.onxFaceReady.subscribeOnce(function() {
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
// Register pause, resume and deviceready channels as events on document.
channel.onPause = xFace.addDocumentEventHandler('pause');
channel.onResume = xFace.addDocumentEventHandler('resume');
channel.onDeviceReady = xFace.addDocumentEventHandler('deviceready');

module.exports = xFace;
});

// file: lib/common/app.js
define("xFace/app", function(require, exports, module) {
var channel = require('xFace/channel');
var message = channel.create("message");
var gstorage = require('xFace/localStorage');
var start = channel.create("start");
var close = channel.create("close");

var app =
{
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

    sendMessage:function(data, appid){

        function toString(data)
        {
            var result;
            if( typeof data == 'string'){
                result = data;
            }else if( data != null && typeof data == 'object'){
                result = data.toString();
            }
            return result;

        }
        function generateUniqueMsgId()
        {
            var msgId = parseInt((Math.random() * 65535), 10).toString(10);
            while(null != gstorage.getOriginalLocalStorage().getItem.call(localStorage, msgId))
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
}
module.exports = app;
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
var utils = require('xFace/utils');

/**
 * Channel
 * @constructor
 * @param type String 通道的名字
 * @param opts  Object opts可选, 目前支持存储两个回调函数，onSubscribe，onUnsubscript，在订阅和反订阅回调的时候被调用
 */
var Channel = function(type, opts) {
    this.type = type;
    this.handlers = {};
    this.numHandlers = 0;
    this.guid = 0;
    this.fired = false;
    this.enabled = true;
    this.events = {
        onSubscribe:null,
        onUnsubscribe:null
    };
    if (opts) {
        if (opts.onSubscribe) this.events.onSubscribe = opts.onSubscribe;
        if (opts.onUnsubscribe) this.events.onUnsubscribe = opts.onUnsubscribe;
    }
},
    channel = {
    /**
     * 所有的通道被fire之后，才会执行提供的函数
     * @param h 需要执行的函数
     * @param c 通道数组
     */
        join: function (h, c) {
            var i = c.length;
            var len = i;
            var f = function() {
                if (!(--i)) h();
            };
            for (var j=0; j<len; j++) {
                !c[j].fired?c[j].subscribeOnce(f):i--;
            }
            if (!i) h();
        },
        create: function (type, opts) {
            channel[type] = new Channel(type, opts);
            return channel[type];
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
         **/
         waitForInitialization: function(feature) {
            if (feature) {
                var c = null;
                if (this[feature]) {
                    c = this[feature];
                }
                else {
                    c = this.create(feature);
                }
                this.deviceReadyChannelsMap[feature] = c;
                this.deviceReadyChannelsArray.push(c);
            }
        },

         /**
          * feature初始化代码已经完成，表明feature提供的能够已经能够使用
          **/
        initializationComplete: function(feature) {
            var c = this.deviceReadyChannelsMap[feature];
            if (c) {
                c.fire();
            }
        }
    };

function forceFunction(f) {
    if (f === null || f === undefined || typeof f != 'function') throw "Function required as first argument!";
}

/**
 * 订阅一个函数
 */
Channel.prototype.subscribe = function(f, c, g) {
    // need a function to call
    forceFunction(f);

    var func = f;
    if (typeof c == "object") { func = utils.close(c, f); }

    g = g || func.observer_guid || f.observer_guid || this.guid++;
    func.observer_guid = g;
    f.observer_guid = g;
    this.handlers[g] = func;
    this.numHandlers++;
    if (this.events.onSubscribe) this.events.onSubscribe.call(this);
    return g;
};

/**
 * 订阅一个函数，在该函数执行之后，会被反订阅
 */
Channel.prototype.subscribeOnce = function(f, c) {
    // need a function to call
    forceFunction(f);

    var g = null;
    var _this = this;
    var m = function() {
        f.apply(c || null, arguments);
        _this.unsubscribe(g);
    };
    if (this.fired) {
        if (typeof c == "object") { f = utils.close(c, f); }
        f.apply(this, this.fireArgs);
    } else {
        g = this.subscribe(m);
    }
    return g;
};

/**
 * 从通道中反订阅一个函数
 */
Channel.prototype.unsubscribe = function(g) {
    // need a function to unsubscribe
    if (g === null || g === undefined) { throw "You must pass _something_ into Channel.unsubscribe"; }

    if (typeof g == 'function') { g = g.observer_guid; }
    var handler = this.handlers[g];
    if (handler) {
        this.handlers[g] = null;
        delete this.handlers[g];
        this.numHandlers--;
        if (this.events.onUnsubscribe) this.events.onUnsubscribe.call(this);
    }
};

/**
 * fire 通道中的所有订阅的函数
 */
Channel.prototype.fire = function(e) {
    if (this.enabled) {
        var fail = false;
        this.fired = true;
        for (var item in this.handlers) {
            var handler = this.handlers[item];
            if (typeof handler == 'function') {
                var rv = (handler.apply(this, arguments)===false);
                fail = fail || rv;
            }
        }
        this.fireArgs = arguments;
        return !fail;
    }
    return true;
};

channel.create('onDOMContentLoaded');

channel.create('onNativeReady');

channel.create('onxFaceReady');

channel.create('onxFaceInfoReady');

channel.create('onxFaceConnectionReady');

channel.create('onDeviceReady');


channel.create('onResume');

channel.create('onPause');

channel.create('onDestroy');

channel.waitForInitialization('onxFaceReady');
channel.waitForInitialization('onxFaceConnectionReady');

module.exports = channel;
});

// file: lib/common/common.js
define("xFace/common", function(require, exports, module) {
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
        }
    }
};
});

// file: lib/ios/exec.js
define("xFace/exec", function(require, exports, module) {
var xFace = require('xFace'),
    utils = require('xFace/utils'),
    jsBridge,
    createJsBridge = function() {
        jsBridge = document.createElement("iframe");
        jsBridge.setAttribute("style", "display:none;");
        jsBridge.setAttribute("height","0px");
        jsBridge.setAttribute("width","0px");
        jsBridge.setAttribute("frameborder","0");
        document.documentElement.appendChild(jsBridge);
    },
    channel = require('xFace/channel');

module.exports = function() {
    if (!channel.onxFaceReady.fired) {
        utils.alert("ERROR: Attempting to call xFace.exec()" + " before 'deviceready'. Ignoring.");
        return;
    }
    var successCallback, failCallback, service, action, actionArgs, splitCommand;
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

    // Start building the command object.
    var command = {
        className: service,
        methodName: action,
        "arguments": []
    };

    // Register the callbacks and add the callbackId to the positional
    // arguments if given.
    if (successCallback || failCallback || statusChangedCallback) {
        callbackId = service + xFace.callbackId++;
        xFace.callbacks[callbackId] =
        {success:successCallback, fail:failCallback, statusChanged:statusChangedCallback};
    }
    // If callbackId is null, it will become NSNull in native
    command["arguments"].push(callbackId);

    for (var i = 0; i < actionArgs.length; ++i) {
        command["arguments"].push(actionArgs[i]);
    }

    // Stringify and queue the command. We stringify to command now to
    // effectively clone the command arguments in case they are mutated before
    // the command is executed.
    xFace.commandQueue.push(JSON.stringify(command));

    // If the queue length is 1, then that means it was empty before we queued
    // the given command, so let the native side know that we have some
    // commands to execute, unless the queue is currently being flushed, in
    // which case the command will be picked up without notification.
    if (xFace.commandQueue.length == 1 && !xFace.commandQueueFlushing) {
        if (!jsBridge) {
            createJsBridge();
        }

        jsBridge.src = "xface://ready";
    }
};
});

// file: lib/common/extension/Acceleration.js
define("xFace/extension/Acceleration", function(require, exports, module) {
var Acceleration = function(x, y, z, timestamp) {
  this.x = x;
  this.y = y;
  this.z = z;
  this.timestamp = timestamp || (new Date()).getTime();
};

module.exports = Acceleration;
});

// file: lib/common/extension/AdvancedFileTransfer.js
define("xFace/extension/AdvancedFileTransfer", function(require, exports, module) {
var exec = require('xFace/exec'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

/**
 * @constructor
 * @param source {String}            文件传输的源文件地址（下载时为服务器地址，上传时为本地路径）
 * @param target {String}             文件传输的目标地址（下载时为本地路径，上传时为服务器地址）
 * @param isUpload {boolean}      标识是上传还是下载（默认为false，即默认为下载，iOS目前还不支持上传）
 */
var AdvancedFileTransfer = function(source, target, isUpload) {
    this.source = source;
    this.target = target;
    this.isUpload = isUpload || false;
    this.onprogress = null;     // While download the file, and reporting partial download data
};

/**
 * 下载一个文件到指定的路径
 * @param successCallback         成功回调函数
 * @param errorCallback           失败回调函数
 */
AdvancedFileTransfer.prototype.download = function(successCallback, errorCallback) {
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

AdvancedFileTransfer.prototype.pause = function() {
    exec(null, null, null, 'AdvancedFileTransfer', 'pause', [this.source]);
};

AdvancedFileTransfer.prototype.cancel = function() {
    exec(null, null, null, 'AdvancedFileTransfer', 'cancel', [this.source, this.target, this.isUpload]);
};

module.exports = AdvancedFileTransfer;
});

// file: lib/common/extension/BarcodeScanner.js
define("xFace/extension/BarcodeScanner", function(require, exports, module) {
var exec = require('xFace/exec');
function BarcodeScanner(){};

/**
 * 启动条形码扫描器
 * @param successCallback         成功回调函数
 * @param errorCallback           失败回调函数
 */
BarcodeScanner.prototype.start = function(successCallback, errorCallback){
    exec(successCallback, errorCallback, null, "BarcodeScanner", "start", []);
}
module.exports = new BarcodeScanner();
});

// file: lib/common/extension/Calendar.js
define("xFace/extension/Calendar", function(require, exports, module) {
var exec = require('xFace/exec');
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
 * 打开原生时间控件(iOS不支持传参初始化,默认为系统当前时间).
 * 可以指定控件显示的初始时间，默认为当前时间.
 * @param {Function} success   成功的回调函数，返回用户设置的时间
 * @param {Function} fail      失败的回调函数
 * @param {Number} hours   初始小时值(可选)
 * @param {Number} minutes 初始分钟值(可选)
 */
Calendar.prototype.getTime = function(success, fail, hours, minutes) {
    var hours = parseInt(hours,10);
	var minutes = parseInt(minutes,10);

	var checkTime = function(hours, minutes) {
		//实例一个Date对象
		var d = new Date();
		d.setHours(hours);
		d.setMinutes(minutes);
		if(d.getHours() == hours
		   && d.getMinutes() == minutes){
			return true;
		}
		return false;
	};

    if(typeof hours  != "number" || typeof minutes  != "number" ||
		(hours < MIN_HOURS) || (minutes < MIN_MINUTES) ||
		(hours > MAX_HOURS) || (minutes > MAX_MINUTES) ||
		!checkTime(hours, minutes)){
        if(fail && typeof fail == "function") {
            fail("The parameter is invalid! ");
        }
        return;
    }
    exec(success, fail, null, "Calendar", "getTime", [hours, minutes]);
}

/**
 * 打开原生日期控件.(iOS不支持传参初始化,默认为系统当前时间)
 * 可以指定控件显示的初始时间，默认为当前日期.
 * @param {Function} success   成功的回调函数，返回用户设置的日期
 * @param {Function} fail      失败的回调函数
 * @param {Number} year    初始年值(可选)
 * @param {Number} month   初始月份值(可选)
 * @param {Number} day     初始日值(可选)
 */
Calendar.prototype.getDate = function(success, fail, year, month, day) {
    var year = parseInt(year,10);
    var month = parseInt(month,10);
    var day = parseInt(day,10);

	var checkDate = function(year, month, day) {
		//实例一个Date对象
		var d = new Date();
		//设置Date对象的各个属性值，注意月份是从0开始，因此减1
		d.setFullYear(year);
		d.setMonth(month-1);
		d.setDate(day);
		//判断输入时期是否合法 ，同样月份需要加1
		if(d.getFullYear() == year
		   && d.getMonth()+1 == month
		   && d.getDate()== day){
			return true;
		}
		return false;
	};

    if(typeof year  != "number" || typeof month  != "number" || typeof day  != "number" ||
		(year < MIN_YEARS) || (month < MIN_MONTHS) || (day < MIN_DAYS) ||
		(year > MAX_YEARS) || (month > MAX_MONTHS) || (day > MAX_DAYS) ||
		!checkDate(year,month,day)){
        if(fail && typeof fail == "function") {
            fail("The parameter is invalid! ");
        }
        return;
    }
    exec(success, fail, null, "Calendar", "getDate",[year, month, day]);
}

module.exports = new Calendar();
});

// file: lib/common/extension/Camera.js
define("xFace/extension/Camera", function(require, exports, module) {
var exec = require('xFace/exec'),
    Camera = require('xFace/extension/CameraConstants');

var cameraExport = {};

// Tack on the Camera Constants to the base camera plugin.
for (var key in Camera) {
    cameraExport[key] = Camera[key];
}

/**
 * 根据"options.sourceType"从 source中获取一张图片,并根据"options.destinationType"
 * 决定返回图片的结果
 * sourceType默认是CAMERA 即使用相机获取图片
 * destinationType默认是FILE_URL. 即返回包含图片路径的file协议
 *
 * @param {Function} successCallback 成功回调方法
 * @param {Function} errorCallback 失败回调方法
 * @param {Object} options 可选参数
 */
cameraExport.getPicture = function(successCallback, errorCallback, options) {
    // successCallback required
    if (typeof successCallback != "function") {
        console.log("Camera Error: successCallback is not a function");
        return;
    }

    // errorCallback optional
    if (errorCallback && (typeof errorCallback != "function")) {
        console.log("Camera Error: errorCallback is not a function");
        return;
    }

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
  DestinationType:{
    DATA_URL: 0,         // Return base64 encoded string
    FILE_URI: 1          // Return file uri (content://media/external/images/media/2 for Android)
  },
  EncodingType:{
    JPEG: 0,             // Return JPEG encoded image
    PNG: 1               // Return PNG encoded image
  },
  MediaType:{
    PICTURE: 0,          // allow selection of still pictures only. DEFAULT. Will return format specified via DestinationType
    VIDEO: 1,            // allow selection of video only, ONLY RETURNS URL
    ALLMEDIA : 2         // allow selection from all media types
  },
  PictureSourceType:{
    PHOTOLIBRARY : 0,    // Choose image from picture library (same as SAVEDPHOTOALBUM for Android)
    CAMERA : 1,          // Take picture from camera
    SAVEDPHOTOALBUM : 2  // Choose image from picture library (same as PHOTOLIBRARY for Android)
  }
};
});

// file: lib/common/extension/CaptureAudioOptions.js
define("xFace/extension/CaptureAudioOptions", function(require, exports, module) {
var CaptureAudioOptions = function(){
    //在单个采集操作期间能够记录的音频剪辑数量最大值，必须设定为大于等于1（默认值为1）
    this.limit = 1;
    //一个音频剪辑的最长时间，单位为秒。(android平台不支持)
    this.duration = 0;
    //选定的音频模式，必须设定为capture.supportedAudioModes枚举中的值。(android平台不支持)
    this.mode = null;
};

module.exports = CaptureAudioOptions;
});

// file: lib/common/extension/CaptureError.js
define("xFace/extension/CaptureError", function(require, exports, module) {
var CaptureError = function(c) {
   this.code = c || null;
};

// 摄像头或者耳机采集图片或声音失败。
CaptureError.CAPTURE_INTERNAL_ERR = 0;
// 摄像头或者音频采集程序正在处理别的采集请求。
CaptureError.CAPTURE_APPLICATION_BUSY = 1;
// 非法的API调用(Limit 参数的值小于1)。
CaptureError.CAPTURE_INVALID_ARGUMENT = 2;
// 在采集到任何信息之前用户退出了摄像头或者音频采集程序。
CaptureError.CAPTURE_NO_MEDIA_FILES = 3;
// 采集信息的请求是不支持的请求。
CaptureError.CAPTURE_NOT_SUPPORTED = 20;

module.exports = CaptureError;
});

// file: lib/common/extension/CaptureImageOptions.js
define("xFace/extension/CaptureImageOptions", function(require, exports, module) {
var CaptureImageOptions = function(){
    // 在单个采集操作期间能够采集的图像数量最大值，必须设定为大于等于1（默认值为1）。
    this.limit = 1;
    // 选定的图像模式，必须设定为capture.supportedImageModes枚举中的值。(android平台不支持)
    this.mode = null;
};

module.exports = CaptureImageOptions;
});

// file: lib/common/extension/CaptureVideoOptions.js
define("xFace/extension/CaptureVideoOptions", function(require, exports, module) {
var CaptureVideoOptions = function(){
    //在单个采集操作期间能够采集的视频剪辑数量最大值，必须设定为大于等于1（默认值为1）。
    this.limit = 1;
    //一个视频剪辑的最长时间，单位为秒。(android平台不支持)
    this.duration = 0;
    //选定的视频采集模式，必须设定为capture.supportedVideoModes枚举中的值。(android平台不支持)
    this.mode = null;
};

module.exports = CaptureVideoOptions;
});

// file: lib/common/extension/CompassError.js
define("xFace/extension/CompassError", function(require, exports, module) {
var CompassError = function(err) {
    this.code = (err !== undefined ? err : null);
};

CompassError.COMPASS_INTERNAL_ERR = 0;
CompassError.COMPASS_NOT_SUPPORTED = 20;

module.exports = CompassError;
});

// file: lib/common/extension/CompassHeading.js
define("xFace/extension/CompassHeading", function(require, exports, module) {
var CompassHeading = function(magneticHeading, trueHeading, headingAccuracy, timestamp) {
  this.magneticHeading = (magneticHeading !== undefined ? magneticHeading : null);
  this.trueHeading = (trueHeading !== undefined ? trueHeading : null);
  this.headingAccuracy = (headingAccuracy !== undefined ? headingAccuracy : null);
  this.timestamp = (timestamp !== undefined ? timestamp : new Date().getTime());
};

module.exports = CompassHeading;
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
module.exports = {
        UNKNOWN: "unknown",
        ETHERNET: "ethernet",
        WIFI: "wifi",
        CELL_2G: "2g",
        CELL_3G: "3g",
        CELL_4G: "4g",
        NONE: "none"
};
});

// file: lib/common/extension/Contact.js
define("xFace/extension/Contact", function(require, exports, module) {
var exec = require('xFace/extension/privateModule').getExecV2(),
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
 * 单个联系人包含的信息
 * @constructor
 * @param {DOMString} id 唯一标示
 * @param {DOMString} displayName
 * @param {ContactName} name
 * @param {DOMString} nickname
 * @param {Array.<ContactField>} phoneNumbers 电话号码的数组
 * @param {Array.<ContactField>} emails email地址数组
 * @param {Array.<ContactAddress>} addresses 地址数组
 * @param {Array.<ContactField>} ims 即时通讯用户的 id
 * @param {Array.<ContactOrganization>} organizations
 * @param {DOMString} birthday
 * @param {DOMString} note 用户对此联系人的注释
 * @param {Array.<ContactField>} photos
 * @param {Array.<ContactField>} categories  （Android、iOS系统无对应属性）
 * @param {Array.<ContactField>} urls 联系人的网站
 */
var Contact = function (id, displayName, name, nickname, phoneNumbers, emails, addresses,
    ims, organizations, birthday, note, photos, categories, urls) {
    this.id = id || null;
    this.rawId = null;
    this.displayName = displayName || null;
    this.name = name || null; // ContactName
    this.nickname = nickname || null;
    this.phoneNumbers = phoneNumbers || null; // ContactField[]
    this.emails = emails || null; // ContactField[]
    this.addresses = addresses || null; // ContactAddress[]
    this.ims = ims || null; // ContactField[]
    this.organizations = organizations || null; // ContactOrganization[]
    this.birthday = birthday || null;
    this.note = note || null;
    this.photos = photos || null; // ContactField[]
    this.categories = categories || null; // ContactField[]
    this.urls = urls || null; // ContactField[]
};

/**
 * 从设备的存储中清除联系人.
 */
Contact.prototype.remove = function(successCallback, errorCallback) {
    var fail = function(code) {
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
 * 创建一个联系人的深拷贝.
 * 域中的 Id 均设置为 null.
 * 拷贝成功后返回拷贝的对象
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
 * 保存联系人信息到设备存储中.
 * 存储成功后返回此联系人的 JSONObject，失败后得到错误信息
 */
Contact.prototype.save = function(successCallback, errorCallback) {
    var fail = function(code) {
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
var ContactAccountType = function() {
};

ContactAccountType.All = "All";
ContactAccountType.Phone = "Phone";
ContactAccountType.SIM = "SIM";

module.exports = ContactAccountType;
});

// file: lib/common/extension/ContactAddress.js
define("xFace/extension/ContactAddress", function(require, exports, module) {
var ContactAddress = function(pref, type, formatted, streetAddress, locality, region, postalCode, country) {
    this.id = null;
    this.pref = (typeof pref != 'undefined' ? pref : false);
    this.type = type || null;
    this.formatted = formatted || null;
    this.streetAddress = streetAddress || null;
    this.locality = locality || null;
    this.region = region || null;
    this.postalCode = postalCode || null;
    this.country = country || null;
};

module.exports = ContactAddress;
});

// file: lib/common/extension/ContactError.js
define("xFace/extension/ContactError", function(require, exports, module) {
var ContactError = function(err) {
    this.code = (typeof err != 'undefined' ? err : null);
};

/**
 * 错误码
 */
ContactError.UNKNOWN_ERROR = 0;
ContactError.INVALID_ARGUMENT_ERROR = 1;
ContactError.TIMEOUT_ERROR = 2;
ContactError.PENDING_OPERATION_ERROR = 3;
ContactError.IO_ERROR = 4;
ContactError.NOT_SUPPORTED_ERROR = 5;
ContactError.PERMISSION_DENIED_ERROR = 20;

module.exports = ContactError;
});

// file: lib/common/extension/ContactField.js
define("xFace/extension/ContactField", function(require, exports, module) {
var ContactField = function(type, value, pref) {
    this.id = null;
    this.type = (type && type.toString()) || null;
    this.value = (value && value.toString()) || null;
    this.pref = (typeof pref != 'undefined' ? pref : false);
};

module.exports = ContactField;
});

// file: lib/common/extension/ContactFindOptions.js
define("xFace/extension/ContactFindOptions", function(require, exports, module) {
var ContactAccountType = require("xFace/extension/ContactAccountType");

/**
 * ContactFindOptions.
 * @constructor
 * @param filter 用于指定查询时的 where 子句，为空时，返回所有联系人的所有属性
 * @param multiple 用于指定是否返回满足条件的多个联系人信息，为 true 时返回多个，false 时返回一个
 * @param accountType 用于指定联系人账户类型（如：All, Phone, SIM），目前仅Android系统支持
 */
var ContactFindOptions = function(filter, multiple, accountType) {
    this.filter = filter || '';
    this.multiple = (typeof multiple != 'undefined' ? multiple : false);
    this.accountType = accountType || ContactAccountType.All;
};

module.exports = ContactFindOptions;
});

// file: lib/common/extension/ContactName.js
define("xFace/extension/ContactName", function(require, exports, module) {
var ContactName = function(formatted, familyName, givenName, middle, prefix, suffix) {
    this.formatted = formatted || null;
    this.familyName = familyName || null;
    this.givenName = givenName || null;
    this.middleName = middle || null;
    this.honorificPrefix = prefix || null;
    this.honorificSuffix = suffix || null;
};

module.exports = ContactName;
});

// file: lib/common/extension/ContactOrganization.js
define("xFace/extension/ContactOrganization", function(require, exports, module) {
var ContactOrganization = function(pref, type, name, dept, title) {
    this.id = null;
    this.pref = (typeof pref != 'undefined' ? pref : false);
    this.type = type || null;
    this.name = name || null;
    this.department = dept || null;
    this.title = title || null;
};

module.exports = ContactOrganization;
});

// file: lib/common/extension/DirectoryEntry.js
define("xFace/extension/DirectoryEntry", function(require, exports, module) {
var utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    Entry = require('xFace/extension/Entry');

/**
 * 构造函数
 */
var DirectoryEntry = function(name, fullPath) {
     DirectoryEntry.__super__.constructor.apply(this, [false, true, name, fullPath]);
};

utils.extend(DirectoryEntry, Entry);

DirectoryEntry.prototype.createReader = function() {
    return new DirectoryReader(this.fullPath);
};

/**
 * 创建或者查找目录
 * @param path      目录的相对或者绝对路径
 * @param options   目录不存在时是否创建
 * @param successCallback 成功的回调函数
 * @param errorCallback   失败的回调函数
 */
DirectoryEntry.prototype.getDirectory = function(path, options, successCallback, errorCallback) {
    var win = typeof successCallback !== 'function' ? null : function(result) {
        var entry = new DirectoryEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getDirectory", [this.fullPath, path, options]);
};

/**
 * 删除一个目录以及该目录下的所有文件和子目录
 */
DirectoryEntry.prototype.removeRecursively = function(successCallback, errorCallback) {
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(successCallback, fail, null, "File", "removeRecursively", [this.fullPath]);
};

/**
 * 创建或者查找一个文件
 */
DirectoryEntry.prototype.getFile = function(path, options, successCallback, errorCallback) {
    var win = typeof successCallback !== 'function' ? null : function(result) {
        var FileEntry = require('xFace/extension/FileEntry');
        var entry = new FileEntry(result.name, result.fullPath);
        successCallback(entry);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getFile", [this.fullPath, path, options]);
};

module.exports = DirectoryEntry;
});

// file: lib/common/extension/DirectoryReader.js
define("xFace/extension/DirectoryReader", function(require, exports, module) {
var exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry');

function DirectoryReader(path) {
    this.path = path || null;
}

/**
 * 返回一个目录中的所有文件实体
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
var exec = require('xFace/exec'),
    Metadata = require('xFace/extension/Metadata'),
    FileError = require('xFace/extension/FileError');

/**
 * 文件（夹）实体对象
 * @param isFile       判断是否为文件（true代表文件）
 * @param isDirectory  判断是否为文件夹（true代表文件夹）
 * @param name         文件（夹）的名字
 * @param fullPath     文件（夹）的绝对路径
 */
function Entry(isFile, isDirectory, name, fullPath, fileSystem) {
    this.isFile = (typeof isFile != 'undefined'?isFile:false);
    this.isDirectory = (typeof isDirectory != 'undefined'?isDirectory:false);
    this.name = name || '';
    this.fullPath = fullPath || '';
    this.filesystem = fileSystem || null;
}

/**
 * 移动文件（夹）
 * @param parent  将要移动到的父目录对象
 * @param newName 移动文件后的新名字（默认为当前的名字）
 * @param successCallback 成功的回调函数
 * @param errorCallback   失败的回调函数
 */
Entry.prototype.moveTo = function(parent, newName, successCallback, errorCallback) {
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
 * 复制文件（夹）
 * @param parent  将要复制到的父目录对象
 * @param newName 复制文件后的新名字（默认为当前的名字）
 * @param successCallback 成功的回调函数
 * @param errorCallback   失败的回调函数
 */
Entry.prototype.copyTo = function(parent, newName, successCallback, errorCallback) {
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
 * 删除一个文件（夹）（不能删除一个不为空的文件夹，也不能删除文件根目录）
 */
Entry.prototype.remove = function(successCallback, errorCallback) {
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(successCallback, fail, null, "File", "remove", [this.fullPath]);
};

/**
 * 返回一个可以标识该实体的URL
 */
Entry.prototype.toURL = function() {
    // fullPath attribute contains the full URL
    return "file://" + this.fullPath;
};

/**
 * 返回一个可以标识该实体的URI
 */
Entry.prototype.toURI = function(mimeType) {
    console.log("DEPRECATED: Update your code to use 'toURL'");
    return "file://" + this.fullPath;
};

/**
 * 查找父目录
 */
Entry.prototype.getParent = function(successCallback, errorCallback) {
    var win = typeof successCallback !== 'function' ? null : function(result) {
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
 * 查找文件的元数据
 */
Entry.prototype.getMetadata = function(successCallback, errorCallback) {
  var success = typeof successCallback !== 'function' ? null : function(lastModified) {
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

var File = function(name, fullPath, type, lastModifiedDate, size){
    this.name = name || '';
    this.fullPath = fullPath || null;
    this.type = type || null;
    this.lastModifiedDate = lastModifiedDate || null;
    this.size = size || 0;
};

module.exports = File;
});

// file: lib/common/extension/FileEntry.js
define("xFace/extension/FileEntry", function(require, exports, module) {
var utils = require('xFace/utils'),
    exec = require('xFace/exec');
    Entry = require('xFace/extension/Entry'),
    File = require('xFace/extension/File'),
    FileWriter = require('xFace/extension/FileWriter'),
    FileError = require('xFace/extension/FileError');

/**
 * An interface representing a file on the file system.
 */
var FileEntry = function(name, fullPath) {
     FileEntry.__super__.constructor.apply(this, [true, false, name, fullPath]);
};

utils.extend(FileEntry, Entry);

FileEntry.prototype.createWriter = function(successCallback, errorCallback) {
    this.file(function(filePointer) {
        var writer = new FileWriter(filePointer);

        if (writer.fileName === null || writer.fileName === "") {
            if (typeof errorCallback === "function") {
                errorCallback(new FileError(FileError.INVALID_STATE_ERR));
            }
        } else {
            if (typeof successCallback === "function") {
                successCallback(writer);
            }
        }
    }, errorCallback);
};

/**
 * Returns a File that represents the current state of the file that this FileEntry represents.
 *
 * @param {Function} successCallback is called with the new File object
 * @param {Function} errorCallback is called with a FileError
 */
FileEntry.prototype.file = function(successCallback, errorCallback) {
    var win = typeof successCallback !== 'function' ? null : function(f) {
        var file = new File(f.name, f.fullPath, f.type, f.lastModifiedDate, f.size);
        successCallback(file);
    };
    var fail = typeof errorCallback !== 'function' ? null : function(code) {
        errorCallback(new FileError(code));
    };
    exec(win, fail, null, "File", "getFileMetadata", [this.fullPath]);
};

module.exports = FileEntry;
});

// file: lib/common/extension/FileError.js
define("xFace/extension/FileError", function(require, exports, module) {
function FileError(error) {
  this.code = error || null;
}

// File error codes
// Found in DOMException
FileError.NOT_FOUND_ERR = 1;
FileError.SECURITY_ERR = 2;
FileError.ABORT_ERR = 3;

// Added by File API specification
FileError.NOT_READABLE_ERR = 4;
FileError.ENCODING_ERR = 5;
FileError.NO_MODIFICATION_ALLOWED_ERR = 6;
FileError.INVALID_STATE_ERR = 7;
FileError.SYNTAX_ERR = 8;
FileError.INVALID_MODIFICATION_ERR = 9;
FileError.QUOTA_EXCEEDED_ERR = 10;
FileError.TYPE_MISMATCH_ERR = 11;
FileError.PATH_EXISTS_ERR = 12;

module.exports = FileError;
});

// file: lib/common/extension/FileReader.js
define("xFace/extension/FileReader", function(require, exports, module) {
var exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

var FileReader = function() {
    this.fileName = "";

    this.readyState = 0;

    this.result = null;

    this.error = null;

    // 事件句柄
    this.onloadstart = null;    // When the read starts.
    this.onprogress = null;     // While reading (and decoding) file or fileBlob data, and reporting partial file data (progess.loaded/progress.total)
    this.onload = null;         // When the read has successfully completed.
    this.onerror = null;        // When the read has failed (see errors).
    this.onloadend = null;      // When the request has completed (either in success or failure).
    this.onabort = null;        // When the read has been aborted. For instance, by invoking the abort() method.
};

// States
FileReader.EMPTY = 0;
FileReader.LOADING = 1;
FileReader.DONE = 2;

/**
 * 取消读取文件
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
 * 读取text内容
 * @param file          要读取的文件对象
 * @param encoding      编码格式 (see http://www.iana.org/assignments/character-sets)
 */
FileReader.prototype.readAsText = function(file, encoding) {
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
        null, "File", "readAsText", [this.fileName, enc]);
};

/**
 * 读取文件并返回base64 encoded data url的数据
 * 返回数据的格式:
 *      data:[<mediatype>][;base64],<data>
 *
 * @param file       要读取的文件对象
 */
FileReader.prototype.readAsDataURL = function(file) {
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
        null, "File", "readAsDataURL", [this.fileName]);
};

/**
 * 读取文件并返回二进制数据
 * @param file          要读取的文件对象
 */
FileReader.prototype.readAsBinaryString = function(file) {
    // TODO:目前不支持
    console.log('method "readAsBinaryString" is not supported at this time.');
};

/**
 * 读取文件并返回二进制数据
 * @param file          要读取的文件对象
 */
FileReader.prototype.readAsArrayBuffer = function(file) {
    // TODO:目前不支持
    console.log('This method is not supported at this time.');
};

module.exports = FileReader;
});

// file: lib/common/extension/FileSystem.js
define("xFace/extension/FileSystem", function(require, exports, module) {
var DirectoryEntry = require('xFace/extension/DirectoryEntry');

/**
 * 构造函数
 * @param name 标识文件系统的名称 (readonly)
 * @param root 文件系统的根目录 (readonly)
 */
var FileSystem = function(name, root) {
    this.name = name || null;
    if (root) {
        this.root = new DirectoryEntry(root.name, root.fullPath);
    }
};

module.exports = FileSystem;
});

// file: lib/ios/extension/FileTransfer.js
define("xFace/extension/FileTransfer", function(require, exports, module) {
var exec = require('xFace/exec'),
    FileTransferError = require('xFace/extension/FileTransferError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

function newProgressEvent(result) {
    var pe = new ProgressEvent();
    pe.lengthComputable = result.lengthComputable;
    pe.loaded = result.loaded;
    pe.total = result.total;
    return pe;
}

var idCounter = 0;
/**
 * @构造函数
 */
var FileTransfer = function() {
    this._id = ++idCounter;
    this.onprogress = null; // optional callback
};

/**
 * 下载一个文件到指定的路径
 * @param source {String}    文件所在的服务器URL
 * @param target {String}    将要下载到的指定路径
 * @param successCallback    成功回调函数
 * @param errorCallback      失败回调函数
 */
FileTransfer.prototype.download = function(source, target, successCallback, errorCallback) {
    var self = this;
    var win = function(result) {
        if (typeof result.lengthComputable != "undefined") {
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
            successCallback(entry);
        }
    };
    exec(win, errorCallback, null, 'FileTransfer', 'download', [source, target, this._id]);
};

/**
 * 文件上传
 * @param filePath {String}           要上传的本地文件路径
 * @param server {String}             接收文件的服务器地址
 * @param successCallback (Function}  成功回调函数
 * @param errorCallback {Function}    失败回调函数
 * @param options {FileUploadOptions}
 * @param trustAllHosts {Boolean} Optional trust all hosts (e.g. for self-signed certs), 默认为false
*/
FileTransfer.prototype.upload = function(filePath, server, successCallback, errorCallback, options, trustAllHosts) {
    // 参数检查
    if (!filePath || !server) throw new Error("FileTransfer.upload requires filePath and server URL parameters at the minimum.");
    // 检查options
    var fileKey = null;
    var fileName = null;
    var mimeType = null;
    var params = null;
    var chunkedMode = true;
    if (options) {
        fileKey = options.fileKey;
        fileName = options.fileName;
        mimeType = options.mimeType;
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
        if (typeof result.lengthComputable != "undefined") {
            if (self.onprogress) {
                return self.onprogress(newProgressEvent(result));
            }
        } else {
             return successCallback(result);
        }
    };
    exec(win, fail, null, 'FileTransfer', 'upload', [filePath, server, fileKey, fileName, mimeType, params, trustAllHosts, chunkedMode, this._id]);
};

/**
 * Aborts the ongoing file transfer on this object
 * @param successCallback {Function}  Callback to be invoked upon success
 * @param errorCallback {Function}    Callback to be invoked upon error
 */
FileTransfer.prototype.abort = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, null, 'FileTransfer', 'abort', [this._id]);
};

module.exports = FileTransfer;
});

// file: lib/common/extension/FileTransferError.js
define("xFace/extension/FileTransferError", function(require, exports, module) {
var FileTransferError = function(code, source, target, status) {
    this.code = code || null;
    this.source = source || null;
    this.target = target || null;
    this.http_status = status || null;
};

FileTransferError.FILE_NOT_FOUND_ERR = 1;
FileTransferError.INVALID_URL_ERR = 2;
FileTransferError.CONNECTION_ERR = 3;
FileTransferError.ABORT_ERR = 4;

module.exports = FileTransferError;

});

// file: lib/common/extension/FileUploadOptions.js
define("xFace/extension/FileUploadOptions", function(require, exports, module) {
var FileUploadOptions = function(fileKey, fileName, mimeType, params) {
    this.fileKey = fileKey || null;
    this.fileName = fileName || null;
    this.mimeType = mimeType || null;
    this.params = params || null;
};

module.exports = FileUploadOptions;
});

// file: lib/common/extension/FileUploadResult.js
define("xFace/extension/FileUploadResult", function(require, exports, module) {
var FileUploadResult = function() {
    this.bytesSent = 0;
    this.responseCode = null;
    this.response = null;
};

module.exports = FileUploadResult;
});

// file: lib/common/extension/FileWriter.js
define("xFace/extension/FileWriter", function(require, exports, module) {
var exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

/**
 * 构造函数
 */
var FileWriter = function(file) {
    this.fileName = "";
    this.length = 0;
    if (file) {
        this.fileName = file.fullPath || file;
        this.length = file.size || 0;
    }
    // 默认从开始位置写文件
    this.position = 0;

    this.readyState = 0;

    this.result = null;

    this.error = null;

    // 事件句柄
    this.onwritestart = null;   // When writing starts
    this.onprogress = null;     // While writing the file, and reporting partial file data
    this.onwrite = null;        // When the write has successfully completed.
    this.onwriteend = null;     // When the request has completed (either in success or failure).
    this.onabort = null;        // When the write has been aborted. For instance, by invoking the abort() method.
    this.onerror = null;        // When the write has failed (see errors).
};

// 状态
FileWriter.INIT = 0;
FileWriter.WRITING = 1;
FileWriter.DONE = 2;

/**
 * 取消写文件
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
 * 写文件
 *
 * @param text 要写入的内容
 */
FileWriter.prototype.write = function(text) {
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
 * 从当前位置向后移动文件指针
 * 如果offset为负值，则从后往前移动，如果offset大于文件的总大小，文件指针则在文件的末尾
 * @param offset 文件指针要移动到的位置.
 */
FileWriter.prototype.seek = function(offset) {
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
 * 清除文件
 * @param size 清除后剩下的文件大小
 */
FileWriter.prototype.truncate = function(size) {
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
function Flags(create, exclusive) {
    this.create = create || false;
    this.exclusive = exclusive || false;
}

module.exports = Flags;
});

// file: lib/common/extension/LocalFileSystem.js
define("xFace/extension/LocalFileSystem", function(require, exports, module) {
var LocalFileSystem = function() {

};

LocalFileSystem.TEMPORARY = 0;  //临时文件
LocalFileSystem.PERSISTENT = 1; //持久文件

module.exports = LocalFileSystem;
});

// file: lib/common/extension/Media.js
define("xFace/extension/Media", function(require, exports, module) {
var utils = require('xFace/utils'),
    exec = require('xFace/exec');

var mediaObjects = {};

/**
 * 此对象提供获得设备 Media 的能力.
 *
 * @constructor
 * @param src                   文件的名称或者 url
 * @param successCallback       成功回调
 * @param errorCallback         异常回调（可选）
 * @param statusCallback        状态变化回调（可选）
 */
var Media = function(src, successCallback, errorCallback, statusCallback) {

    if (successCallback && (typeof successCallback !== "function")) {
        console.log("Media Error: successCallback is not a function");
        return;
    }

    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("Media Error: errorCallback is not a function");
        return;
    }

    if (statusCallback && (typeof statusCallback !== "function")) {
        console.log("Media Error: statusCallback is not a function");
        return;
    }

    this.id = utils.createUUID();
    mediaObjects[this.id] = this;
    this.src = src;
    this.successCallback = successCallback;
    this.errorCallback = errorCallback;
    this.statusCallback = statusCallback;
    this._duration = -1;
    this._position = -1;
};

// Media messages
Media.MEDIA_STATE = 1;
Media.MEDIA_DURATION = 2;
Media.MEDIA_POSITION = 3;
Media.MEDIA_ERROR = 4;

// Media states
Media.MEDIA_NONE = 0;
Media.MEDIA_STARTING = 1;
Media.MEDIA_RUNNING = 2;
Media.MEDIA_PAUSED = 3;
Media.MEDIA_STOPPED = 4;
Media.MEDIA_MSG = ["None", "Starting", "Running", "Paused", "Stopped"];

// "static" 函数返回已存在的对象.
Media.get = function(id) {
    return mediaObjects[id];
};

/**
 * Start 或者 resume 正在播放的音频文件.
 *
 * @param options       可选参数（Android无效）
 */
Media.prototype.play = function(options) {
    exec(null, null, null, "Audio", "play", [this.id, this.src, options]);
};

/**
 * 停止正在播放的 audio.
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
 * Seek 或者 jump 到正在播放的 audio 的一个新位置.
 */
Media.prototype.seekTo = function(milliseconds) {
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
 * 暂停正在播放的 audio.
 */
Media.prototype.pause = function() {
    exec(null, this.errorCallback, null, "Audio", "pause", [this.id]);
};

/**
 * 获取当前 audio 的 duration.
 * 此 duration 仅对处于下列播放状态的 audio 有效：playing, paused 或者 stopped.
 *
 * @return      duration已知时则返回实际值，否则返回 -1.
 */
Media.prototype.getDuration = function() {
    return this._duration;
};

/**
 * 获取 audio 当前的播放位置.
 *
 * @param success    成功回调
 * @param fail       失败回调
 */
Media.prototype.getCurrentPosition = function(success, fail) {
    var me = this;
    exec(
        function(p) {
            me._position = p;
            success(p);
        },
        fail,
        null,
        "Audio", "getCurrentPosition", [this.id]
    );
};

/**
 * 设置 audio 的播放音量.
 *
 * @param value      音量值(rang = 0.0 to 1.0)
 */
Media.prototype.setVolume = function(value) {
    exec(null,this.errorCallback,null,"Audio", "setVolume", [this.id,value]);
};

/**
 * 释放资源.
 */
Media.prototype.release = function() {
    exec(null, this.errorCallback, null, "Audio", "release", [this.id]);
};

/**
 * 开始录制 audio.
 */
Media.prototype.startRecord = function() {
    exec(this.successCallback, this.errorCallback, null, "Audio", "startRecording", [this.id, this.src]);
};

/**
 * 停止 audio.
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
var MediaError = function(code, msg) {
    this.code = (code !== undefined ? code : null);
    this.message = msg || "";
};

MediaError.MEDIA_ERR_NONE_ACTIVE    = 0;
MediaError.MEDIA_ERR_ABORTED        = 1;
MediaError.MEDIA_ERR_NETWORK        = 2;
MediaError.MEDIA_ERR_DECODE         = 3;
MediaError.MEDIA_ERR_NONE_SUPPORTED = 4;

module.exports = MediaError;
});

// file: lib/common/extension/MediaFile.js
define("xFace/extension/MediaFile", function(require, exports, module) {
var utils = require('xFace/utils'),
    exec = require('xFace/exec'),
    File = require('xFace/extension/File'),
    CaptureError = require('xFace/extension/CaptureError');
/**
 * 代表一个单独的多媒体文件.
 *
 * name {DOMString} 文件名, 不包含路径信息
 * fullPath {DOMString} 文件的全路径，包括文件名
 * type {DOMString} mime type
 * lastModifiedDate {Date} 最后修改日期
 * size {Number} 文件大小，单位是比特
 */
var MediaFile = function(name, fullPath, type, lastModifiedDate, size){
    MediaFile.__super__.constructor.apply(this, arguments);
};

utils.extend(MediaFile, File);

/**
 * 请求一个指定路径和类型的文件的格式信息
 *
 * @param {Function} successCallback
 * @param {Function} errorCallback
 */
MediaFile.prototype.getFormatData = function(successCallback, errorCallback) {
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
var MediaFileData = function(codecs, bitrate, height, width, duration){
    this.codecs = codecs || null;
    this.bitrate = bitrate || 0;
    this.height = height || 0;
    this.width = width || 0;
    this.duration = duration || 0;
};

module.exports = MediaFileData;
});

// file: lib/common/extension/Message.js
define("xFace/extension/Message", function(require, exports, module) {
var Message = function(messageId, subject, body, destinationAddresses, messageType, date, isRead) {
    this.messageId = messageId || null;
    this.subject = subject || null;
    this.body = body || null;
    this.destinationAddresses = destinationAddresses || null;
    this.messageType = messageType || null;
    this.date = date || null;
    this.isRead = isRead || null;
};

module.exports = Message;
});

// file: lib/common/extension/MessageTypes.js
define("xFace/extension/MessageTypes", function(require, exports, module) {
var MessageTypes = function() {
};

MessageTypes.EmailMessage = "Email";
MessageTypes.MMSMessage = "MMS";
MessageTypes.SMSMessage = "SMS";

module.exports = MessageTypes;
});

// file: lib/common/extension/Messaging.js
define("xFace/extension/Messaging", function(require, exports, module) {
var exec = require('xFace/exec'),
    Message = require('xFace/extension/Message');

var Messaging = function() {
};

/**
 * 创建信息.
 * @param messageType     信息类型（如MMS,SMS,Email）
 * @param successCallback 成功回调函数
 * @param errorCallback   失败回调函数
 */
Messaging.prototype.createMessage = function(messageType, successCallback, errorCallback) {
    //TODO:根据messageType创建不同类型的信息，目前只处理了短消息
    var MessageTypes = require('xFace/extension/MessageTypes');
    if(typeof messageType  != "string" ||
      (messageType != MessageTypes.EmailMessage&&
       messageType != MessageTypes.MMSMessage&&
       messageType != MessageTypes.SMSMessage)){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    if(successCallback && typeof successCallback == "function") {
        var result = new Message();
        result.messageType = messageType;
        successCallback(result);
    }
}

/**
 * 发送信息.
 * 目前支持发送短信和Email
 * @param message         要发送的信息对象
 * @param successCallback 成功回调函数
 * @param errorCallback   失败回调函数
 */
Messaging.prototype.sendMessage = function(message, successCallback, errorCallback){
    exec(successCallback, errorCallback, null, "Messaging", "sendMessage", [message.messageType, message.destinationAddresses, message.body, message.subject]);
};

module.exports = new Messaging();
});

// file: lib/common/extension/Metadata.js
define("xFace/extension/Metadata", function(require, exports, module) {
var Metadata = function(time) {
    this.modificationTime = (typeof time != 'undefined'?new Date(time):null);
};

module.exports = Metadata;
});

// file: lib/common/extension/Notification.js
define("xFace/extension/Notification", function(require, exports, module) {
var exec = require('xFace/exec');
    var notification = function() {};

/**
 * Open a native alert dialog, with a customizable title and button text.
 * @param {String} message              Message to print in the body of the alert
 * @param {Function} alertCallback   The callback that is called when user clicks on a button.
 * @param {String} title                Title of the alert dialog (default: Alert)
 * @param {String} buttonLabel          Label of the close button (default: OK)
 */
notification.prototype.alert = function(message, alertCallback, title, buttonLabel){
    var _title = (title || "Alert");
    var _buttonLabel = (buttonLabel || "OK");
    exec(alertCallback, null, null, "Notification", "alert", [message, _title, _buttonLabel]);
};

/**
 * Open a native confirm dialog, with a customizable title and button text.
 * The result that the user selects is returned to the result callback.
 *
 * @param {String} message              Message to print in the body of the alert
 * @param {Function} alertCallback     The callback that is called when user clicks on a button.
 * @param {String} title                Title of the alert dialog (default: Confirm)
 * @param {String} buttonLabels         Comma separated list of the labels of the buttons (default: 'OK,Cancel')
 */
notification.prototype.confirm = function(message, alertCallback, title, buttonLabels){
    var _title = (title || "Confirm");
    var _buttonLabels = (buttonLabels || "OK,Cancel");
    exec(alertCallback, null, null, "Notification", "confirm", [message, _title, _buttonLabels]);
};

/**
 * 使设备震动
 *
 * @param {Integer} mills       震动的毫秒数.
 */
notification.prototype.vibrate = function(mills) {
    exec(null, null, null, "Notification", "vibrate", [mills]);
};

module.exports = new notification();

});

// file: lib/common/extension/ProgressEvent.js
define("xFace/extension/ProgressEvent", function(require, exports, module) {
var ProgressEvent = (function() {
    return function ProgressEvent(type, dict) {
        this.type = type;
        this.bubbles = false;
        this.cancelBubble = false;
        this.cancelable = false;
        this.lengthComputable = false;
        this.loaded = dict && dict.loaded ? dict.loaded : 0;
        this.total = dict && dict.total ? dict.total : 0;
        this.target = dict && dict.target ? dict.target : null;
    };
})();

module.exports = ProgressEvent;
});

// file: lib/common/extension/PushNotification.js
define("xFace/extension/PushNotification", function(require, exports, module) {
var exec = require('xFace/exec');

/**
 * 定义PushNotification,属性deviceToken在平台的push中唯一标识一个设备
 * @constructor
 */
var PushNotification = function() {
    this.onReceived = null;
};

// 引擎方法，不对js提供
PushNotification.prototype.fire = function(pushString) {
    if (this.onReceived) {
        this.onReceived(pushString);
    }
};

/**
 *  设置push数据到达时候的监听器
 * @param listener(pushString) 回调参数为push的json数据
 */
PushNotification.prototype.registerOnReceivedListener = function(listener) {
    if (typeof listener !== "function") {
       console.log("PushNotification Error: registerOnReceivedListener is not a function");
       return;
    }
    this.onReceived = listener;
    exec(null, null, null, "PushNotification", "registerOnReceivedListener", []);
};

/**
 *  获取push deviceToken
 * @param successCallback(deviceToekn) 成功通知回调(必须)
 *          回调参数为deviceToken
 * @param errorCallback 失败通知回调(可选)
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
var exec = require('xFace/exec');
var Security = function() {};

/**
 * 根据传入的密钥对明文加密.
 *
 * @param key {String}        密钥
 * @param plainText {String}  明文
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Security.prototype.encrypt = function(key, plainText, successCallback, errorCallback){
    if(typeof key  != "string" || key.length < 8 || typeof plainText  != "string"){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "encrypt", [key, plainText]);
};

 /**
 *加密文件.
 *
 * @param key {String}        密钥
 * @param sourceFilePath {String}  加密文件路径
 * @param targetFilePath {String}  加密后文件路径
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Security.prototype.encryptFile = function(key, sourceFilePath, targetFilePath, successCallback, errorCallback){
    if(typeof key  != 'string' || key.length < 8 || typeof sourceFilePath != 'string' || typeof targetFilePath != 'string'){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "encryptFile", [key, sourceFilePath,targetFilePath]);
};

/**
 * 根据传入的密钥对密文解密.
 *
 * @param key {String}            密钥
 * @param encryptedText {String}  密文
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Security.prototype.decrypt = function(key, encryptedText, successCallback, errorCallback){
    if(typeof key  != "string" || key.length < 8 || typeof encryptedText  != "string"){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "decrypt", [key, encryptedText]);
};

/**
 * 解密文件.
 *
 * @param key {String}        密钥
 * @param sourceFilePath {String}  要解密得文件路径
 * @param targetFilePath {String}  解密得到的文件的路径
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Security.prototype.decryptFile = function(key, sourceFilePath, targetFilePath, successCallback, errorCallback){
    if(typeof key  != 'string' || key.length < 8 || typeof sourceFilePath != 'string' || typeof targetFilePath != 'string') {
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback();
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "decryptFile", [key, sourceFilePath,targetFilePath]);
};

module.exports = new Security();
});

// file: lib/common/extension/Setting.js
define("xFace/extension/Setting", function(require, exports, module) {
var xFace = require('xFace');
var utils = require("xFace/utils");
var gstorage = require('xFace/localStorage');

var Setting  = function() {};

var m_localStorage_setItem = gstorage.getOriginalLocalStorage().setItem;
var m_localStorage_getItem = gstorage.getOriginalLocalStorage().getItem;
var m_localStorage_removeItem = gstorage.getOriginalLocalStorage().removeItem;;

var keyPrefix = "_";
var keySeparator = ",";

var id = "settingPreference";

function getNewKey(id, key){
    var newKey = id + keyPrefix + key;
    return newKey;
}

/**
 * 存储一个setting键值对
 * @param {String} key         键值对的键值
 * @param {String} value       key所对应的数据
 */
Setting.prototype.setPreference = function(key, value){
    var newKey = getNewKey(id, key);
    m_localStorage_setItem.call(localStorage, newKey, value);
    //更新以id为键值的数据，其中存储的是所有属于Setting的key值
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null == keyList || "" == keyList){
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
}

/**
 * 获取一个key作为键值的setting数据
 * @param {String} key         键值对的键值
 * @return String         返回指定键所对应的记录
 */
Setting.prototype.getPreference = function(key){
    var newKey = getNewKey(id, key);
    var value = m_localStorage_getItem.call(localStorage, newKey);
    return value;
}

/**
 * 删除key作为键值的setting数据
 * @param {String} key         键值对的键值
 */
Setting.prototype.removePreference = function(key){
    var newKey = getNewKey(id, key);
    m_localStorage_removeItem.call(localStorage, newKey);
    //更新保存的keyList，删除相应的key
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null != keyList){
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
}

/**
 * 获得处于index指定的位置的键值
 * @param {String} index 要返回的key所在的位置
 * @return {String}  返回指定位置的键的名称
 */
Setting.prototype.key = function(index){
    var nonNegative = /^\d+(\.\d+)?$/;
    if(nonNegative.test(index)){
        var realIndex = Math.floor(index);
        var keyList = m_localStorage_getItem.call(localStorage, id);
        if((null != keyList) && ("" != keyList)){
            var keyArray = keyList.split(keySeparator);
            if(realIndex < keyArray.length){
                var key = keyArray[realIndex];
                return key;
            }
        }
    }
    return null;
}

/**
 *删除setting存储的所有键值对
 */
Setting.prototype.clear = function(){
    //删除setting的数据，keyList保存了所有属于Setting的key值，根据它的信息
    //可以删除全部的数据
    var keyList = m_localStorage_getItem.call(localStorage, id);
    if(null != keyList){
        var keyArray = keyList.split(keySeparator);
        for ( var index = 0; index < keyArray.length; index++){
            var key = keyArray[index];
            var newKey = getNewKey(id, key);
            m_localStorage_removeItem.call(localStorage, newKey);
        }
    }
    m_localStorage_removeItem.call(localStorage, id);
}

module.exports = new Setting();
});

// file: lib/common/extension/Telephony.js
define("xFace/extension/Telephony", function(require, exports, module) {
var exec = require('xFace/exec');

/**
 * Telephony的构造函数
 */
var Telephony = function(){
};

/**
 * 拨打电话
 *
 * @param phoneNumber 电话号码
 * @param successCallback 成功的回调函数
 * @param errorCallback 失败回调函数
 */
Telephony.prototype.initiateVoiceCall = function(phoneNumber,successCallback,errorCallback){
    exec(successCallback, errorCallback, null, "Telephony", "initiateVoiceCall", [phoneNumber]);
};
module.exports = new Telephony();

});

// file: lib/common/extension/Zip.js
define("xFace/extension/Zip", function(require, exports, module) {
var exec = require('xFace/exec');
var ZipError = require('xFace/extension/ZipError');
var ZipOptions = require('xFace/extension/ZipOptions');
var Zip = function() {};

/**
 * 将指定路径的文件或文件夹压缩成zip文件
 *
 * @param filePath {String}        待压缩的文件路径
 * @param dstFilePath {String}     压缩文件到指定路径（如果为空的话，就压缩到当前目录）
 * @param options {String}         压缩时采用的密码（可选，目前仅ios支持）
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Zip.prototype.zip = function(filePath, dstFilePath, successCallback, errorCallback,options){
    if( typeof filePath != 'string' || typeof dstFilePath != 'string' ) {
        if( errorCallback && (typeof errorCallback == 'function') ) {
            errorCallback.call(this);
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Zip", "zip", [filePath,dstFilePath,options]);
};

/**
 * 将指定路径的zip文件解压.
 *
 * @param zipFilePath {String}            待解压的指定路径的zip文件
 * @param dstFolderPath {String}            解压到指定文件夹下（如果为空的话，就解压到当前app workspace目录）
 * @param options {String}                解压文件时采用的密码 (可选，目前仅ios支持)
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Zip.prototype.unzip = function(zipFilePath, dstFolderPath, successCallback, errorCallback,options){
    if( typeof zipFilePath != 'string' || typeof dstFolderPath != 'string' ) {
        if( errorCallback && (typeof errorCallback == 'function') ) {
            errorCallback.call(this);
        }
        return;
    }
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
 * 将多个指定路径的文件或文件夹压缩成zip文件
 *
 * @param srcEntries {Array of String}        待压缩的文件路径
 * @param dstFilePath {String}     压缩文件到指定路径（如果为空的话，就压缩到当前目录）
 * @param options {String}                解压文件时采用的密码 (可选)
 * @param successCallback {Function}
 * @param errorCallback {Function}
 */
Zip.prototype.zipFiles = function(srcEntries, dstFilePath, successCallback, failCallback, options){
    if( !(srcEntries instanceof Array) || typeof dstFilePath != 'string' ) {
        if( errorCallback && (typeof errorCallback == 'function') ) {
            errorCallback.call(this);
        }
        return;
    }
    exec(successCallback, failCallback, null, "Zip", "zipFiles", [srcEntries, dstFilePath, options]);
};

module.exports = new Zip();

});

// file: lib/common/extension/ZipError.js
define("xFace/extension/ZipError", function(require, exports, module) {
var ZipError = function(c) {
    this.code = c || null;
};

// 文件不存在
ZipError.FILE_NOT_EXIST = 1;
// 压缩文件出错.
ZipError.COMPRESS_FILE_ERROR = 2;
// 解压文件出错.
ZipError.UNZIP_FILE_ERROR = 3;
// 文件路径错误(文件不在workspace)
ZipError.FILE_PATH_ERROR = 4;
// 文件类型错误,不支持的文件类型
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
var utils = require('xFace/utils'),
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
        for (var i = 0, l = tempListeners.length; i < l; i++) {
            tempListeners[i].win(accel);
        }
    }, function(e) {
        var tempListeners = listeners.slice(0);
        for (var i = 0, l = tempListeners.length; i < l; i++) {
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
    return {win:win, fail:fail};
}

// Removes a win/fail listener pair from the listeners array
function removeListeners(l) {
    var idx = listeners.indexOf(l);
    if (idx > -1) {
        listeners.splice(idx, 1);
        if (listeners.length === 0) {
            stop();
        }
    }
}

var accelerometer = {
    /**
     * 获得当前的Acceleration
     *
     * @param successCallback 成功回调函数
     * @param errorCallback   失败回调函数(可选)
     * @param options         获得accelerometer的选项，比如超时时间(可选)
     */
    getCurrentAcceleration: function(successCallback, errorCallback, options) {
        // successCallback required
        if (typeof successCallback !== "function") {
            throw "getCurrentAcceleration must be called with at least a success callback function as first parameter.";
        }

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

        if (!running) {
            start();
        }
    },

    /**
     * 监视Acceleration
     *
     * @param successCallback 成功回调函数
     * @param errorCallback   失败回调函数(可选)
     * @param options         监视Acceleration的选项，比如frequency(可选参数)
     * @return String         返回唯一的watchId
     */
    watchAcceleration: function(successCallback, errorCallback, options) {
        // Default interval (10 sec)
        var frequency = (options && options.frequency && typeof options.frequency == 'number') ? options.frequency : 10000;

        // successCallback required
        if (typeof successCallback !== "function") {
            throw "watchAcceleration must be called with at least a success callback function as first parameter.";
        }

        // Keep reference to watch id, and report accel readings as often as defined in frequency
        var id = utils.createUUID();

        var p = createCallbackPair(function(){}, function(e) {
            errorCallback(e);
            removeListeners(p);
        });
        listeners.push(p);

        timers[id] = {
            timer:window.setInterval(function() {
                if (accel) {
                    successCallback(accel);
                }
            }, frequency),
            listeners:p
        };

        if (running) {
            // If we're already running then immediately invoke the success callback
            successCallback(accel);
        } else {
            start();
        }

        return id;
    },

    /**
     * 取消由id指定的监视器
     *
     * @param id   由watchAcceleration返回的watchId
     */
    clearWatch: function(id) {
        // Stop javascript timer & remove from timer list
        if (id && timers[id]) {
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
var exec = require('xFace/exec');
var xFace = require('xFace');
var localStorage = require('xFace/localStorage');
var AMS = function(){
};

/**
 * 安装应用
 * @param {String} packagePath              应用安装包所在相对路径（相对于当前应用的工作空间）
 * @param {Function} successCallback        成功时的回调函数(安装完成后，需要会将appid通过该回调函数返回)
 * @param {Function} errorCallback          失败时的回调函数
 * @param {Function} statusChangedCallback  安装过程的状态回调函数
 */
AMS.prototype.installApplication = function( packagePath, win, fail, statusChanged)
{
    exec(win, fail, statusChanged,"AMS", "installApplication",[packagePath]);
};

/**
 * 卸载应用
 * @param {String} appId                    用于标识待卸载应用的id
 * @param {Function} successCallback        成功时的回调函数
 * @param {Function} errorCallback          失败时的回调函数
 */
AMS.prototype.uninstallApplication = function( appId , win, fail)
{
    exec(
    //Success callback
    function(s)
    {
        //删除应用存储的数据
        localStorage.clearAppData(appId);
        win(s);
    }, fail, null, "AMS", "uninstallApplication",[appId]);
};

/**
 * 启动应用
 * @param {String} appId                    用于标识待启动应用的id
 */
AMS.prototype.startApplication = function(appId, win, fail)
{
    exec(win, fail, null, "AMS", "startApplication",[appId]);
};

/**
 * 关闭当前应用
 */
AMS.prototype.closeApplication = function()
{
    require('xFace/extension/privateModule').execCommand("xFace_close_application:", []);
};

/**
 * 获取已安装应用列表 返回值为json数组，包含应用的icon，名字，id
   形如:[{"appid":"...", "name":"...","icon":"..." ,"version":"..."},...]
 */
AMS.prototype.listInstalledApplications = function(win, fail)
{
    exec(win, fail, null, "AMS", "listInstalledApplications",[]);
};
/**
 * 获取默认应用可以安装的预设应用安装包列表
 * 列表中每一项为一个应用安装包的相对路径，可以直接安装/更新
 * @param {Function} successCallback     成功时的回调函数
 * @param {Function} errorCallback          失败时的回调函数
 */
AMS.prototype.listPresetAppPackages = function(successCallback, errorCallback)
{
    exec(successCallback, errorCallback, null, "AMS", "listPresetAppPackages", []);
};

/**
 * 重启默认应用
 * 场景描述：
 * 1) 用户首先自行判断默认应用是否需要更新，如果需要更新，则下载相应的更新包
 * 2) 默认应用更新包下载成功后，调用updateApplication进行更新
 * 3) 默认应用更新成功后，调用reset接口重启默认应用
 */
AMS.prototype.reset = function()
{
    exec(null, null, null, "AMS", "reset", []);
};


/**
 * 更新应用
 * @param {String} packagePath              应用更新包所在相对路径（相对于当前应用的工作空间）
 * @param {Function} successCallback        成功时的回调函数
 * @param {Function} errorCallback          失败时的回调函数
 * @param {Function} statusChangedCallback  更新过程的状态回调函数
 */
AMS.prototype.updateApplication = function( packagePath, win, fail, statusChanged)
{
    exec(win, fail, statusChanged,"AMS", "updateApplication",[packagePath]);

};

/**
 * 获取startApp的应用描述信息，如appid, version, icon等
 * @param {Function} successCallback     成功时的回调函数
 * @param {Function} errorCallback          失败时的回调函数
 */
AMS.prototype.getStartAppInfo = function(successCallback, errorCallback)
{
    exec(successCallback, errorCallback, null, "AMS", "getStartAppInfo", []);
};

module.exports = new AMS();
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

var Battery = function() {
    this._level = null;
    this._isPlugged = null;
    // Create new event handlers on the window (returns a channel instance)
    var subscriptionEvents = {
      onSubscribe:this.onSubscribe,
      onUnsubscribe:this.onUnsubscribe
    };
    this.channels = {
      batterystatus:xFace.addWindowEventHandler("batterystatus", subscriptionEvents),
      batterylow:xFace.addWindowEventHandler("batterylow", subscriptionEvents),
      batterycritical:xFace.addWindowEventHandler("batterycritical", subscriptionEvents)
    };
};

/**
 * Event handlers for when callbacks get registered for the battery.
 * Keep track of how many handlers we have so we can start and stop the native battery listener
 * appropriately (and hopefully save on battery life!).
 */
Battery.prototype.onSubscribe = function() {
  var me = battery;
  // If we just registered the first handler, make sure native listener is started.
  if (handlers() === 1) {
    exec(me._status, me._error, null, "Battery", "start", []);
  }
};

Battery.prototype.onUnsubscribe = function() {
  var me = battery;

  // If we just unregistered the last handler, make sure native listener is stopped.
  if (handlers() === 0) {
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
var exec = require('xFace/exec'),
    MediaFile = require('xFace/extension/MediaFile');

/**
 * 根据不同类型启动一个 capture.
 *
 * @param (DOMString} type  媒体文件格式类型，类型包括:captureImage、captureAudio和captureVideo
 * @param {Function} successCallback
 * @param {Function} errorCallback
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
 * 给设备的照相机和麦克风提供一个 Capture 接口.
 */
function Capture() {
    this.supportedAudioModes = [];
    this.supportedImageModes = [];
    this.supportedVideoModes = [];
}

/**
 * 启动照相机应用拍照.
 *
 * @param {Function} successCallback
 * @param {Function} errorCallback
 * @param {CaptureImageOptions} options
 */
Capture.prototype.captureImage = function(successCallback, errorCallback, options){
    captureMedia("captureImage", successCallback, errorCallback, options);
};

/**
 * 启动照相机应用录音.
 *
 * @param {Function} successCallback
 * @param {Function} errorCallback
 * @param {CaptureAudioOptions} options
 */
Capture.prototype.captureAudio = function(successCallback, errorCallback, options){
    captureMedia("captureAudio", successCallback, errorCallback, options);
};

/**
 * 启动照相机应用摄像.
 *
 * @param {Function} successCallback
 * @param {Function} errorCallback
 * @param {CaptureVideoOptions} options
 */
Capture.prototype.captureVideo = function(successCallback, errorCallback, options){
    captureMedia("captureVideo", successCallback, errorCallback, options);
};

module.exports = new Capture();
});

// file: lib/common/extension/compass.js
define("xFace/extension/compass", function(require, exports, module) {
var exec = require('xFace/exec'),
utils = require('xFace/utils'),
CompassHeading = require('xFace/extension/CompassHeading'),
CompassError = require('xFace/extension/CompassError'),
timers = {},
compass = {
    /**
     * 获取指南针当前的方向信息
     * @param successCallback 成功回调函数
     * @param errorCallback   失败回调函数
     * @param options         获得heading的选项（未使用）
     */
    getCurrentHeading:function(successCallback, errorCallback, options) {
        // successCallback required
        if (typeof successCallback !== "function") {
          console.log("Compass Error: successCallback is not a function");
          return;
        }

        // errorCallback optional
        if (errorCallback && (typeof errorCallback !== "function")) {
          console.log("Compass Error: errorCallback is not a function");
          return;
        }

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
     * 监视heading
     * 根据指定的间隔时间循环获取指南针的方向信息
     * @param successCallback 成功回调函数
     * @param errorCallback   失败回调函数
     * @param options         用于监视heading的选项，针对非iOS平台，指定frequency，指返回数据的时间间隔，其默认值为100msec，
     *                                    针对iOS平台，使用options的filter参数来指定监听的headingFilter阈值
     *                                   （即当方向信息数据变化大于等于该阈值时，引擎通过回调更新方向信息）
     * @return 返回watch id
     */
    watchHeading:function(successCallback, errorCallback, options) {
        // 默认的frequency(100 msec)
        var frequency = (options !== undefined && options.frequency !== undefined) ? options.frequency : 100;
        var filter = (options !== undefined && options.filter !== undefined) ? options.filter : 0;

        // successCallback required
        if (typeof successCallback !== "function") {
          console.log("Compass Error: successCallback is not a function");
          return;
        }

        // errorCallback optional
        if (errorCallback && (typeof errorCallback !== "function")) {
          console.log("Compass Error: errorCallback is not a function");
          return;
        }

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
     * 取消由id指定的监听器
     * @param id 由watchHeading返回的watch id
     */
    clearWatch:function(id) {
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

// file: lib/common/extension/contacts.js
define("xFace/extension/contacts", function(require, exports, module) {
var exec = require('xFace/extension/privateModule').getExecV2(),
    ContactError = require('xFace/extension/ContactError'),
    Contact = require('xFace/extension/Contact');

var contacts = {
    /**
     * 返回一组符合查询条件的联系人数组
     * @param fields 需要查询的域
     * @param successCallback
     * @param errorCallback
     * @param {ContactFindOptions} options 应用在联系人搜索中的选项
     * @return 一组符合查询条件的联系人数组
     */
    find:function(fields, successCallback, errorCallback, options) {
        if (!successCallback) {
            throw new TypeError("You must specify a success callback for the find command.");
        }
        if (!fields || (fields instanceof Array && fields.length === 0)) {
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
     * 创建一个新的联系人，但此函数不将其保存在设备存储上。
     * 要持久保存在设备存储上，可调用contact.save()。
     * @param properties 创建新对象所包含的属性
     * @returns 一个新的联系人对象
     */
    create:function(properties) {
        var i;
        var contact = new Contact();
        for (i in properties) {
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
var channel = require('xFace/channel'),
    exec = require('xFace/exec');

// Tell xFace channel to wait on the onxFaceInfoReady event
channel.waitForInitialization('onxFaceInfoReady');

/**
 * 定义Device,用于提供设备的version, UUID等信息
 * @constructor
 */
function Device() {
    this.platform = null;
    this.version = null;
    this.name = null;
    this.uuid = null;
    this.imei = null;
    this.xFaceVersion = null;
    this.productVersion = null;

    var me = this;

    channel.onxFaceReady.subscribeOnce(function() {
        me.getInfo(function(info) {
            me.platform = info.platform;
            me.version = info.version;
            me.name = info.name;
            me.uuid = info.uuid;
            /**ios不支持获取IEMI*/
            me.imei = info.imei ? info.imei : "not support";
            me.xFaceVersion = info.xFaceVersion;
            me.productVersion = info.productVersion;
            channel.onxFaceInfoReady.fire();
        },function(e) {
            console.log("Error initializing xFace: " + e);
        });
    });
}

/**
 * 获得Device上的属性
 *
 * @param {Function} successCallback 获取device上的属性成功时的回调函数
 * @param {Function} errorCallback 获得device上的属性失败时的回调函数
 */
Device.prototype.getInfo = function(successCallback, errorCallback) {
    if (typeof successCallback !== "function") {
        console.log("Device Error: successCallback is not a function");
        return;
    }

    if (errorCallback && (typeof errorCallback !== "function")) {
        console.log("Device Error: errorCallback is not a function");
        return;
    }

    exec(successCallback, errorCallback, null, "Device", "getDeviceInfo", []);
};

module.exports = new Device();
});

// file: lib/ios/extension/ios/Camera.js
define("xFace/extension/ios/Camera", function(require, exports, module) {
var cameraExport = {};
/**
 * 用于清除使用相机拍照存储在程序的temp文件夹下的照片
 *
 * @param {Function} successCallback 成功回调方法
 * @param {Function} errorCallback 失败回调方法
 */
cameraExport.cleanup = function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, null, "Camera", "cleanup", []);
};

module.exports = cameraExport;

});

// file: lib/ios/extension/ios/Contact.js
define("xFace/extension/ios/Contact", function(require, exports, module) {
var exec = require('xFace/exec'),
    ContactError = require('xFace/extension/ContactError');

/**
 * Provides iOS Contact.display API.
 */
module.exports = {
    /*
     *    Display a contact using the iOS Contact Picker UI
     *    NOT part of W3C spec so no official documentation
     *
     *    @param errorCB error callback
     *    @param options object
     *    allowsEditing: boolean AS STRING
     *        "true" to allow editing the contact
     *        "false" (default) display contact
     */
    display : function(errorCB, options) {
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
        exec(successCallback, errorCallback, null, "File", "setMetadata", [this.fullPath, metadataObject]);
    }
};

});

// file: lib/ios/extension/ios/FileReader.js
define("xFace/extension/ios/FileReader", function(require, exports, module) {
var exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    FileReader = require('xFace/extension/FileReader'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

module.exports = {
    readAsText:function(file, encoding) {
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

// file: lib/ios/extension/ios/app.js
define("xFace/extension/ios/app", function(require, exports, module) {
var exec = require('xFace/exec');
var app = function() {
};

/**
 * 调用系统自带的浏览器打开url
 * @param url             待打开的url
 * @param successCallback 成功回调函数
 * @param errorCallback   失败回调函数
 */
app.prototype.openUrl = function(url, successCallback, errorCallback){
    exec(successCallback, errorCallback, null, "App", "openUrl", [url]);
};
module.exports = new app();
});

// file: lib/ios/extension/ios/console.js
define("xFace/extension/ios/console", function(require, exports, module) {
var exec = require('xFace/exec');

/**
 * This class provides access to the debugging console.
 * @constructor
 */
var DebugConsole = function() {
    this.winConsole = window.console;
    this.logLevel = DebugConsole.INFO_LEVEL;
};

// from most verbose, to least verbose
DebugConsole.ALL_LEVEL    = 1; // same as first level
DebugConsole.INFO_LEVEL   = 1;
DebugConsole.WARN_LEVEL   = 2;
DebugConsole.ERROR_LEVEL  = 4;
DebugConsole.NONE_LEVEL   = 8;

DebugConsole.prototype.setLevel = function(level) {
    this.logLevel = level;
};

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
 * Print a normal log message to the console
 * @param {Object|String} message Message or object to print to the console
 */
DebugConsole.prototype.log = function(message) {
    if (this.logLevel <= DebugConsole.INFO_LEVEL) {
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'INFO' } ]);
    } else {
       this.winConsole.log(message);
    }
 };

/**
 * Print a warning message to the console
 * @param {Object|String} message Message or object to print to the console
 */
DebugConsole.prototype.warn = function(message) {
    if (this.logLevel <= DebugConsole.WARN_LEVEL)
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'WARN' } ]);
    else
        this.winConsole.error(message);
};

/**
 * Print an error message to the console
 * @param {Object|String} message Message or object to print to the console
 */
DebugConsole.prototype.error = function(message) {
    if (this.logLevel <= DebugConsole.ERROR_LEVEL)
        exec(null, null, null, 'Console', 'log', [ stringify(message), { logLevel: 'ERROR' } ]);
    else
        this.winConsole.error(message);
};

module.exports = new DebugConsole();
});

// file: lib/ios/extension/ios/contacts.js
define("xFace/extension/ios/contacts", function(require, exports, module) {
var exec = require('xFace/exec');

/**
 * Provides iOS enhanced contacts API.
 */
module.exports = {
    /*
     *  Create a contact using the iOS Contact Picker UI
     *  NOT part of W3C spec so no official documentation
     *
     *  returns:  the id of the created contact as param to successCallback
     */
    newContactUI : function(successCallback) {
         exec(successCallback, null, null, "Contacts","newContact", []);
    },

    /*
     *    Select a contact using the iOS Contact Picker UI
     *    NOT part of W3C spec so no official documentation
     *
     *    @param errorCB error callback
     *    @param options object
     *    allowsEditing: boolean AS STRING
     *        "true" to allow editing the contact
     *        "false" (default) display contact
     *
     *   returns:  the id of the selected contact as param to successCallback
     */
    chooseContact : function(successCallback, options) {
         exec(successCallback, null, null, "Contacts","chooseContact", [options]);
    }
};
});

// file: lib/ios/extension/ios/nativecomm.js
define("xFace/extension/ios/nativecomm", function(require, exports, module) {
var xFace = require('xFace');

/**
 * Called by native code to retrieve all queued commands and clear the queue.
 */
module.exports = function() {
  var json = JSON.stringify(xFace.commandQueue);
  xFace.commandQueue = [];
  return json;
};
});

// file: lib/ios/extension/ios/notification.js
define("xFace/extension/ios/notification", function(require, exports, module) {
var Media = require('xFace/extension/Media');

module.exports = {
    beep:function(count) {
        (new Media('beep.wav')).play();
    }
};
});

// file: lib/common/extension/network.js
define("xFace/extension/network", function(require, exports, module) {
var exec = require('xFace/exec'),
    xFace = require('xFace'),
    channel = require('xFace/channel');

var NetworkConnection = function () {
    this.type = null;
    this._firstRun = true;
    this._timer = null;
    this.timeout = 500;

    var me = this;

    channel.onxFaceReady.subscribeOnce(function() {
        me.getInfo(function (info) {
            me.type = info;
            if (info === "none") {
                // 如果在定时器到点后，仍然是 offline，则设置一个定时器并发送 offline 事件
                me._timer = setTimeout(function(){
                    xFace.fireDocumentEvent("offline");
                    me._timer = null;
                    }, me.timeout);
            } else {
                // 如果有一个正在处理的 offline 事件，则清除之
                if (me._timer !== null) {
                    clearTimeout(me._timer);
                    me._timer = null;
                }
                xFace.fireDocumentEvent("online");
            }

            // 只 fire 一次
            if (me._firstRun) {
                me._firstRun = false;
                channel.onxFaceConnectionReady.fire();
            }
        },
        function (e) {
            // 如果不能获得 network info，则继续 fire deviceready 事件
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
var FileError = require('xFace/extension/FileError'),
    FileSystem = require('xFace/extension/FileSystem'),
    exec = require('xFace/exec');

/**
 * 请求一个文件系统来存储应用数据
 * @param type  文件系统的类型
 * @param size  指示应用期望的存储大小（bytes）
 * @param successCallback  成功的回调函数
 * @param errorCallback    失败的回调函数
 */
var requestFileSystem = function(type, size, successCallback, errorCallback) {
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
var DirectoryEntry = require('xFace/extension/DirectoryEntry'),
    FileEntry = require('xFace/extension/FileEntry'),
    exec = require('xFace/exec');

var resolveLocalFileSystemURI = function(uri, successCallback, errorCallback) {
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
        }
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
    if(null == keyList || "" == keyList){
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
}

localStorage.getItem = function(key){
    var newKey = getNewKey(privateModule.getAppId(), key);
    var value = m_localStorage_getItem.call(localStorage, newKey);
    return value;
}

localStorage.removeItem = function(key){
    var currentAppId = privateModule.getAppId();
    var newKey = getNewKey(currentAppId, key);
    m_localStorage_removeItem.call(localStorage, newKey);
    //更新保存的keyList，删除相应的key
    var keyList = m_localStorage_getItem.call(localStorage, currentAppId);
    if(null != keyList){
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
}

localStorage.key = function(index){
    var nonNegative = /^\d+(\.\d+)?$/;
    if(nonNegative.test(index)){
        var realIndex = Math.floor(index);
        var keyList = m_localStorage_getItem.call(localStorage, privateModule.getAppId());
        if((null != keyList) && ("" != keyList)){
            var keyArray = keyList.split(keySeparator);
            if(realIndex < keyArray.length){
                var key = keyArray[realIndex];
                return key;
            }
        }
    }
    return null;
}

localStorage.clear = function(){
    //删除当前的app所有的数据，keyList保存了所有属于该app的key值，根据它的信息
    //可以删除全部的数据
    self.clearAppData(privateModule.getAppId());
}

var self = {
    //删除指定的appId所对应的应用的数据。
    clearAppData : function(appId) {
        var keyList = m_localStorage_getItem.call(localStorage, appId);
        if(null != keyList){
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
}

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
        navigator: {
            children: {
                app:{
                    path: 'xFace/extension/ios/app'
                }
            }
        },
        File: { // exists natively, override
            path: 'xFace/extension/File'
        },
        FileReader:{
            path: 'xFace/extension/FileReader'
        },
        console: {
            path: 'xFace/extension/ios/console'
        },
        localStorage : {
            path : 'xFace/localStorage'
        },
        MediaError: {
            path: 'xFace/extension/MediaError'
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
                notification:{
                    path: 'xFace/extension/ios/notification'
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
            boot: function () {

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
                        require('xFace').fireDocumentEvent('deviceready');
                    }, channel.deviceReadyChannelsArray);

                }, [ channel.onDOMContentLoaded, channel.onNativeReady ]);
            }
        };

    // boot up once native side is ready
    channel.onNativeReady.subscribeOnce(_self.boot);

    // _nativeReady is global variable that the native side can set
    // to signify that the native code is ready. It is a global since
    // it may be called before any xFace JS is ready.
    if (window._nativeReady) {
        channel.onNativeReady.fire();
    }

}(window));

})();
