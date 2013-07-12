
/*
 Copyright 2012-2013, Polyvi Inc. (http://www.xface3.com)
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

/**
 * @module ams
 */

/**
 * 该类定义了AMS的操作类型，相关用法参考{{#crossLink "AMS"}}{{/crossLink}} （Android, iOS, WP8）<br/>
 * @class AmsOperationType
 * @static
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
function AmsOperationType(type) {
 /**
  * AMS的操作类型，用于表示当前操作类型(Android, iOS, WP8)<br/>
  * 其取值范围参考{{#crossLink "AmsOperationType"}}{{/crossLink}}中定义的常量
  * @example
        function errorCallback(error) {
            if( error.type == AmsOperationType.INSTALL) {
                console.log("Package install operation error!");
            }
        }
  * @property type
  * @type Number
  * @platform Android, iOS, WP8
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
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
AmsOperationType.INSTALL = 1;

/**
 * 应用更新操作
 * @property UPDATE
 * @type Number
 * @final
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
AmsOperationType.UPDATE =  2;

/**
 * 应用卸载操作
 * @property UNINSTALL
 * @type Number
 * @final
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */

AmsOperationType.UNINSTALL = 3;

module.exports = AmsOperationType;
