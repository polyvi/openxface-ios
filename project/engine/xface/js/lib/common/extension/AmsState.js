
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

﻿/**
 * @module ams
 */

/**
 * 该类定义了AMS在安装过程的状态信息，相关用法参考{{#crossLink "AMS"}}{{/crossLink}}（Android, iOS, WP8）<br/>
 * @class AmsState
 * @static
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
function AmsState(state) {
/**
 * 安装的状态码，用于表示具体应用安装的状态(Android, iOS, WP8)<br/>
 * 其取值范围参考{{#crossLink "AmsState"}}{{/crossLink}}中定义的常量
 * @example
        function stateChange(amsstate) {
            if( amsstate.code ==AmsState.INSTALL_INSTALLING) {
            print("the application is installing");
            }
        }
 * @property code
 * @type Number
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
  this.code = state || null;
}
/**
 * 安装初始化
 * @property INSTALL_INITIALIZE
 * @type Number
 * @final
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
AmsState.INSTALL_INITIALIZE          = 0;
/**
 * 应用正在安装
 * @property INSTALL_INSTALLING
 * @type Number
 * @final
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
AmsState.INSTALL_INSTALLING          = 1;
/**
 * 正在写配置文件
 * @property INSTALL_WRITE_CONFIGURATION
 * @type Number
 * @final
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
AmsState.INSTALL_WRITE_CONFIGURATION = 2;
/**
 * 应用安装完成
 * @property INSTALL_FINISHED
 * @type Number
 * @final
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
AmsState.INSTALL_FINISHED            =  3;

module.exports = AmsState;
