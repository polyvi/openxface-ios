
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
//  APDocument+XAPDocument.h
//  xFace
//
//

#import "APDocument.h"

@interface APDocument (XAPDocument)

/**
	根据指定的file路径获取file数据并生成相应的APDocument对象
	@param anFilePath 用于获取file数据
	@returns 成功返回APDocument对象，失败返回nil
 */
+ (id)documentWithFilePath:(NSString *)anFilePath;

/**
    根据指定的xml数据生成APDocument对象
    @param aData 包含xml数据的对象
    @returns 成功返回APDocument对象，失败返回nil
 */
+ (id)documentWithData:(NSData *)aData;

/**
    获取APDocument实例对应的xml数据
    @returns  包含xml数据的对象，失败返回nil
 */
- (NSData *) prettyXMLData;

@end
