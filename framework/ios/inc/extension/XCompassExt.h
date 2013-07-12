
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
//  XCompassExt.h
//  xFaceLib
//
//

#ifdef __XCompassExt__

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "XExtension.h"

enum HeadingStatus
{
    HEADING_STOPPED = 0,
    HEADING_STARTING,
    HEADING_RUNNING,
    HEADING_ERROR
};
typedef NSUInteger HeadingStatus;

enum CompassError
{
    COMPASS_INTERNAL_ERR    = 0,
    COMPASS_NOT_SUPPORTED   = 20
};
typedef NSUInteger CompassError;

@class XHeadingData;

@interface XCompassExt : XExtension<CLLocationManagerDelegate>
{

}

/**
 初始化方法
 @param msgHandler 消息处理者
 @returns 初始化后的XCompassExt扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
 获取Compass Heading信息
 @param arguments 参数列表
 - 0 XJsCallback* callback
 @param options 可选参数 可选 filter一种
 - 0 filter Heading信息的更新频率
 */
- (void)getHeading:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
 以固定的频率，获取Compass Heading更新信息
 @param arguments 参数列表
 - 0 XJsCallback* callback
 @param options 可选参数 有filter和frequency
 - 0 filter Heading信息的过滤
 - 1 frequency Heading信息的更新频率
 */
- (void)watchHeadingFilter:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
 停止 获取Compass Heading信息
 @param arguments 参数列表 (本接口中未使用)
 @param options 可选参数 (本接口中未使用)
 */
- (void)stopHeading:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
