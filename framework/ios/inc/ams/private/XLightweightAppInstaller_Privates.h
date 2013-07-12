
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
//  XLightweightAppInstaller_Privates.h
//  xFaceLib
//
//

#import "XLightweightAppInstaller.h"

@class XAppInfo;

@interface XLightweightAppInstaller ()

/**
    拷贝应用配置文件，便于appList的初始化过程统一
    源目录：<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/app.xml
    目的目录：<Applilcation_Home>/Documents/xface3/app_icons/appId/app.xml
    @param appInfo 用于确定源目录以及目的目录
    @returns 拷贝成功返回YES,否则返回NO
 */
- (BOOL) copyAppConfigFileWithAppInfo:(XAppInfo *)appInfo;

/**
    拷贝应用图标，便于默认应用访问
    源目录：<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/
    目的目录：<Applilcation_Home>/Documents/xface3/app_icons/appId/
    @param appInfo 用于确定源目录以及目的目录
    @returns 拷贝成功返回YES,否则返回NO
 */
- (void) copyAppIconWithAppInfo:(XAppInfo *)appInfo;

/**
    解压内置数据包workspace.zip
    源目录：<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/workspace/workspace.zip
    目的目录：<Applilcation_Home>/Documents/xface3/app_icons/appId/workspace
    @param appInfo 用于确定源目录以及目的目录
    @returns 拷贝成功返回YES,否则返回NO
 */
- (BOOL) unpackAppDataWithAppInfo:(XAppInfo *)appInfo;

@end
