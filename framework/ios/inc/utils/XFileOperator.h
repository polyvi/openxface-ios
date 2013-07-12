
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
//  XFileOperator.h
//  xFace
//
//

@class APDocument;

/**
    用于定义读取和保持文件的常用方法
 */
@protocol XFileOperator <NSObject>

/**
    读取file数据并生成相应的APDocument对象
    @param anFilePath 用于读取file数据
    @returns 成功返回APDocument对象，失败返回nil
 */
- (APDocument*)readAsDocFromFile:(NSString *)filePath;

/**
    读取file数据并返回数据
    @param anFilePath 用于读取file数据
    @returns 成功返回NSData对象，失败返回nil
 */
- (NSData*)readAsDataFromFile:(NSString *)filePath;

/**
    把APDocument对象保存到指定的文件中
    @param doc 待保存的doc数据
    @param filePath 待保存数据的文件的路径
    @returns 成功返回YES,失败返回NO
 */
- (BOOL) saveDoc:(APDocument *)doc toFile:(NSString *)filePath;

/**
    把NSData保存到指定的文件中
    @param  待保存的data数据
    @param  filePath 待保存数据的文件的路径
    @returns 成功返回YES,失败返回NO
 */
- (BOOL) saveData:(NSData*)data toFile:(NSString *)filePath;

/**
    把NSString保存到指定的文件中
    @param  待保存的string数据
    @param  filePath 待保存数据的文件的路径
    @returns 成功返回YES,失败返回NO
 */
- (BOOL) saveString:(NSString*)string toFile:(NSString *)filePath;

@end
