
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
//  XHexData.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

@interface NSData (HEX)

/*
    将按16进制格式编码的字符串形式的数据转换成NSData
    @param hexString  16进制编码的数据字符串
    @returns NSData实例对象
 */
+ (NSData*) dataWithHexString:(NSString*)hexString;

/**
    将NSData转换成以16进制格式编码的字符串形式的数据
    @returns 以16进制格式编码的字符串形式的数据
 */
- (NSString*) hexString;

@end
