
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  XInstallListener.h
//  xFace
//
//

/**
    应用安装、更新、卸载过程中的错误码
 */
typedef enum {
    ERROR_BASE = 0,
    NO_SRC_PACKAGE,                /**< 应用安装包不存在 */
    APP_ALREADY_EXISTED,           /**< 应用已经存在 */
    IO_ERROR,                      /**< IO异常错误 */
    NO_TARGET_APP,                 /**< 没有找到待操作的目标应用 */
    NO_APP_CONFIG_FILE,            /**< 不存在应用配置文件 */
    RESERVED,                      /**< 保留字段,兼容旧的REMOVE_APP_FAILED*/
    UNKNOWN                        /**< 未知错误 */
} AMS_ERROR;

/**
    进度状态码
 */
typedef enum {
    INITIALIZED = 0,               /**< 完成初始化操作 */
    INSTALLING,                    /**< 正在安装 */
    UPDATING_CONFIGURATION,        /**< 正在更新配置文件 */
    FINISHED                       /**< 操作完成 */
} PROGRESS_STATUS;

/**
    标识当前操作类型
 */
typedef enum {
    INSTALL = 1,                   /**< 应用安装操作 */
    UPDATE,                        /**< 应用更新操作 */
    UNINSTALL                      /**< 应用卸载操作 */
} OPERATION_TYPE;

