
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
//  XAmsExt.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XExtension.h"

@protocol XAms;

@class XMessenger;
@class XJavaScriptEvaluator;

/**
	AMS扩展，用于提供通过脚本对应用进行管理的功能
 */
@interface XAmsExt : XExtension
{
    NSObject<XAms>           *ams;           /**< 应用管理的真正实现者 */
    XMessenger               *messenger;     /**< 用于发送消息给 message handler */
}

/**
	初始化方法
	@param amsObj       提供给扩展使用的应用管理器对象
	@param msger        用于发送消息给handler
	@param msgHandler   消息处理者
	@returns 初始化后的ams扩展对象，如果初始化失败，则返回nil
 */
- (id) init:(id<XAms>)amsObj withMessenger:(XMessenger *)msger withMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
	安装一个应用
	@param arguments
		- 0 XJsCallback* callback  js回调对象
		- 1 NSString* packpagePath 相对于当前应用工作空间的应用安装包路径
	@param options 可选参数
 */
- (void) installApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	更新一个应用
	@param arguments 参数列表
		- 0 XJsCallback* callback  js回调对象
		- 1 NSString* packpagePath 相对于当前应用工作空间的应用更新包路径
	@param options 可选参数
 */
- (void) updateApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	卸载一个应用
	@param arguments 参数列表
		- 0 XJsCallback* callback  js回调对象
		- 1 NSString* appId        用于标识待卸载应用的id
	@param options 可选参数
 */
- (void) uninstallApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	启动一个应用
	@param arguments 参数列表
		- 0 XJsCallback* callback  js回调对象
		- 1 NSString* appId        用于标识待启动应用的id
	@param options 可选参数
 */
- (void) startApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
	获取已安装的应用.
	获取到的应用不包括默认应用.
	@param arguments 参数列表
		- 0 XJsCallback* callback  js回调对象
	@param options 可选参数
 */
- (void) listInstalledApplications:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    列出默认应用可以使用的所有应用预置包
    列表中每一项为一个应用包的相对路径，这些应用包位于默认应用工作目录的pre_set目录下
    @param arguments 参数列表
        - 0 XJsCallback* callback  js回调对象
    @param options 可选参数（没有使用）
 */
- (void) listPresetAppPackages:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

/**
    获取默认应用的描述信息
    @params arguments 参数列表
        - 0 XJsCallback* callback js回调对象
    @param options 可选参数（没有使用）
 */
- (void) getStartAppInfo:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

@end

