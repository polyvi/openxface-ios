
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
//  XApplicationPersistence_Privates.h
//  xFaceLib
//
//

#import "XApplicationPersistence.h"

@interface XApplicationPersistence ()

/**
    获取默认应用对应的app id
    @returns 成功时返回获取到的默认应用对应的app id,失败时返回nil
 */
- (NSString *)getDefaultAppId;

/**
    获取以appId为key,srcRoot为value的所有已安装应用的字典
    @returns 成功时返回获取到已安装应用字典,失败时返回nil
 */
- (NSMutableDictionary *)getAppsDict;

@end
