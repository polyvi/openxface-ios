
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
//  NSData+Encoding.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

enum {
    XDataUTF8Encoding      =     0, //UTF8编码
    XDataBase64Encoding    =     1, //base64编码
    XDataHexEncoding       =     2  //16进制编码
};

//数据编码类型
typedef u_int XDataEncoding;


@interface NSData (Encoding)

/**
    将字符串形式的数据按指定的编码格式转换成NSData
    @param string  字符串形式的数据
    @returns NSData实例对象
 */
+ (NSData*) dataWithString:(NSString*)string usingEncoding:(XDataEncoding)encoding;

/**
    将NSData转换成以指定格式编码的字符串形式的数据
    @returns 字符串形式的数据
 */
- (NSString*) stringUsingEncoding:(XDataEncoding)encoding;

@end
