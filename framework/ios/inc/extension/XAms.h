
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
//  XAms.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@protocol XInstallListener;

@class XAppList;

/**
	定义接口，提供给ams扩展对象使用
 */
@protocol XAms <NSObject>

/**
	安装应用
	@param arguments 参数列表
        - 0 id<XApplication> app 调用该接口的应用
        - 1 NSString* pkgPath 应用安装包所在相对路径（相对于app的工作空间）
        - 2 id<XInstallListener> 安装过程监听器
 */
- (void) installApp:(NSArray *)arguments;

/**
	卸载应用
	@param arguments 参数列表
        - 0 NSString* appId 待卸载的应用对应的app id
        - 1 id<XInstallListener> 卸载过程监听器
 */
- (void) uninstallApp:(NSArray *)arguments;

/**
	更新应用
	@param arguments 参数列表
        - 0 id<XApplication> app 调用该接口的应用
        - 1 NSString* pkgPath 应用更新包所在相对路径（相对于app的工作空间）
        - 2 id<XInstallListener> 卸载过程监听器
 */
- (void) updateApp:(NSArray *)arguments;

/**
	启动应用
	@param appId  应用id
	@param params 应用启动参数
    @return 启动是否成功
 */
- (BOOL) startApp:(NSString *)appId withParameters:(NSString *)params;

/**
	获取已安装应用列表
	@returns 获取到的应用安装列表
 */
- (XAppList *) getAppList;

/**
    获取默认应用工作目录的pre_set目录下的所有应用安装包
    返回的数组中每一项为一个应用包的包名
    @return 应用安装包列表，如果为nil则表示没有安装包
 */
- (NSMutableArray *) getPresetAppPackages;

@end
