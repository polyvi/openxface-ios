
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
//  XMessenger.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@class XJavaScriptEvaluator;
@class XJsCallback;

/**
	负责将执行扩展过程中产生的消息发送给目标handler
 */
@interface XMessenger : NSObject
{
}

/**
	异步发送扩展执行结果到目标handler
	@param jsCallback 待处理的js回调对象，包含扩展执行结果
	@param msgHandler 处理消息的目标handler
 */
- (void) sendAsyncResult:(XJsCallback *)jsCallback toMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
    同步发送扩展执行结果到目标handler
    @param jsCallback 待处理的js回调对象，包含扩展执行结果
    @param msgHandler 处理消息的目标handler
 */
- (void) sendSyncResult:(XJsCallback *)jsCallback toMsgHandler:(XJavaScriptEvaluator *)msgHandler;

@end
