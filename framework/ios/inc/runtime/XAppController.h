
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
//  XAppController.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

@protocol XApplication;

/**
 扩展管理器，程序所有js扩展的执行入口
 */
@interface XAppController : NSObject <UIWebViewDelegate>
{
    __weak id<XApplication> _app;                /**< 关联的app */
    BOOL                    _loadFromString;     /**< 通过设置页面内容的方式加载webview */
}

/**
    初始化方法
    @param app 关联的app
    @returns 初始化成功返回XAppController的实例对象，否则返回nil。
 */
- (id) initWithApp:(id<XApplication>)app;

/*
    处理ajax请求
    @param request 需要处理的ajax请求.
    @returns 如果需要自行处理指定的请求就返回YES，否则返回NO.
 */
- (BOOL)canInitWithRequest:(NSURLRequest *)theRequest;

/**
    根据请求确定是否允许加载指定webview
    @param theWebView 待加载的webview
    @param request 用于指定content location的请求
    @returns 允许webview加载，返回YES,否则返回NO
 */
- (BOOL) shouldStartLoadWebView:(UIWebView *)theWebView withRequest:(NSURLRequest *)request;

@end