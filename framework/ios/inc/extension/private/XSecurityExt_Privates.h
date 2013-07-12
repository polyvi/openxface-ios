
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
//  XSecurityExt_Privates.h
//  xFaceLib
//
//

#ifdef __XSecurityExt__

#import "XSecurityExt.h"

#define SECURITY_KEY_MIN_LENGTH    8

#define kKeyForDES                 @1
#define kKeyFor3DES                @2
#define kKeyForRSA                 @3


#define kKeyForALG                 @"CryptAlgorithm"
#define kKeyForEncodeDataType      @"EncodeDataType"
#define kKeyForEncodeKeyType       @"EncodeKeyType"

enum SecurityError {
    FILE_NOT_FOUND_ERR = 1,
    PATH_ERR = 2,
    OPERATION_ERR = 3
};
typedef NSUInteger SecurityError;

@interface NSDictionary (XCiphers)

/**
    获取指定的算法的加解密器
    @param key 加解密算法的键值
    @returns 返回键值对应的加解密算法的加解密器，或者默认des算法的加解密器如果键值对应的加解密算法不存在
 */
- (XCipher*) cipherForKey:(id)key;

@end

@interface XSecurityExt ()

/**
    检查加解密参数的有效性.
    @returns 有效返回YES,否则返回NO
 */
- (BOOL) checkArguments:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    根据arguments 和 action 加密或解密文件
    @param arguments
    - 0 XJsCallback* callback
    - 1 sKey 密钥
    - 2 sourceFile 源文件
    - 3 targetFile 目标文件所存的位置
    @param options 用于存放jscallback及application对象
    @param op 加密或解密
 */
- (void) doFileCrypt:(NSMutableArray*)arguments withDict:(NSMutableDictionary *)options useOperation:(SecurityAction)op;

@end

#endif
