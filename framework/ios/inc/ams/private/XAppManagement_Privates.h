
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
//  XAppManagement_Privates.h
//  xFaceLib
//
//

#import "XAppManagement.h"

@class XApplicationPersistence;

@interface XAppManagement ()

/**
    已安装应用列表
 */
@property (strong, readwrite) XAppList *appList;

/**
    用于获取配置文件信息
 */
@property (strong, readwrite) XApplicationPersistence *appPersistence;

/**
	用于完成启动应用，关闭应用操作的委托
 */
@property (weak) id<XAmsDelegate> amsDelegate;

/**
	所有正在运行的应用
 */
@property (strong) NSMutableArray *activeApps;

/**
    判定是否使用免解压过程的应用安装器
    @param resPath 应用安装包所在路径或预装应用源码所在路径
    @returns 如果资源为非压缩包时，返回YES,否则返回NO
 */
-(BOOL) shouldUseLightweightInstaller:(NSString *)resPath;

@end
