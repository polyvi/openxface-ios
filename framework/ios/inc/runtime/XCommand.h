
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
//  XCommand.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@interface XCommand : NSObject
{
	NSString* callbackId;     /**< 回调id */
	NSString* className;      /**< 扩展类名 */
	NSString* methodName;     /**< 扩展接口名 */
	NSArray*  arguments;      /**< 执行扩展接口需要的参数 */
}

@property(nonatomic, readonly) NSArray*  arguments;
@property(nonatomic, readonly) NSString* callbackId;
@property(nonatomic, readonly) NSString* className;
@property(nonatomic, readonly) NSString* methodName;

/**
    初始化XCommand对象
    @param jsonEntry 存有callback id等信息的数组，用于初始化XCommand对象
    @returns 初始化后的XCommand对象
 */
+ (XCommand*)commandFromJson:(NSArray*)jsonEntry;

/**
    初始化XCommand对象
    @param args 执行扩展接口需要的参数
    @param cbId 回调id
    @param extClassName 扩展类名
    @param extMethodName 扩展接口名
    @returns 初始化后的XCommand对象
 */
- (id)initWithArguments:(NSArray*)args
             callbackId:(NSString*)cbId
              className:(NSString*)extClassName
             methodName:(NSString*)extMethodName;

/**
    根据jsonEntry中的信息初始化XCommand对象
	@param jsonEntry 存有callback id等信息的数组，用于初始化XCommand对象
	@returns 初始化后的XCommand对象
 */
- (id)initFromJson:(NSArray*)jsonEntry;

@end
