
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
//  XJavaScriptEvaluator.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@class XAppList;
@class XJsCallback;
@class XCommandQueue;
@class XCommand;
@protocol XApplication;

/**
    负责执行js语句
 */
@interface XJavaScriptEvaluator : NSObject
{
    __weak id<XApplication> _app;  /**< 关联的app */
}

/**
    初始化方法
    @param app 关联的app
    @returns 成功返回XJavaScriptEvaluator对象，否则返回nil
 */
- (id) initWithApp:(id<XApplication>)app;

/**
    执行js回调
    @param jsCallback 要执行的js回调对象
 */
- (void) eval:(XJsCallback *)jsCallback;

@end
