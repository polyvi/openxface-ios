
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

//
//  XFileConstants.h
//  xFace
//
//

#ifdef __XFileExt__

/**
	定义文件操作的错误代码
	@note 必须和js接口处的定义保持一致
 */
enum XFileError {
    NO_ERROR = 0,                           /**< 没有发生错误 */
    NOT_FOUND_ERR = 1,                      /**< 找不到文件 */
    SECURITY_ERR = 2,                       /**< 文件安全权限错误 */
    ABORT_ERR = 3,                          /**< 操作取消 */
    NOT_READABLE_ERR = 4,                   /**< 文件不可读 */
    ENCODING_ERR = 5,                       /**< 编码格式错误 */
    NO_MODIFICATION_ALLOWED_ERR = 6,        /**< 文件不允许修改 */
    INVALID_STATE_ERR = 7,                  /**< 状态错误 */
    SYNTAX_ERR = 8,                         /**< 语法错误 */
    INVALID_MODIFICATION_ERR = 9,           /**< 无效的修改 */
    QUOTA_EXCEEDED_ERR = 10,                /**< 超出配额限制 */
    TYPE_MISMATCH_ERR = 11,                 /**< 文件类型匹配错误 */
    PATH_EXISTS_ERR = 12                    /**< 文件路径错误 */
};

typedef int XFileError;

/**
	文件系统类型
 */
enum XFileSystemType {
	TEMPORARY = 0,                          /**< 临时空间 */
	PERSISTENT = 1                          /**< 持久空间 */
};

typedef int XFileSystemType;

#endif
