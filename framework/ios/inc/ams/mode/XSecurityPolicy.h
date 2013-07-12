
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
//  XSecurityPolicy.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

@protocol XApplication;

//安全策略接口
@protocol XSecurityPolicy <NSObject>

/**
   启动应用的时 对应用进行校验
   @param app[in] 被启动的应用
   @returns 如果验证有效则返回true，否则返回false
 */
- (BOOL)checkAppStart:(id<XApplication>)app;

/**
   关闭应用时 对应用的校验
   @param app[in] 被关闭的应用
   @returns 如果验证成功返回true，否则返回false
 */
- (BOOL)checkAppClose:(id<XApplication>)app;

@end
