
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
//  XNotificationExt.h
//  xFaceLib
//
//

#ifdef __XNotificationExt__

#import "XExtension.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@class XJsCallback;

@interface XNotificationExt : XExtension <UIAlertViewDelegate>
{
    SystemSoundID   soundFileObject;    /**< 提示音文件对象id */
    CFURLRef        soundFileURLRef;    /**< 提示音文件url ref */
}

/**
    alert方法
    @param arguments alert方法的参数
        - 0 XJsCallback* callback
        - 1 NSString* 要弹出的消息内容
        - 2 NSString* 消息框的标题
        - 3 NSString* 消息框上的按钮内容
    @param options 可选参数
 */
- (void)alert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    confirm方法
    @param arguments confirm方法的参数
        - 0 XJsCallback* callback
        - 1 NSString* 要弹出的消息内容
        - 2 NSString* 消息框的标题
        - 3 NSString* 消息框上的按钮内容
    @param options 可选参数
 */
- (void)confirm:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    vibrate方法（设置设备的震动时间）
    @param arguments vibrate方法的参数
    @param options 可选参数
 */
- (void)vibrate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
   beep方法，播放提示音
   @param arguments 参数列表
   @param options 可选参数
 */
- (void) beep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end


@interface XAlertView : UIAlertView {
}
@property(nonatomic, strong) XJsCallback* callback;

@end

#endif
