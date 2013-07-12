
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
//  XRuntime_Privates.h
//  xFaceLib
//
//

#import "XRuntime.h"

@class XRootViewController;
@class XExtensionManager;
@class XAppManagement;
@class XMessenger;
@class XJavaScriptEvaluator;
@class XSystemBootstrap;
@class XAppUpdater;
@class XSystemEventHandler;
@class XAnalyzer;

@interface XRuntime ()

/**
	应用管理器.
 */
@property (strong, nonatomic) XAppManagement *appManagement;

/**
	负责资源部署，安装预置应用, 启动系统等.
 */
@property (strong, nonatomic) id <XSystemBootstrap> systemBootstrap;

/**
    负责处理系统事件，如resume, pause等
 */
@property (strong, nonatomic) XSystemEventHandler *sysEventHandler;

/**
    负责检测是否存在新版本的app.
    @note XAppUpdater有UIAlertViewDelegate，不能是局部变量，否则UIAlertView弹出之后，
          XAppUpdater是局部变量的话就被回收了（执行dealloc），再点击UIAlertView的按钮，
          触发UIAlertViewDelegate，就引起崩溃。
 */
@property (strong, nonatomic) XAppUpdater *appUpdater;

/**
    启动参数
 */
@property (strong, readwrite, nonatomic) NSString *bootParams;

/**
    负责初始化第三方数据统计工具，以及通过监听event实现event,screen统计功能
 */
@property (strong, nonatomic) XAnalyzer *analyzer;

/**
    关闭应用视图，并解除app与view之间的关联
    @param app 要关闭视图对应的app对象
 */
- (void) removeAppView:(id<XApplication>)app;

/**
    显示错误提示框
    @param error error具体信息
 */
- (void) showErrorAlert:(NSError *)error;

@end
