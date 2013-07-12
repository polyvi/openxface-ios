
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
//  XNetworkConnectionExt.h
//  xFace
//
//

#ifdef __XNetworkConnectionExt__

#import "XExtension.h"

@class XJavaScriptEvaluator;

@interface XNetworkConnectionExt : XExtension

/**
	初始化方法
	@param msgHandler 消息处理者
	@returns 初始化后的file扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
	获取Connection数据
	@param arguments 参数列表
		- 0 XJsCallback* callback   js回调
	@param options 可选参数
 */
- (void) getConnectionInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
