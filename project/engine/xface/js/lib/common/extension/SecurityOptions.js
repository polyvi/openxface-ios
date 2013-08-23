
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
 * @module security
 */

 /**
  * 该类封装了加密算法配置选项（Android, iOS, WP8）<br/>
  * @class SecurityOptions
  * @platform Android, iOS
  * @since 3.0.0
  */
function SecurityOptions() {
    /**
     * 加解密用到的算法(Android, iOS, WP8)<br/>
     * @example
            //采用DES算法加密
            var options = new SecurityOptions();
            options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.DES;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options);
            //采用3DES算法加密
            var options = new SecurityOptions();
            options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.TRIPLE_DES;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options);
            //采用RSA算法加密
            var options = new SecurityOptions();
            options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.RSA;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options);
            //采用DES算法解密
            var options = new SecurityOptions();
            options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.DES;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options);
            //采用3DES算法解密
            var options = new SecurityOptions();
            options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.TRIPLE_DES;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options);
            //采用RSA算法解密
            var options = new SecurityOptions();
            options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.RSA;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options);
     * @property CryptAlgorithm
     * @type Number
     * @default SecurityOptions.CryptAlgorithm.DES
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.CryptAlgorithm = SecurityOptions.CryptAlgorithm.DES;
    /**
     * 加密结果(解密内容)字符串编码类型(Android, iOS, WP8)
     * @example
            //加密后返回数据为Base64编码
            var options = new SecurityOptions();
            options.EncodeDataType = StringEncodeType.STRING;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options)
            //加密后返回数据为16进制编码
            var options = new SecurityOptions();
            options.EncodeDataType = StringEncodeType.HEX;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options)
            //要解密的数据格式为Base64编码
            var options = new SecurityOptions();
            options.EncodeDataType = StringEncodeType.STRING;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options)
            //要解密的数据格式为16进制编码
            var options = new SecurityOptions();
            options.EncodeDataType = StringEncodeType.HEX;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options)
     * @property EncodeDataType
     * @type Number
     * @default StringEncodeType.STRING
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.EncodeDataType = StringEncodeType.Base64;
    /**
     * 加密key结果(解密key内容)字符串编码类型(Android, iOS, WP8)
     * @example
            //要加密的key格式为Base64编码
            var options = new SecurityOptions();
            options.EncodeKeyType = StringEncodeType.STRING;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options)
            //要加密的key格式为16进制编码
            var options = new SecurityOptions();
            options.EncodeKeyType = StringEncodeType.HEX;
            xFace.Security.encrypt(key, plainText, decryptSuccess, decryptError, options)
            //要解密的key格式为Base64编码
            var options = new SecurityOptions();
            options.EncodeKeyType = StringEncodeType.STRING;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options)
            //要解密的key格式为16进制编码
            var options = new SecurityOptions();
            options.EncodeKeyType = StringEncodeType.HEX;
            xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options)
     * @property EncodeKeyType
     * @type Number
     * @default StringEncodeType.STRING
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    this.EncodeKeyType = StringEncodeType.STRING;
}
  /**
   * 该类定义一些常量，用于标识加解密采用的算法类型（Android, iOS）<br/>
   * 相关参考： {{#crossLink "Security"}}{{/crossLink}}
   * @class CryptAlgorithm
   * @namespace SecurityOptions
   * @static
   * @platform Android, iOS, WP8
   * @since 3.0.0
   */
  SecurityOptions.CryptAlgorithm = {
    /**
     * DES加密算法
     * @property DES
     * @type Number
     * @final
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    DES : 1,
    /**
     * 3DES加密算法
     * @property TRIPLE_DES
     * @type Number
     * @final
     * @platform Android, iOS, WP8
     * @since 3.0.0
     */
    TRIPLE_DES : 2,
    /**
     * RSA加密算法
     * @property RSA
     * @type Number
     * @final
     * @platform Android, iOS
     * @since 3.0.0
     */
    RSA : 3
  },
module.exports = SecurityOptions;
