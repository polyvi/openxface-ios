
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
//  XAppInstallerProtocol.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

@protocol XInstallListener;

@class XAppList;
@class XApplicationPersistence;

@protocol XAppInstallerProtocol <NSObject>

@required

/**
    初始化方法
    @param installedAppList 已安装应用列表
    @param applicationPersistence 用于读写配置文件
    @returns 成功返回installer对象，否则返回nil
 */
- (id) initWithAppList:(XAppList *)installedAppList appPersistence:(XApplicationPersistence *)applicationPersistence;

/**
    安装应用
    @param resPath 应用安装包所在路径或预装应用源码所在路径
    @param listener 应用安装监听器
 */
- (void) install:(NSString *)resPath withListener:(id<XInstallListener>)listener;

/**
    更新应用
    @param resPath 应用更新包路径或预装应用源码所在路径
    @param listener 应用更新监听器
 */
- (void) update:(NSString *)resPath withListener:(id<XInstallListener>)listener;

@optional

/**
    卸载指定应用
    @param appId 待卸载应用对应的appId
    @param listener 应用卸载监听器
 */
- (void) uninstall:(NSString *)appId withListener:(id<XInstallListener>)listener;

@end
