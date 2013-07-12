
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
//  XCompassExt_Privates.h
//  xFaceLib
//
//

#ifdef __XCompassExt__

#import "XCompassExt.h"

@interface XCompassExt ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong) XHeadingData* headingData;

/**
 是否有电子罗盘
 @returns 如果有电子罗盘返回YES，否则返回NO
 */
- (BOOL) hasHeadingSupport;

/**
 返回compass Heading信息到js端
 @param arguments 参数列表
 - 0 XJsCallback* callback 回调
 @param (BOOL) theRetain 是否通知
 */
- (void)returnHeadingInfo: (XJsCallback*) callback keepCallback: (BOOL) theRetain;

/**
 使用一个固定更新频率启动电子罗盘
 @param (CLLocationDegrees) filter
 */
- (void) startHeadingWithFilter: (CLLocationDegrees) filter;

/**
 获取Heading信息成功的系统框架回调
 @param (CLLocationManager *)manager CLLocationManager的对象
 @param (CLHeading *)heading CLHeading的对象，包含Heading信息
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading;

/**
 获取Heading信息失败的系统框架回调
 @param (CLLocationManager *)manager CLLocationManager的对象
 @param (NSError *)error CLHeading的对象，包含Heading信息
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

#endif
