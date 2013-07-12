
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
    Metadata = require('xFace/extension/Metadata'),
    FileError = require('xFace/extension/FileError');

/**
 * 表示文件系统中的一个文件（夹）对象，该类是{{#crossLink "DirectoryEntry"}}{{/crossLink}}
 * 和{{#crossLink "FileEntry"}}{{/crossLink}}的基类（Android, iOS, WP8）<br/>
 * @example
        var entry = new Entry();
 * @class Entry
 * @constructor
 * @param {Boolean} [isFile=false] 用于标识是否为文件（true代表文件）
 * @param {Boolean} [isDirectory=false] 用于标识是否为文件夹（true代表文件夹）
 * @param {String} [name=''] 文件（夹）的名字
 * @param {String} [fullPath=''] 文件（夹）的绝对路径
 * @param {FileSystem} [fileSystem=null] 文件（夹）所在的文件系统
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
function Entry(isFile, isDirectory, name, fullPath, fileSystem) {
    argscheck.checkArgs('BBSSO', 'Entry.Entry', arguments);
    /**
     * 是否是文件对象(Android, iOS, WP8)
     * @example
           entry.isFile
     * @property isFile
     * @type Boolean
     * @default false
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isFile = (typeof isFile != 'undefined'?isFile:false);

    /**
     * 是否是文件夹对象(Android, iOS, WP8)
     * @example
           entry.isDirectory
     * @property isDirectory
     * @type Boolean
     * @default false
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.isDirectory = (typeof isDirectory != 'undefined'?isDirectory:false);

    /**
     * 文件（夹）的名称，不包含路径(Android, iOS, WP8)
     * @example
           entry.name
     * @property name
     * @type String
     * @default ""
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.name = name || '';

    /**
     * 文件（夹）的绝对路径(Android, iOS, WP8)
     * @example
           entry.fullPath
     * @property fullPath
     * @type String
     * @default ""
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.fullPath = fullPath || '';

    /**
     * 文件（夹）所在的文件系统(Android, iOS, WP8)
     * @example
           entry.filesystem
     * @property filesystem
     * @type FileSystem
     * @default null
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.filesystem = fileSystem || null;
}

/**
 * 移动文件（夹）（Android, iOS, WP8）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/moveTo"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/moveTo"}}{{/crossLink}}的实例
 * @method moveTo
 * @param {DirectoryEntry} parent 将要移动到的父目录
 * @param {String} [newName=this.name] 文件（夹）的新名字
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry|DirectoryEntry} successCallback.entry 移动后的文件（夹）对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
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
 * 复制文件（夹）（Android, iOS, WP8）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/copyTo"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/copyTo"}}{{/crossLink}}的实例
 * @method copyTo
 * @param {DirectoryEntry} parent  将要复制到的父目录对象
 * @param {String} [newName=this.name] 文件（夹）的新名字
 * @param {Function} [successCallback] 成功回调函数
 * @param {FileEntry|DirectoryEntry} successCallback.entry 复制后的文件（夹）对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
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
 * 删除一个文件（夹）（Android, iOS, WP8）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/remove"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/remove"}}{{/crossLink}}的实例
 * @method remove
 * @param {Function} [successCallback] 成功回调函数
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
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
 * 返回当前文件（夹）的URL地址（Android, iOS, WP8）
 * @example
        var dirURL = entry.toURL();
 * @method toURL
 * @return {String} URL地址
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Entry.prototype.toURL = function() {
    // fullPath attribute contains the full URL
    return "file://" + this.fullPath;
};

/**
 * 返回当前文件（夹）的URI信息（Android, iOS, WP8）
 * @deprecated 该方法以后可能不支持，建议使用toURL方法
 * @method toURI
 * @param {String} mimeType 文件类型(常见的MIME类型:如"text/html"，"text/plain"，"image/gif"等)
 * @return {String} URI信息
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
Entry.prototype.toURI = function(mimeType) {
    argscheck.checkArgs('s', 'Entry.toURI', arguments);
    console.log("DEPRECATED: Update your code to use 'toURL'");
    return "file://" + this.fullPath;
};

/**
 * 获取当前文件（夹）的父目录（Android, iOS, WP8）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/getParent"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/getParent"}}{{/crossLink}}的实例
 * @method getParent
 * @param {Function} successCallback 成功回调函数
 * @param {DirectoryEntry} successCallback.entry 父目录对象
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
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
 * 获取当前文件（夹）的元数据（Android, iOS, WP8）<br/>
 * 示例请参考DirectoryEntry的{{#crossLink "DirectoryEntry/getMetadata"}}{{/crossLink}}和FileEntry的{{#crossLink "FileEntry/getMetadata"}}{{/crossLink}}的实例
 * @method getMetadata
 * @param {Function} successCallback 成功回调函数
 * @param {Metadata} successCallback.metadata 目标对象的元数据
 * @param {Function} [errorCallback]  失败回调函数
 * @param {FileError} errorCallback.fileError 错误信息
 * @platform Android, iOS, WP8
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