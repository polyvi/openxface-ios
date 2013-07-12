
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
//  XExtensionResult.h
//  xFace
//
//

#import <Foundation/Foundation.h>

/**
	执行结果状态码
 */
typedef enum {
	STATUS_NO_RESULT = 0,
    STATUS_PROGRESS_CHANGING,
	STATUS_OK,
	STATUS_CLASS_NOT_FOUND_EXCEPTION,
	STATUS_ILLEGAL_ACCESS_EXCEPTION,
	STATUS_INSTANTIATION_EXCEPTION,
	STATUS_MALFORMED_URL_EXCEPTION,
	STATUS_IO_EXCEPTION,
	STATUS_INVALID_ACTION,
	STATUS_JSON_EXCEPTION,
	STATUS_ERROR
} STATUS;

/**
	此类用于封装扩展执行结果.
 */
@interface XExtensionResult : NSObject
{
	NSNumber *status;        /**< 执行结果状态码 */
	id        message;       /**< 执行结果返回值 */
	BOOL      keepCallback;  /**< 是否在js端保留回调函数 */
}

@property (nonatomic, strong, readonly) NSNumber *status;
@property (nonatomic, strong, readonly) id        message;
@property BOOL keepCallback;

/**
	根据参数构造一个XExtensionResult对象
	@param status 执行结果状态码
 */
+ (XExtensionResult *) resultWithStatus:(STATUS)status;

/**
	根据参数构造一个XExtensionResult对象
	@param status      执行结果状态码
	@param theMessage 执行结果返回值
 */
+ (XExtensionResult *) resultWithStatus:(STATUS)status messageAsObject:(id)theMessage;

/**
	根据参数构造一个XExtensionResult对象
	@param status     执行结果状态码
	@param theMessage 执行结果返回值
 */
+ (XExtensionResult *) resultWithStatus:(STATUS)status messageAsInt:(int)theMessage;

/**
	根据参数构造一个XExtensionResult对象
	@param status     执行结果状态码
	@param theMessage 执行结果返回值
 */
+ (XExtensionResult *) resultWithStatus:(STATUS)status messageAsDouble:(double)theMessage;

/**
  根据参数构造一个XExtensionResult对象
  @param status     执行结果状态码
  @param errorCode  执行结果错误码值
 */
+ (XExtensionResult *) resultWithStatus:(STATUS)status messageToErrorObject: (int) errorCode;

/**
    获取用于通知js端操作执行的js语句
    @param callbackId 回调函数对应的id
	@returns 可执行的js语句
 */
- (NSString *) toCallbackString:(NSString *)callbackI;

@end
