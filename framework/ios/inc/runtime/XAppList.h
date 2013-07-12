
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
//  XAppList.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@protocol XAppView;
@protocol XApplication;

/**
	对已安装应用列表进行封装
 */
@interface XAppList : NSObject
{
    NSMutableArray *appCollection;      /**< 所有已安装应用列表 */
}

/**
	用于标识默认应用的id
 */
@property (strong, readonly) NSString *defaultAppId;

/**
	初始化方法
	@returns 成功返回XAppList对象，否则返回nil
 */
- (id) init;

/**
	在已安装应用列表中添加一个应用
	@param app 待添加到列表中的应用
 */
- (void) add:(id<XApplication>)app;

/**
	根据app id获取对应的应用
	@param appId 用于获取应用的app id
	@returns 根据app id获取到的应用，如果获取失败，则返回nil
 */
- (id<XApplication>) getAppById:(NSString *)appId;

/**
	判断已安装应用列表中是否存在指定的app
	@param appId 待检查应用对应的id
	@returns 如果已安装列表中已经存在指定应用，则返回YES,否则返回NO
 */
- (BOOL) containsApp:(NSString *)appId;

/**
	在已安装应用列表中移除指定的应用
	@param appId 与待移除应用对应的id
 */
- (void) removeAppById:(NSString *)appId;

/**
	将指定appId标记为默认应用对应的id
	@param appId 待用于标识默认应用的app id
 */
- (void) markAsDefaultApp:(NSString *)appId;

/**
	获取默认应用
	@returns 获取到的默认应用,如果默认应用还未设置，则返回nil
 */
- (id<XApplication>) getDefaultApp;

/**
	获取用于迭代已安装应用列表的迭代器
	@returns 迭代器
 */
- (NSEnumerator *)getEnumerator;

@end
