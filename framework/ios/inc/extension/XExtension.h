
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
//  XExtension.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VERIFY_ARGUMENTS(args, expectedCount, callback) if (![self verifyArguments:args \
    withExpectedCount:expectedCount andCallback:callback callerFileName:__FILE__ \
    callerFunctionName:__PRETTY_FUNCTION__]) { return; }

@protocol XApplication;

@class XJavaScriptEvaluator;
@class XJsCallback;

/**
	为扩展定义公共接口
 */
@interface XExtension : NSObject
{
    XJavaScriptEvaluator     *jsEvaluator;   /**< 负责执行js语句 */
}

/**
 xFace 的rootViewController
 */
@property (nonatomic, weak) UIViewController* viewController;

/**
	初始化扩展.
	@param msgHandler 扩展执行结果的消息处理器
	@returns 返回self
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
	发送异步执行结果给消息处理器.
	@param callback 异步执行的回调对象
 */
- (void) sendAsyncResult:(XJsCallback *)callback;

/**
	是否在后台线程执行扩展方法
	@param fullMethodName 待执行的扩展方法
	@returns 在后台线程执行扩展方法，返回YES,否则返回NO
 */
- (BOOL) shouldExecuteInBackground:(NSString *)fullMethodName;

/**
	验证扩展命令的参数有效性.
    若参数个数验证失败，会调用error callback或写入NSLog，反之，返回True.
	@param args 不包含callbackId的参数数组
	@param expectedCount 期望的参数个数
	@param callback js回调对象
	@param callerFileName 执行扩展命令的调用文件名称
	@param callerFunctionName 执行扩展命令的调用函数名称
	@returns 验证成功或者失败
 */
- (BOOL) verifyArguments:(NSMutableArray*)args withExpectedCount:(NSUInteger)expectedCount
           andCallback:(XJsCallback*)callback callerFileName:(const char*)callerFileName
           callerFunctionName:(const char*)callerFunctionName;

/**
    app退出时的处理函数
    @appId 当前app的id
 */
- (void) onAppClosed:(NSString *)appId;

/**
    页面切换的处理函数
    @appId 当前app的id
 */
- (void) onPageStarted:(NSString*)appId;

/**
    从options中获取applications对象
    @return aplication对象，如果不存在返回nil
 */
- (id<XApplication>) getApplication:(NSDictionary *)options;

/**
    从options中获取JsCallback对象
    @return JsCallback对象，如果不存在返回nil
 */
- (XJsCallback *) getJsCallback:(NSDictionary *)options;

@end
