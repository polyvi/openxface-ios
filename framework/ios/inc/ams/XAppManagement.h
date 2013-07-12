
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
//  XAppManagement.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@protocol XInstallListener;
@protocol XAmsDelegate;
@protocol XAppInstallerProtocol;
@protocol XApplication;

@class XAppList;


#define kAppEventMessage @"message"
#define kAppEventStart   @"start"
#define kAppEventClose   @"close"

/**
	负责对应用进行管理，包括：安装、卸载、更新等
 */
@interface XAppManagement : NSObject
{
    id<XAppInstallerProtocol> appInstaller;                   /**< 需要解压过程的应用安装器，负责应用安装、卸载 */
    id<XAppInstallerProtocol> lightweightAppInstaller;        /**< 免解压过程的应用安装器 */
}

/**
    已安装应用列表
 */
@property (strong, readonly) XAppList *appList;

/**
    初始化方法
    @param amsDelegate 用于完成启动应用，关闭应用操作的委托
    @returns 成功返回XAppManagement对象，否则返回nil
 */
- (id)initWithAmsDelegate:(id<XAmsDelegate>)amsDelegate;

/**
	安装应用
	@param resPath 应用安装包所在路径或预装应用源码所在路径
	@param listener 应用安装监听器
 */
- (void) installApp:(NSString *)resPath withListener:(id<XInstallListener>)listener;

/**
	卸载应用
	@param appId 待卸载的应用对应的app id
	@param listener 应用卸载监听器
 */
- (void) uninstallApp:(NSString *)appId withListener:(id<XInstallListener>)listener;

/**
	更新应用
	@param resPath 待更新应用安装包所在路径或预装应用源码所在路径
	@param listener 应用更新监听器
 */
- (void) updateApp:(NSString *)resPath withListener:(id<XInstallListener>)listener;

/**
	启动应用，如果应用已经启动，返回NO
	@param appId  应用id
	@param params 应用启动参数
    @return 启动是否成功
 */
- (BOOL) startApp:(NSString *)appId withParameters:(NSString *)params;

/**
	关闭应用
	@param appId 应用id
 */
- (void) closeApp:(NSString *)appId;

/**
	启动默认应用
	@param params 启动参数，允许为nil
	@return 启动成功返回YES,否则返回NO
 */
- (BOOL) startDefaultAppWithParams:(NSString *)params;

/**
	标记默认应用.
	将指定appId对应的应用标记为默认应用，同时更新相应的配置文件
	@param appId 待标记为默认应用的应用标识
 */
- (void) markAsDefaultApp:(NSString *)appId;

/**
	判断是否为默认应用
	@param appId 待判定应用对应的id
	@returns 是默认应用返回YES,否则返回NO
 */
- (BOOL) isDefaultApp:(NSString *)appId;

/**
    处理app事件
    @param app 发起事件的app
    @param event 事件类型
    @param msg   消息
 */
-(void)handleAppEvent:(id<XApplication>)app event:(NSString*)event msg:(NSString*)msg;

/**
    关闭所有app,包括默认应用
    此方法在xFace即将被终止前调用
 */
- (void) closeAllApps;

@end
