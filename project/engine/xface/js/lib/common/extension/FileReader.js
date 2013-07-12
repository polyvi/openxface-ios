
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
 * @module file
 */

var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec'),
    FileError = require('xFace/extension/FileError'),
    ProgressEvent = require('xFace/extension/ProgressEvent');

 /**
  * FileReader提供了读取文件的系列接口（Android，iOS, WP8）<br/>
  * 用户可以通过注册通知回调onloadstart、onprogress、onload、onloadend、onerror和onabort来分别监听
  * 开始读事件、读取进度事件、读取结束事件、读取成功完成事件、读取错误事件和读取被中止事件
  * @example
         var reader = new FileReader();
  * @class FileReader
  * @constructor
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var FileReader = function() {
    /**
     * 文件名称（如果是String类型则表示文件的绝对路径，否则是File对象）（Android，iOS, WP8）
     * @example
        var reader = new FileReader();
        var name = reader.fileName;
     * @property fileName
     * @default ""
     * @type String|File
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.fileName = "";

    /**
     * 文件读取的状态(参考{{#crossLink "FileReader"}}{{/crossLink}}类的EMPTY,LOADING,DONE常量)（Android，iOS, WP8）
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.readyState = 0;

    /**
     * 读取的文件内容（Android，iOS, WP8）
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.result = null;

    /**
     * 读取文件时发生的错误信息（Android，iOS, WP8）
     * @example
        function errorInfo(error) {
            console.log(error.code);
        }
     * @property error
     * @default null
     * @type FileError
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.error = null;

    /**
     * 文件读取开始时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onloadstart = null;    // When the read starts.

    /**
     * 当读取（或解码）一个文件或文件块数据时，或当报告部分文件数据时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onprogress = null;     // While reading (and decoding) file or fileBlob data, and reporting partial file data (progess.loaded/progress.total)

    /**
     * 文件读取操作成功完成时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onload = null;         // When the read has successfully completed.

    /**
     * 文件读取操作失败时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onerror = null;        // When the read has failed (see errors).

    /**
     * 文件读取操作完成后调用该通知回调函数（不管读取成功或者失败都会调用该通知回调函数）（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onloadend = null;      // When the request has completed (either in success or failure).

    /**
     * 文件读取操作取消时调用该通知回调函数，如abort方法被调用时（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onabort = null;        // When the read has been aborted. For instance, by invoking the abort() method.
};

// States
/**
 * 表示文件未开始读取状态（Android，iOS, WP8）
 * @example
        FileReader.EMPTY;
 * @property EMPTY
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileReader.EMPTY = 0;
/**
 * 表示文件正在进行读取状态（Android，iOS, WP8）
 * @example
        FileReader.LOADING;
 * @property LOADING
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileReader.LOADING = 1;
/**
 * 表示文件结束读取状态（Android，iOS, WP8）
 * @example
        FileReader.DONE;
 * @property DONE
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileReader.DONE = 2;

/**
 * 取消读取文件（Android, iOS, WP8）
 * @example
        var reader = new FileReader();
        reader.abort();
 * @method abort
 * @platform Android, iOS, WP8
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
 * 读取文本文件（Android，iOS, WP8）<br/>
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
 * @platform Android, iOS, WP8
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
 * 读取文件并以base64编码的URL字符串形式返回(URL的格式由IETF在RFC2397中定义)（Android，iOS, WP8）<br/>
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
 * @platform Android, iOS, WP8
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
 * 读取文件并返回二进制数据,返回的messageType为BinaryString（Android，iOS, WP8）<br/>
 * 用户可以注册FileReader的通知回调函数来接收读取的结果
 * @example
        function readAsBinaryString(file) {
            var reader = new FileReader();
            reader.onloadend = function(evt) {
                console.log("Read as binary string");
                console.log(evt.target.result);
            };
            reader.readAsBinaryString(file);
        }
 * @method readAsBinaryString
 * @param {File} file 要读取的文件对象
 * @platform Android, iOS, WP8
 * @since 3.1.0
 */
FileReader.prototype.readAsBinaryString = function(file) {
    argscheck.checkArgs('o', 'FileReader.readAsBinaryString', arguments);
    var me = this;
    var execArgs = [this.fileName, file.start, file.end];
    // Read file
    exec(
        // Success callback
        function(r) {
            // If DONE (cancelled), then don't do anything
            if (me.readyState === FileReader.DONE) {
                return;
            }
            // DONE state
            me.readyState = FileReader.DONE;
            me.result = r;
            // If onload callback
            if (typeof me.onload === "function") {
                me.onload(new ProgressEvent("load", {target:me}));
            }
            // If onloadend callback
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        },
        // Error callback
        function(e) {
            // If DONE (cancelled), then don't do anything
            if (me.readyState === FileReader.DONE) {
                return;
            }
            // DONE state
            me.readyState = FileReader.DONE;
            me.result = null;
            // Save error
            me.error = new FileError(e);
            // If onerror callback
            if (typeof me.onerror === "function") {
                me.onerror(new ProgressEvent("error", {target:me}));
            }
            // If onloadend callback
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        }, "File", "readAsBinaryString", execArgs);
};

/**
 * 读取文件并返回二进制数据,返回的messageType为ArrayBuffer（Android，iOS, WP8）<br/>
 * 用户可以注册FileReader的通知回调函数来接收读取的结果
 * @example
        function readAsArrayBuffer(file) {
            var reader = new FileReader();
            reader.onloadend = function(evt) {
                console.log("Read as array buffer");
                console.log(evt.target.result);
            };
            reader.readAsArrayBuffer(file);
        }
 * @method readAsArrayBuffer
 * @param {File} file 要读取的文件对象
 * @platform Android, iOS, WP8
 * @since 3.1.0
 */
FileReader.prototype.readAsArrayBuffer = function(file) {
    argscheck.checkArgs('o', 'FileReader.readAsArrayBuffer', arguments);
    var me = this;
    var execArgs = [this.fileName, file.start, file.end];
    // Read file
    exec(
        // Success callback
        function(r) {
            // If DONE (cancelled), then don't do anything
            if (me.readyState === FileReader.DONE) {
                return;
            }
            // DONE state
            me.readyState = FileReader.DONE;
            me.result = r;
            // If onload callback
            if (typeof me.onload === "function") {
                me.onload(new ProgressEvent("load", {target:me}));
            }
            // If onloadend callback
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        },
        // Error callback
        function(e) {
            // If DONE (cancelled), then don't do anything
            if (me.readyState === FileReader.DONE) {
                return;
            }
            // DONE state
            me.readyState = FileReader.DONE;
            me.result = null;
            // Save error
            me.error = new FileError(e);
            // If onerror callback
            if (typeof me.onerror === "function") {
                me.onerror(new ProgressEvent("error", {target:me}));
            }
            // If onloadend callback
            if (typeof me.onloadend === "function") {
                me.onloadend(new ProgressEvent("loadend", {target:me}));
            }
        }, "File", "readAsArrayBuffer", execArgs);
};

module.exports = FileReader;