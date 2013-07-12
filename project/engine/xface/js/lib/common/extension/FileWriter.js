
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
 * FileWriter提供了写文件的系列接口（Android，iOS, WP8）<br/>
 * 用户可以通过注册通知回调onwritestart、onprogress、onwrite、onwriteend、onerror和onabort来分别监听<br/>
 * 开始写操作事件、写操作进度事件、写操作结束事件、写操作成功完成事件、写操作错误事件和写操作被中止事件<br/>
 * 一个FileWriter对应一个文件。用户可以用该对象对一个文件进行多次写操作。FileWriter保存了文件指针位置和长度的属性<br/>
 * 所以用户可以在一个文件的任何位置进行查询和写操作。默认情况下，FileWriter会从文件的开始进行写操作(会覆盖文件中已存在的数据)<br/>
 * @example
        var writer = new FileWriter(file);
 * @constructor
 * @param {File} file 文件对象
 * @class FileWriter
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
var FileWriter = function(file) {
    argscheck.checkArgs('o', 'FileWriter.FileWriter', arguments);
    //TODO:PhoneGap支持构造函数加参数，从文件尾部开始写
    /**
     * 文件名称（如果是String类型则表示文件的绝对路径，否则是File对象）（Android，iOS, WP8）
     * @example
        var filename = writer.filename;
     * @property fileName
     * @type String|File
     * @default ""
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.fileName = "";

    /**
     * 要写入的文件长度（Android，iOS, WP8）
     * @example
        var fileLength = writer.length;
     * @property length
     * @type Number
     * @default 0
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.length = 0;
    if (file) {
        this.fileName = file.fullPath || file;
        this.length = file.size || 0;
    }
    // 默认从开始位置写文件
    /**
     * 文件指针的当前位置（Android，iOS, WP8）
     * @example
        function getWriterPosition(writer) {
            console.log(writer.position);
        }
     * @property position
     * @type Number
     * @default 0
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.position = 0;

    /**
     * 文件写操作的状态(参考{{#crossLink "FileWriter"}}{{/crossLink}}类的INIT,WRITING,DONE常量)（Android，iOS, WP8）
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.readyState = 0;

    /**
     * 错误信息（Android，iOS, WP8）
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.error = null;

    /**
     * 写文件开始时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onwritestart = null;   // When writing starts

    /**
     * 在写文件时需要报告写文件进度时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onprogress = null;     // While writing the file, and reporting partial file data

    /**
     * 当写文件请求成功完成时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onwrite = null;        // When the write has successfully completed.

    /**
     * 当写文件请求完成时调用该通知回调函数（不管写操作成功或者失败都会调用该通知回调函数）（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onwriteend = null;     // When the request has completed (either in success or failure).

    /**
     * 当写文件操作被中止时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     **/
    this.onabort = null;        // When the write has been aborted. For instance, by invoking the abort() method.

    /**
     * 当写文件操作出错时调用该通知回调函数（Android，iOS, WP8）<br/>
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
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.onerror = null;        // When the write has failed (see errors).
};

// 状态
/**
 * 表示准备进行写文件操作，但是还未写（Android，iOS, WP8）
 * @example
        FileWriter.INIT;
 * @property INIT
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileWriter.INIT = 0;

/**
 * 表示正在进行写文件操作（Android，iOS, WP8）
 * @example
        FileWriter.WRITING;
 * @property WRITING
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileWriter.WRITING = 1;

/**
 * 表示已经完成写文件操作（Android，iOS, WP8）
 * @example
        FileWriter.DONE;
 * @property DONE
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileWriter.DONE = 2;

/**
 * 取消写文件操作（Android, iOS, WP8）
 * @example
        function abortWrite(writer) {
            writer.abort();
        }
 * @method abort
 * @platform Android, iOS, WP8
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
 * 将数据写入到文件中（Android，iOS, WP8）<br/>
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
 * @platform Android, iOS, WP8
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
 * 将文件指针移动到指定的以byte为单位的具体数值的位置（Android，iOS, WP8）<br/>
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
 * @platform Android, iOS, WP8
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
 * 截取文件到指定大小，文件末尾超过指定大小的内容会被删掉（Android，iOS, WP8）<br/>
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
 * @platform Android, iOS, WP8
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