
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
//  XNetworkConnectionExt_Privates.h
//  xFaceLib
//
//

#ifdef __XNetworkConnectionExt__

#import "XNetworkConnectionExt.h"

@class XNetworkReachability;

@interface XNetworkConnectionExt ()

/**
    当前的网络连接类型
 */
@property (strong, nonatomic) NSString *connectionType;

/**
    负责监听网络状态
 */
@property (strong, nonatomic) XNetworkReachability *internetReach;

/**
    负责管理注册了js回调的app
 */
@property (nonatomic, strong) NSMutableSet *registeredApps;

/**
    根据reachability获取网络连接类型
    @param reachability 用于获取网络连接类型
    @returns 获取到的网络类型："none" "2g" "wifi"
 */
- (NSString*) getConnectionType:(XNetworkReachability*)reachability;

/**
    更新Reachability.
    当connection类型改变时，通知js端，并由js端触发online offline事件
    @param reachability 当前的Network Reachability，用于获取网络连接类型
 */
- (void) updateReachability:(XNetworkReachability*)reachability;

/**
    更新网络连接类型
    @param notification 用于获取Network Reachability对象
 */
- (void) updateConnectionType:(NSNotification*)notification;

/**
    负责准备工作：初始化internetReach，开始监听网络状态等
 */
- (void) prepare;

@end

#endif
