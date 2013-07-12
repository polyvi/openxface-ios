
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
//  XBatteryExt_Privates.h
//  xFaceLib
//
//

#ifdef __XBatteryExt__

#import "XBatteryExt.h"

@interface XBatteryExt ()

@property (nonatomic) UIDeviceBatteryState state;               /**< 电池状态 */
@property (nonatomic) float level;                              /**< 电量值 */
@property (nonatomic) BOOL isPlugged;                           /**< 是否接驳了电源 */
@property (nonatomic, strong) NSMutableSet *registeredApps;  /**< 注册管理多个js callback */

/**
    更新电池的状态.
    实现了Notification Center的观察者方法.
    @param notification
 */
- (void) updateBatteryStatus:(NSNotification*)notification;

/**
    获得电池信息.
    @return 返回当前电池状态和电量
 */
- (NSDictionary*) getBatteryStatus;

@end

#endif
