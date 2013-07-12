
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
 * 该模块提供文件的属性和对文件的一系列操作
 * @module file
 * @main file
 */

 var argscheck = require('xFace/argscheck');
 
 /**
  * File定义了单个文件的属性（Android, iOS, WP8）<br/>
  * @example
        var file = new File();
  * @param {String} [name=""] 文件的名称，不包含文件路径信息
  * @param {String} [fullPath=null] 文件的完整路径，包含文件名
  * @param {String} [type=null] 文件类型(常见的MIME类型:如text/html，text/plain，image/gif等)
  * @param {Date} [lastModifiedDate=null] 文件的最后修改时间
  * @param {Number} [size=0] 用bytes单位表示的文件大小
  * @class File
  * @constructor
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var File = function(name, fullPath, type, lastModifiedDate, size){
    /**
     * 文件的名称，不包含文件路径信息(Android, iOS, WP8).
     * @example
        function success(file) {
            alert(file.name);
        }
     * @property name
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.name = name || '';

    /**
     * 文件的完整路径，包含文件名(Android, iOS, WP8).
     * @example
        function success(file) {
            alert(file.fullPath);
        }
     * @property fullPath
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.fullPath = fullPath || null;

    /**
     * 文件类型(mime)(Android, iOS, WP8).
     * @example
        function success(file) {
            alert(file.type);
        }
     * @property type
     * @type String
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.type = type || null;

    /**
     * 文件的最后修改时间(Android, iOS, WP8).
     * @example
        function success(file) {
            alert(file.lastModifiedDate);
        }
     * @property lastModifiedDate
     * @type Date
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.lastModifiedDate = lastModifiedDate || null;

    /**
     * 用bytes单位表示的文件大小(Android, iOS, WP8).
     * @example
        function success(file) {
            alert(file.size);
        }
     * @property size
     * @type Number
     * @platform Android, iOS, WP8
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