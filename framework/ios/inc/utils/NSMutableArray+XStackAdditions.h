
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
//  NSMutableArray+XStackAdditions.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

/**
    扩展NSMutableArray的能力，增加栈操作功能
 */
@interface NSMutableArray (XStackAdditions)

/**
	添加元素到栈顶
 */
- (void) push: (id)obj;

/**
	移除并返回位于栈顶的对象
	@returns 栈顶对象
 */
- (id) pop;

/**
	返回位于栈顶的对象但不将其移除
	@returns 栈顶对象
 */
- (id) peek;

@end
