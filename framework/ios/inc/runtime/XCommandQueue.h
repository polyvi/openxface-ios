
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
//  XCommandQueue.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class XCommand;
@protocol XApplication;


@interface XCommandQueue : NSObject
{
@private
    NSMutableArray* queue;                                /**< 用于存储待执行命令的数组 */
    BOOL currentlyExecuting;                              /**< 用于标识当前是否正在执行command */
    NSInteger lastFlushedRequestId;                       /**< 用于标识与关联的WebView对应的上一次被flush的Request Id */
    __weak id<XApplication>   _app;                   /**< 用于执行js */

}

@property (nonatomic, readonly) BOOL currentlyExecuting;

/**
    初始化操作
    @param app 关联的app
    @returns 初始化后的对象
 */
- (id)initWithApp:(id<XApplication>)app;

/**
    执行清理操作
 */
- (void)dispose;

/**
    添加batchJSON到queue中,并尝试执行相应的command
    @param batchJSON 待添加到queue中的command batch
 */
- (void)enqueAndTryExecCommandBatch:(NSString*)batchJSON;


/**
    尝试获取并执行JS端commands
    @param requestId 请求id
 */
- (void)tryFlushCommandsFromJs:(NSNumber *)requestId;

/**
    获取并执行JS端commands
 */
- (void)flushCommandsFromJs;

/**
     清除js框架（xface.js）中command queue中缓存的扩展命令
     提供该方法的目的主要是在页面切换清除回调时调用。
 */
- (void) clearJsCommandQueue;

@end
