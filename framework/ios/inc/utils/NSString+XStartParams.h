
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
//  NSString+XStartParams.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

//用于解析启动参数字符串
//启动参数格式形如：startpage=a/b.html;data=webdata
@interface NSString (XStartParams)

/**
    启动参数中的startpage字段，用于指定启动页面
 */
- (NSString *)startPage;

/**
    启动参数中的data字段，将被传递给web app
 */
- (NSString *)data;

@end

//定义XStartParams使用的私有方法
@interface NSString (Privates)

/**
    获取表达式的value部分，如表达式为：startpage=a/b.html，获取到的value即为a/b.html
    @param theExpression 用于获取value的表达式
    @returns 获取到的value
 */
- (NSString *) extractValueFromExpression:(NSString *)theExpression;

/**
    获取字符串中的startpage与data component
    @param theString 待解析的字符串
    @returns 以startpage或data为key,startpage=a/b.html或data=webdata为value的字典
 */
- (NSDictionary *) getComponents;

@end

