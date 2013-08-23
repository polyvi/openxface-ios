
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
 * 该模块提供加解密的功能
 * @module security
 * @main   security
 */

 /**
  * 该类提供一系列基础api，用于字符串或者文件的加解密操作（Android, iOS, WP8）<br/>
  * 该类不能通过new来创建相应的对象，只能通过xFace.Security对象来直接使用该类中定义的方法
  * @class Security
  * @platform Android, iOS, WP8
  * @since 3.0.0
  */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');
var Security = function() {};

/**
 * 根据传入的密钥对明文字符串加密，并返回加密后的密文（Android, iOS, WP8）<br/>
 * @example
        //采用3DES方式加密并以16进制返回加密数据，如果没有设置加密方式则默认用DES加密，如果没有设置加密后数据类型则默认返回String类型数据。
        options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.TRIPLE_DES;
        options.EncodeDataType = StringEncodeType.HEX;
        options.EncodeKeyType = StringEncodeType.HEX;
        xFace.Security.encrypt(key, plainText, encryptSuccess, encryptError, options);
        function encryptSuccess(encryptedText) {
            alert("encryptedContent:" + encryptedText);
        }
        function encryptError(errorcode) {
            alert("Encrypt file error:" + errorcode);
        }
 * @method encrypt
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} plainText 需要加密的明文
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.encryptedText 该参数用于返回加密后的密文内容
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回加密错误码
 * <ul>返回的加密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @param {SecurityOptions} [options] 封装加解密配置选项
 * @platform Android, iOS, WP8
 */
Security.prototype.encrypt = function(key, plainText,  successCallback, errorCallback, options){
    argscheck.checkArgs('ssFFO', 'xFace.Security.encrypt', arguments);
    if(key.length < 8 ||  plainText.length === 0){
        if(errorCallback) {
            errorCallback("Wrong parameter of encrypt! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "encrypt", [key, plainText, options]);
};

/**
 * 根据传入的密钥对密文解密，并返回解密后的明文（Android, iOS, WP8）<br/>
 * @example
        //采用3DES方式解密并以16进制返回解密数据，如果没有设置解密方式则默认用DES解密，如果没有设置解密后数据类型则默认返回String类型数据。
        var options = new SecurityOptions();
        options.CryptAlgorithm = SecurityOptions.CryptAlgorithm.TRIPLE_DES;
        options.EncodeDataType = StringEncodeType.HEX;
        options.EncodeKeyType = StringEncodeType.HEX;
        xFace.Security.decrypt(key, plainText, decryptSuccess, decryptError, options);
        function decryptSuccess(decryptedText) {
            alert("decryptedContent:" + decryptedText);
        }
        function decryptError(errorcode) {
            alert("Decrypt file error:" + errorcode);
        }
 * @method decrypt
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} encryptedText 需要解密的密文
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.decryptedText 该参数用于返回解密后的明文内容
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回解密错误码
 * <ul>返回的解密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @param {SecurityOptions} [options] 封装加解密配置选项
 * @platform Android, iOS, WP8
 */
Security.prototype.decrypt = function(key, encryptedText, successCallback, errorCallback, options){
    argscheck.checkArgs('ssFFO', 'xFace.Security.decrypt', arguments);
    if(key.length < 8 || encryptedText.length === 0){
        if(errorCallback) {
            errorCallback("Wrong parameter of decrypt! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "decrypt", [key, encryptedText, options]);
};

/**
 * 根据传入的密钥加密文件，并返回新生成加密文件的路径（Android，iOS, WP8）<br/>
 * @example
        var sourceFilePath = "encrypt_source.txt";
        var targetFilePath = "encrypt_target.txt";
        xFace.Security.encryptFile(key, sourceFilePath, targetFilePath, success, error);
        function success(entry) {
            alert("Encrypt file path:" + entry);
        }
        function error(errorcode) {
            alert("Encrypt file error:" + errorcode);
        }
 * @method encryptFile
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} sourceFilePath 要加密的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {String} targetFilePath 用户指定加密后生成的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.path 该参数用于返回新生成加密文件的路径
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回加密错误码
 * <ul>返回的加密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @platform Android, iOS, WP8
 */
Security.prototype.encryptFile = function(key, sourceFilePath, targetFilePath, successCallback, errorCallback){
    argscheck.checkArgs('sssFF', 'xFace.Security.decrypt', arguments);
    if(key.length < 8){
        if(errorCallback) {
            errorCallback("Wrong parameter of encryptFile! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "encryptFile", [key, sourceFilePath,targetFilePath]);
};

/**
 * 根据传入的密钥解密文件，返回解密后的新生成文件的路径（Android，iOS, WP8）<br/>
 * @example
        var sourceFilePath = "decrypt_source.txt";
        var targetFilePath = "decrypt_target.txt";
        xFace.Security.decryptFile(key, sourceFilePath,targetFilePath, success, error);
        function success(entry) {
            alert("Decrypt file path:" + entry);
        }
        function error(errorcode) {
            alert("Decrypt file error:" + errorcode);
        }
 * @method decryptFile
 * @param {String} key 密钥，长度必须大于或等于8个字符
 * @param {String} sourceFilePath 要解密的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {String} targetFilePath 用户指定解密后生成的文件路径，只支持相对路径（相对于应用的工作空间）
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.path 该参数用于返回新生成解密文件的路径
 * @param {Function} [errorCallback]  失败回调函数
 * @param {String} errorCallback.errorCode 该参数用于返回解密错误码
 * <ul>返回的解密错误码具体说明：</ul>
 * <ul>1:   文件找不到错误</ul>
 * <ul>2:   加密路径错误</ul>
 * <ul>3:   加密过程出错</ul>
 * @platform Android, iOS, WP8
 */
Security.prototype.decryptFile = function(key, sourceFilePath, targetFilePath, successCallback, errorCallback){
    argscheck.checkArgs('sssFF', 'xFace.Security.decrypt', arguments);
    if(key.length < 8) {
        if(errorCallback) {
            errorCallback("Wrong parameter of decryptFile! key length is less than 8");
        }
        return;
    }
    exec(successCallback, errorCallback, null, "Security", "decryptFile", [key, sourceFilePath,targetFilePath]);
};

/**
 * 根据传入的数据求MD5值，并返回该数据的MD5值（Android, iOS, WP8）<br/>
 * @example
        var data = "test1234567890";
        xFace.Security.digest(data, successCallback, errorCallback);
        function successCallback(MD5Value) {
            alert("MD5 value:" + MD5Value);
        }
        function errorCallback(errorcode) {
            alert("digest failed!");
        }
 * @method digest
 * @param {String} data 需要求MD5值的数据
 * @param {Function} [successCallback] 成功回调函数
 * @param {String} successCallback.MD5Value MD5值
 * @param {Function} [errorCallback]  失败回调函数
 * @platform Android, iOS, WP8
 */
Security.prototype.digest = function(data, successCallback, errorCallback){
    argscheck.checkArgs('sFF', 'xFace.Security.digest', arguments);
    exec(successCallback, errorCallback, null, "Security", "digest", [data]);
};

module.exports = new Security();
