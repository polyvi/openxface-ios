
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
//  XAppPreinstallListener_Private.h
//  xFaceLib
//
//

#import "XAppPreinstallListener.h"

typedef enum {
    PRESET_APP_PACKAGE,               /**< 预置应用包 */
    PRESET_DATA_PACKAGE               /**< 预置数据包 */
} PRESET_PACKAGE_TYPE;

@interface XAppPreinstallListener()

/**
    处理预置包：
    将<system workspace>/pre_set目录下的预置应用包拷贝到defaultApp的<app workspace>/pre_set下
    将<system workspace>/pre_set目录下的预置数据包拷贝到defaultApp的<app workspace>下
    并删除<system workspace>/pre_set目录
 */
- (void) handlePresetPackages;

/**
    将<system workspace>/pre_set目录下的预置应用包拷贝到defaultApp的<app workspace>/pre_set下
 */
- (void) movePresetAppPackages;

/**
    将<system workspace>/pre_set目录下的预置数据包拷贝到defaultApp的<app workspace>下
 */
- (void) movePresetDataPackages;

/**
    获取path下所有与type匹配的package file names
    @param type 指定待查找的package的类型
    @param path package所在路径
    @returns 查找成功时返回包含package file name的数组,否则返回nil
 */
- (NSArray *)getPresetPackagesOfType:(PRESET_PACKAGE_TYPE)type atPath:(NSString *)path;

/**
    将packageFiles中的所有文件从srcPath下移动到dstPath下
    @param packageFiles 包含所有待移动包名的数组
    @param srcPath package所在源路径
    @param dstPath 目的路径
 */
- (void) movePackages:(NSArray *)packageFiles atPath:(NSString *)srcPath toPath:(NSString *)dstPath;

/**
    处理加密代码包：
    将<system workspace>/encrypt_code目录下的加密代码包拷贝到defaultApp的安装目录下
    并删除<system workspace>/encrypt_code目录
 */
- (void) handleEncryptCodePackages;

@end
