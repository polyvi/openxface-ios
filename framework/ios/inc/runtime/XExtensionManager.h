
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
//  XExtensionManager.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XApplication.h"

@class XExtension;
@class XCommand;
@class XRootViewController;
@class XCommandQueue;

/**
    扩展管理器，程序所有js扩展的执行入口
 */
@interface XExtensionManager : NSObject
{
    __weak id<XApplication> _app;                /**< 关联的app */
}

/**
    初始化方法
    @param app 关联的app
    @returns 初始化成功返回XExtensionManager的实例对象，否则返回nil。
 */
- (id) initWithApp:(id<XApplication>)app;

/**
    负责command的获取与执行
 */
@property (nonatomic, readonly, strong) XCommandQueue* commandQueue;

/**
    向扩展管理器中添加一个扩展
    @param extension     待添加到管理器中的扩展对象
    @param extensionName 扩展名称，添加到扩展集合中时，用作key
    @returns 成功返回YES,失败返回NO
 */
- (BOOL) registerExtension:(XExtension*)extension withName:(NSString *)extensionName;

/**
    执行指定命令
    @param cmd    待执行命令
    @returns 成功返回YES，否则返回NO
    */
- (BOOL) exec:(XCommand *)cmd;

/**
    当退出app时，通知每个 ext 回调
    @param appId 当前app的id
 */
- (void) onAppClosed:(NSString *)appId;

/**
    页面切换的处理函数
    @param appId 当前app的id
 */
- (void) onPageStarted:(NSString*)appId;

@end
