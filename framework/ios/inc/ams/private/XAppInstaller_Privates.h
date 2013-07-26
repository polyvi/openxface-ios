
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
//  XAppInstaller_Privates.h
//  xFaceLib
//
//

#import "XAppInstaller.h"

@interface XAppInstaller ()

/**
  删除应用图标
  @param appId  用于标识待删除应用图标所属应用
 */
- (void) deleteAppIconWithAppId:(NSString *)appId;

/**
  移动应用图标到<Applilcation_Home>/Documents/xface3/app_icons/appId/目录下，便于默认应用访问
  @param appInfo 与图标所属应用相关的信息
 */
- (void) moveAppIconWithAppInfo:(XAppInfo *)appInfo;

@end
