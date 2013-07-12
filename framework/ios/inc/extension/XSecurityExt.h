
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
//  XSecurityExt.h
//  xFaceLib
//
//

#ifdef __XSecurityExt__

#import "XExtension.h"

@class XCipher;

typedef NSUInteger SecurityAction;

@interface XSecurityExt : XExtension
{
    NSDictionary *ciphers;                 /**<用于执行数据加解密的具体操作*/
}

/**
    初始化方法
    @param msgHandler 消息处理者
    @return 初始化后的Security扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
    使用指定算法加密,通过回调返回加密后的数据.
    @param arguments
    - 0 XJsCallback* callback
    - 1 sKey 密钥
    - 2 sourceData 需要加密的数据
    - 3 jsOptions  需要加密的数据
        - 1 CryptAlgorithm        加密算法，默认des
        - 2 EncodeDataType        数据编码格式，默认base64
        - 3 kKeyForEncodeKeyType  密钥编码格式，默认16进制

 */
- (void) encrypt:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    使用指定算法解密,通过回调返回解密后的数据.
    @param arguments
    - 0 XJsCallback* callback
    - 1 sKey 密钥
    - 2 sourceData 需要解密的数据
    - 3 jsOptions  需要加密的数据
        - 1 CryptAlgorithm        加密算法，默认des
        - 2 EncodeDataType        数据编码格式，默认base64
        - 3 kKeyForEncodeKeyType  密钥编码格式，默认16进制

 */
- (void) decrypt:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    使用指定算法加密文件,通过回调返回加密后的数据.
    @param arguments
    - 0 XJsCallback* callback
    - 1 sKey 密钥
    - 2 sourceFile 需要加密的文件
    - 3 targetFile 加密的后文件所存的位置
 */
- (void) encryptFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    使用指定算法解密文件,通过回调返回解密后的数据.
    @param arguments
    - 0 XJsCallback* callback
    - 2 sourceFile 需要解密的文件
    - 3 targetFile 解密的后文件所存的位置
 */
- (void) decryptFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    根据传入的数据求MD5值，并通过回调返回该数据的MD5值
    @param arguments
    - 0  data 需要求MD5值的数据
 */
- (void) digest:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
