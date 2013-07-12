
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
//  XAPElement.h
//  xFace
//
//

#import "APXML.h"

/**
	定义XAPElement category.
	为APElement添加新方法，以满足查找节点，移除节点等需求
 */
@interface APElement (XAPElement)

/**
	根据tag name以及属性查找相应的节点
	@param aName 用于查找节点的tag name
	@param anAttribute 用于查找的节点的属性
	@returns 成功返回查找到的节点，失败返回nil
 */
- (APElement *)firstChildElementNamed:(NSString *)aName withAttribute:(APAttribute *)anAttribute;

/**
	移除指定节点
	@param anElement 待移除的节点
 */
- (void)removeChild:(APElement*)anElement;

/**
    根据id属性获取APElement对象
    @param aName 要获取的APElment对象的tagName
    @param attribute 要查找的属性名
    @param aValue    要查找的属性值
    @returns 成功返回APElement对象，失败返回nil
 */
- (id)elementNamed:(NSString *) aName attribute:(NSString *)attr withValue:(NSString *)aValue;

@end
