
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
//  XAmsImpl.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XAms.h"

@class XAppManagement;

/**
	提供给ams扩展对象使用
 */
@interface XAmsImpl : NSObject <XAms>
{
    XAppManagement *appManagement;     /**< 负责对应用进行管理 */
}

/**
	初始化方法
	@param applicationManagement 负责对应用进行管理的对象
	@returns 成功返回XAmsImpl对象，否则返回nil
 */
- (id)init:(XAppManagement *)applicationManagement;

@end
