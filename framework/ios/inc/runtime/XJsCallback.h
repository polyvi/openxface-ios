
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
//  XJsCallback.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import "XExtensionResult.h"

@protocol XApplication;

/**
  js回调封装类，包含js回调id以及扩展执行结果对象
 */
@interface XJsCallback : NSObject
{
    NSString *callbackId; /**< js回调的id*/
    NSString *jsScript; /**< 回调要执行的js脚本，extensionResult为nil时，该值有效*/
    XExtensionResult *extensionResult; /**< js回调结果，可以生成回调执行的js脚本*/
    NSString *callbackKey; /**< 在XApplication中注册回调时对应的key，这里保存下来主要是为了效率考虑*/
}

@property(readonly) NSString *callbackId;

@property(readonly) NSString *callbackKey;

/**
  初始化方法
  @param aCallbackId js回调id
  @param key 在XApplication中注册该回调时的key，这里保存下来主要是为了效率考虑
 */
- (id)initWithCallbackId:(NSString *)aCallbackId withCallbackKey:(NSString *)key;

/**
  设置js回调时要执行的script语句
  在某些场景下，扩展需要通过执行特殊的js语句来完成回调功能
  则直接调用该方法设置js语句，而不是设置XExtensionResult对象
  @param script js回调对应的script
 */
- (void)setJsScript:(NSString *)script;

/**
  设置扩展执行结果对象，生成js回调script语句会用到该对象
  @param result 扩展执行结果对象
 */
- (void)setExtensionResult:(XExtensionResult *)result;

/**
  生成js回调所用到的script语句
 */
- (NSString *)genCallbackScript;

/**
  判断该回调在一个应用中是否有效
  一个回调只能在一个应用中使用，并保持有效状态，在该应用发生了页面切换之后，
  该回调失效，不能再继续使用
  @param app 回调所在的应用
 */
- (BOOL)isValid:(id<XApplication>)app;
@end
