
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
//  XCipher.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

/**
	提供加解密常用工具方法
 */
@interface XCipher : NSObject

/**
    加解密算法
 */
@property CCAlgorithm algorithm;

/**
    加解密参数选项，包括填充算法等
 */
@property CCOptions   options;

/**
    密钥
 */
@property NSData*     key;

/**
    密钥长度
 */
@property size_t      keySize;

/**
    块长度
 */
@property size_t      blockSize;

/**
   根据加密算法初始化默认参数,
   对于kCCAlgorithmAES128：
   options = PKCS7Padding | kCCOptionECBMode,
   keySize = 16
   blockSize = kCCBlockSizeAES128

   对于kCCAlgorithmDES:
   options = PKCS7Padding | kCCOptionECBMode,
   keySize = 8
   blockSize = kCCBlockSizeDES

   对于kCCAlgorithm3DES:
   options = PKCS7Padding,
   keySize = 24
   blockSize = kCCBlockSize3DES

   @param  alg 指定加解密算法
 */
-(id) initWithAlgorithm:(CCAlgorithm)alg;

/**
    加密文件
    @param fileIn 待处理的的文件路径
    @param fileOut 保存加密结果的文件路径
    @returns 成功返回YES，失败返回NO
 */
-(BOOL) encryptFile:(NSString*)fileIn to:(NSString*)fileOut;

/**
    解密文件
    @param fileIn 待处理的的文件路径
    @param fileOut 保存解密结果的文件路径
    @returns 成功返回YES，失败返回NO
 */
-(BOOL) decryptFile:(NSString*)fileIn to:(NSString*)fileOut;

/**
    解密文件并返回NSData
    @param filePath 待处理的的文件路径
    @returns 成功返回解密后的数据，失败返回nil
 */
-(NSData*) decryptFile:(NSString*)filePath;

/**
    加密数据并保存到文件
    @param sourceData 待处理的数据
    @param fileOut    保存加密结果的文件路径
    @returns 成功返回加密后的数据，失败返回nil
 */
-(BOOL) encryptData:(NSData*)sourceData toFile:(NSString*)fileOut;

/**
    加密数据
    @param sourceData 待处理的数据
    @returns 成功返回加密后的数据，失败返回nil
 */
-(NSData*) encryptData:(NSData*)sourceData;

/**
    解密数据
    @param sourceData 待处理的数据
    @returns 成功返回解密后的数据，失败返回nil
 */
-(NSData*) decryptData:(NSData*)sourceData;

/**
    加密或解密数据
    @param sourceData 待处理的数据
    @returns 成功返回加密或解密的数据，失败返回nil
 */
-(NSData*) cryptData:(NSData*)sourceData withOperation:(CCOperation)op;
@end
