
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
//  XBatteryExt.h
//  xFace
//
//

#ifdef __XBatteryExt__

#import "XExtension.h"

@interface XBatteryExt : XExtension

/**
	初始化方法
	@param msgHandler 消息处理者
	@returns 初始化后的file扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
    启动电池监控.
    @param arguments 参数列表
        - 0 callback js回调对象
        - 1 app 启动监控的app
    @param options 可选参数列表(本接口中未使用)
 */
- (void) start:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

/**
    停止电池监控.
    @param arguments 参数列表(本接口中未使用)
        - 0 callback js回调对象
        - 1 app 发出停止请求的app
    @param options 可选参数列表(本接口中未使用)
 */
- (void) stop:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

@end

#endif
