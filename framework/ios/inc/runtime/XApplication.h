
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XApplication.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XAppRunningMode.h"

@protocol XAppView;

@class XAppInfo;
@class XJsCallback;
@class XWhitelist;
@class XExtensionManager;
@class XJavaScriptEvaluator;
@class XAppController;

/**
    用于描述一个应用，是XNativeApplication与XWebXApplication的基类
 */
@protocol XApplication <NSObject>

@required

/**
	初始化方法
	@param applicationInfo 应用配置信息
	@returns 成功返回XApplication对象，否则返回nil
 */
- (id) initWithAppInfo:(XAppInfo *)applicationInfo;

/**
    与app关联的配置信息
 */
@property (strong, nonatomic) XAppInfo *appInfo;

/**
    与app关联的view
 */
@property (strong, nonatomic) id<XAppView> appView;

/**
    用于确定当前app的网络访问权限
 */
@property (strong, readonly, nonatomic) XWhitelist *whitelist;

/**
    获取app id
    @returns 获取到的app id
 */
- (NSString *) getAppId;

/**
    判断app是否已安装
    @returns web app始终返回YES,native app根据canOpenUrl接口判断是否已安装
 */
- (BOOL) isInstalled;

/**
    判断app是否为native application
    @returns native application返回YES, web application返回NO
 */
- (BOOL) isNative;

@optional

/**
    加载应用
    只有加载web app时才会调用此接口，用于加载web应用到app view上显示
    @returns 操作执行成功返回YES,否则返回NO
 */
- (BOOL) load;

/**
    加载应用
    只有加载native app时才会调用此接口：如果native app对应的ipa包已安装，则直接启动native app，否则展示ipa包安装界面
    @param params 应用启动参数
    @returns 操作执行成功返回YES,否则返回NO
 */
- (BOOL) loadWithParameters:(NSString *)params;

/**
    获取应用安装目录所在绝对路径
    路径形如：~/Documents/xface3/apps/appId
    @returns 应用安装目录所在绝对路径
 */
- (NSString *) installedDirectory;

/**
	获取app的工作空间.
	当app的工作空间不存在时，将为其创建相应的工作空间.
	@returns app的工作空间
 */
- (NSString *) getWorkspace;

/**
    获取应用程序存放数据的目录.
    若不存在则创建，应用对该目录没有写权限.
    @returns app存放数据的目录
 */
- (NSString *) getDataDir;

/**
    向app注册扩展方法及其关联的callback对象，一个key可以对应一个或多个callback对象.
    @param key 以"<扩展名>_<方法名>"为key(XUtils有相应的工具方法生成)
    @param callback js回调对象
 */
- (void) registerJsCallback:(NSString *)key withCallback:(XJsCallback *)callback;

/**
    向app注消一个扩展方法对应的所有js回调.
    @param key 以"<扩展名>_<方法名>"为key(XUtils有相应的工具方法生成)
 */
- (void) unregisterJsCallback:(NSString *)key;

/**
    通过扩展key获得与之关联的callback列表
    @param key 以"<扩展名>_<方法名>"为key(XUtils有相应的工具方法生成)
    @return 关联的所有callback对象
*/
- (NSSet *) getCallbackSet:(NSString *)key;

/**
    清除该应用所有的js回调
 */
- (void) clearJsCallbacks;

/**
	判断当前应用是否处于活动状态.
	@returns 处于活动状态返回YES，否则返回NO
 */
- (BOOL) isActive;

/**
    设置app通讯数据
    @param value 通讯数据的值
    @param key   标识通讯数据的key
 */
- (void) setData:(id)value forKey:(NSString *)key;

/**
    移除指定的通讯数据
    @param key 标识通讯数据的key
 */
- (void) removeDataForKey:(NSString *)key;

/**
    获取指定的通讯数据
    @param key 标识通讯数据的key
    @returns 获取到的通讯数据
 */
- (id) getDataForKey:(NSString *)key;

/**
    获取应用对应的运行模式
 */
- (RUNNING_MODE) getRunningMode;

/**
    获取应用对应的URL
 */
- (NSURL*) getURL;

/**
    获取应用的图标URL
 */
- (NSString*) getIconURL;

/**
    获取应用的资源迭代器
 */
- (id) getResourceIterator;

/**
    负责扩展的管理
 */
@property (strong, nonatomic) XExtensionManager* extMgr;

/**
    负责执行js语句.
 */
@property (strong, nonatomic) XJavaScriptEvaluator* jsEvaluator;

/**
    app关联的controller.
 */
@property (strong, nonatomic) XAppController* appController;

@end
