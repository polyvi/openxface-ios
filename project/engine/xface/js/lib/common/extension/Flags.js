
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
var argscheck = require('xFace/argscheck');
/**
 * 该对象用于为{{#crossLink "DirectoryEntry"}}{{/crossLink}}对象的{{#crossLink "DirectoryEntry/getFile"}}{{/crossLink}}和
 * {{#crossLink "DirectoryEntry/getDirectory"}}{{/crossLink}}方法提供参数（Android, iOS, WP8）<br/>
 * @example
        var flags = new Flags(true, false);
 * @constructor
 * @param {Boolean} [create=false] 用于指示如果文件或目录不存在时是否创建该文件或目录
 * @param {Boolean} [exclusive=false] 该属性表示是否强制创建文件或目录
 * @class Flags
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
function Flags(create, exclusive) {
    argscheck.checkArgs('BB', 'Flags.Flags', arguments);
    /**
     * 用于指示如果文件或目录不存在时是否创建该文件或目录(Android, iOS, WP8)<br/>
     * @example
        //获取test目录，如果该目录不存在则创建它
        testDir = fileSystem.root.getDirectory("test", {create: true});
     * @property create
     * @type Boolean
     * @default false
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.create = create || false;

    /**
     * 该属性表示是否强制创建文件或目录(Android, iOS, WP8)<br/>
     * 注意：当只用exclusive属性时，它没有效果，它需要和create属性一起使用<br/>
     * 例如：和create一起使用时且create为true，当要创建的目标路径已经存在并且exclusive设为false时，它会导致文件或目录创建失败<br/>
     * 和create一起使用时且create为true，当要创建的目标路径已经存在并且exclusive设为true时，它会强制性的创建该目标路径<br/>
     * @example
        //只有在test.txt不存在时才创建该文件
        testFile = dataDir.getFile("test.txt", {create: true, exclusive: true});
     * @property exclusive
     * @type Boolean
     * @default false
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.exclusive = exclusive || false;
}

module.exports = Flags;