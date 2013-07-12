
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
 * @module zip
 */

/**
 * 该类定义一些常量，用于标识压缩和解压失败的错误信息（Android, iOS, WP8）<br/>
 * 相关参考： {{#crossLink "Zip"}}{{/crossLink}}
 * @class ZipError
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */

var ZipError = function() {
};

/**
 * 待压缩的文件或文件夹不存在（Android, iOS, WP8）
 * @property FILE_NOT_EXIST
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ZipError.FILE_NOT_EXIST = 1;

/**
 * 压缩文件出错.（Android, iOS, WP8）
 * @property COMPRESS_FILE_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ZipError.COMPRESS_FILE_ERROR = 2;

/**
 * 解压文件出错.（Android, iOS, WP8）
 * @property UNZIP_FILE_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ZipError.UNZIP_FILE_ERROR = 3;

/**
 * 文件路径错误(相应的文件(夹)不在APP的workspace下)（Android, iOS, WP8）
 * @property FILE_PATH_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ZipError.FILE_PATH_ERROR = 4;

/**
 * 文件类型错误,不支持的文件类型（Android, iOS, WP8）
 * @property FILE_TYPE_ERROR
 * @type Number
 * @static
 * @final
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
ZipError.FILE_TYPE_ERROR = 5;

module.exports = ZipError;
