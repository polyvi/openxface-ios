
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

/**
 * FileError用于表示文件操作出现的具体的错误（Android, iOS, WP8）<br/>
 * @class FileError
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
function FileError(error) {
  /**
   * 文件操作的错误码，用于表示具体的文件操作错误(Android, iOS, WP8)<br/>
   * 其取值范围参考{{#crossLink "FileError"}}{{/crossLink}}中定义的常量
   * @example
            function errorCallback(fileError) {
                if( fileError.code == FileError.PATH_EXISTS_ERR) {
                    print("File is already exists!");
                }
            }
   * @property code
   * @type Number
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  this.code = error || null;
}

// File error codes
// Found in DOMException
/**
 * 表示没有找到相应的文件或者目录的错误（Android，iOS, WP8）
 * @example
            FileError.NOT_FOUND_ERR;
 * @property NOT_FOUND_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.NOT_FOUND_ERR = 1;

/**
 * 表示所有没被其他错误类型所涵盖的安全错误（Android，iOS, WP8）<br/>
 * 例如：当前文件在Web应用中被访问是不安全的；对文件资源过多的访问等
 * @example
           FileError.SECURITY_ERR;
 * @property SECURITY_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.SECURITY_ERR = 2;

/**
 * 表示文件操作被中止错误（Android，iOS, WP8）
 * @example
           FileError.ABORT_ERR;
 * @property ABORT_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.ABORT_ERR = 3;

// Added by File API specification
/**
 * 表示文件或目录无法读取的错误（Android，iOS, WP8）<br/>
 * 通常是由于另外一个应用已经获取了当前文件的引用并使用了并发锁（Android，iOS）
 * @example
           FileError.NOT_READABLE_ERR;
 * @property NOT_READABLE_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.NOT_READABLE_ERR = 4;

/**
 * 表示文件编码错误（Android，iOS, WP8）<br/>
 * 例如：在特殊的字符串中包含不合法的协议或者字符串无法被解析时，返回该错误码
 * @example
           FileError.ENCODING_ERR;
 * @property ENCODING_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.ENCODING_ERR = 5;

/**
 * 表示文件修改拒绝的错误（Android，iOS, WP8）<br/>
 * 例如：当试图写入一个文件或目录时（底层文件系统不允许修改该文件或目录，如存在访问权限等问题）会返回该错误码
 * @example
           FileError.NO_MODIFICATION_ALLOWED_ERR;
 * @property NO_MODIFICATION_ALLOWED_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.NO_MODIFICATION_ALLOWED_ERR = 6;

/**
 * 表示无效的文件操作状态错误（Android，iOS, WP8）<br/>
 * 例如：一个进程在写文件的时候又有个进程对同一个文件进行写的操作时会返回该错误码
 * @example
           FileError.INVALID_STATE_ERR;
 * @property INVALID_STATE_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.INVALID_STATE_ERR = 7;

/**
 * 表示文件格式错误（Android，iOS, WP8）<br/>
 * 例如：在请求一个文件来存储应用数据，被请求的文件格式不是临时文件或持久文件时，返回该错误码
 * @example
           FileError.SYNTAX_ERR;
 * @property SYNTAX_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.SYNTAX_ERR = 8;

/**
 * 表示非法的文件修改请求错误（Android，iOS, WP8）<br/>
 * 例如：同级移动（即移动到文件或目录所在目录）且没有提供和当前名称不同的名称时，会返回该错误码
 * @example
           FileError.INVALID_MODIFICATION_ERR;
 * @property INVALID_MODIFICATION_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.INVALID_MODIFICATION_ERR = 9;

/**
 * 表示文件操作越界错误（Android，iOS, WP8）<br/>
 * 例如：当向一个只有4kb的存储空间中存储超过它容量的文件时，会返回该错误码
 * @example
           FileError.QUOTA_EXCEEDED_ERR;
 * @property QUOTA_EXCEEDED_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.QUOTA_EXCEEDED_ERR = 10;

/**
 * 表示文件类型不匹配错误（Android，iOS, WP8）<br/>
 * 当试图查找文件或目录而查找的对象类型不是请求的对象类型时返回该错误码<br/>
 * 例如：当用户请求一个FileEntry对象，而该对象其实是一个DirectoryEntry对象时会返回该错误码
 * @example
           FileError.TYPE_MISMATCH_ERR;
 * @property TYPE_MISMATCH_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.TYPE_MISMATCH_ERR = 11;

/**
 * 表示文件或目录已存在错误（Android，iOS, WP8）<br/>
 * 例如：当试图创建路径已经存在的文件或目录时返回该错误码
 * @example
           FileError.PATH_EXISTS_ERR;
 * @property PATH_EXISTS_ERR
 * @type Number
 * @final
 * @platform Android，iOS, WP8
 * @since 3.0.0
 */
FileError.PATH_EXISTS_ERR = 12;

module.exports = FileError;