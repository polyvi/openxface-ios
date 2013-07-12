
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
//  XSystemEventHandler.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

@class XAppManagement;

/**
    用于处理系统相关的事件
 */
@interface XSystemEventHandler : NSObject
{
    XAppManagement       *appManagement;         /**<应用管理器*/
    float                 oldVolume;             /**<保存按下音量键前的音量值 */
}

/**
    初始化方法
    @param applicationManagement 应用管理器
    @returns 成功时返回XSystemEventHandler对象，失败时返回nil
 */
- (id) initWithAppManagement:(XAppManagement *)applicationManagement;

/**
    收到UIApplication将要被终止的通知
    @param notification 携带通知相关数据的对象
 */
- (void)appWillTerminate:(NSNotification*)notification;

/**
    收到UIApplication将要进入前台的通知
    @param notification 携带通知相关数据的对象
 */
- (void)appWillEnterForeground:(NSNotification*)notification;

/**
    收到UIApplication已经进入后台的通知
    @param notification 携带通知相关数据的对象
 */
- (void)appDidEnterBackground:(NSNotification*)notification;

/**
    收到UIApplication将要进入inactive状态的通知
    @param notification 携带通知相关数据的对象
 */
- (void)appWillResignActive:(NSNotification*)notification;

/**
    收到UIApplication已经进入active状态的通知
    @param notification 携带通知相关数据的对象
 */
- (void)appDidBecomeActive:(NSNotification*)notification;

/**
    收到音量发生变化的通知
    @param notification 携带通知相关数据的对象
 */
- (void)volumeDidChange:(NSNotification*)notification;

@end
