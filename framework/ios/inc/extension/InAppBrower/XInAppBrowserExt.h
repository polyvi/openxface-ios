
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
//  XInAppBrowserExt.h
//  xFace
//
//

#ifdef __XInAppBrowserExt__

#import "XExtension.h"

@class XBrowserViewController;

//浏览器事件
@protocol XInAppBrowserNavigationDelegate <NSObject>

/**
    准备加载事件
    @param url 网页地址
    @param app 拥有该浏览器的app对象
    @param jsCallback js回调对象
 */
- (void)browserLoadStart:(NSURL*)url app:(id<XApplication>)app callback:(XJsCallback*)jsCallbackb;

/**
    完成加载事件
    @param url 网页地址
    @param app 拥有该浏览器的app对象
    @param jsCallback js回调对象
 */
- (void)browserLoadStop:(NSURL*)url app:(id<XApplication>)app callback:(XJsCallback*)jsCallbackb;

/**
    关闭事件
    @param app 拥有该浏览器的app对象
    @param jsCallback js回调对象
 */
- (void)browserExitWithApp:(id<XApplication>)app callback:(XJsCallback*)jsCallback;

@end


/*
   内置浏览器扩展
 */
@interface XInAppBrowserExt : XExtension <XInAppBrowserNavigationDelegate>
{
    NSMutableDictionary* browserViewControllers;  /*< 在多app环境中，每个app拥有一个浏览器控制器*/
}

/**
   打开网页
   @param arguments
   - 0 url        要打开的url地址
   - 1 target     在何处打开url
   - 2 jsoptions  特性列表
   @param options 可选参数
 */
- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
   关闭浏览器
   @param arguments 无参数
   @param options 可选参数
 */
- (void)close:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
