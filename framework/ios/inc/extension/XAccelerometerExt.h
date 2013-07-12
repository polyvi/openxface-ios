
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
//  XAccelerometerExt.h
//  xFaceLib
//
//

#ifdef __XAccelerometerExt__

#import <UIKit/UIKit.h>
#import "XExtension.h"

@interface XAccelerometerExt : XExtension<UIAccelerometerDelegate>
{
    double x;
    double y;
    double z;
    NSTimeInterval timestamp;
}

/**
    初始化方法
    @param msgHandler 消息处理者
    @returns 初始化后的accelerometer扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
    启动加速度感应功能
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 id<XApplication> 启动监控的app
    @param options 可选参数
 */
- (void)start:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    停止加速度感应功能
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 id<XApplication> 发出停止请求的app
    @param options 可选参数
 */
- (void)stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
