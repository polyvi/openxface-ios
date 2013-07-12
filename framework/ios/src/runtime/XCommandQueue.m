
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
//  XCommandQueue.m
//  xFaceLib
//
//

#import "NSObject+JSONSerialization.h"
#import "XCommandQueue.h"
#import "XRootViewController.h"
#import "XCommand.h"
#import "XAppView.h"
#import "XExtensionManager.h"
#import "XCommandQueue_Privates.h"

#define MAX_LOG_LENGTH   1024

@implementation XCommandQueue

@synthesize currentlyExecuting;

- (id)initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self != nil) {
        self->_app = app;
        self->queue = [[NSMutableArray alloc] init];
        self->currentlyExecuting = NO;
    }
    return self;
}

- (void)dispose
{
    self->_app = nil;
}

- (void)enqueAndTryExecCommandBatch:(NSString*)batchJSON
{
    if ([batchJSON length] > 0)
    {
        [self->queue addObject:batchJSON];
        [self executePending];
    }
}

- (void)tryFlushCommandsFromJs:(NSNumber *)requestId
{
    // 由于同一个request会被尝试flush多次，所以需要通过request ID来判定当前request是否已经被flush过

    BOOL flushed = [self isRequestFlushed:[requestId integerValue]];
    if (!flushed)
    {
        self->lastFlushedRequestId = [requestId integerValue];
        [self flushCommandsFromJs];
    }
}

- (void)flushCommandsFromJs
{
    // 获取js端队列中所有的commands.
    UIWebView* webView = (UIWebView*)[_app appView];
    NSString* queuedCommandsJSON = [webView stringByEvaluatingJavaScriptFromString:
                                    @"xFace.require('xFace/exec').nativeFetchMessages()"];

    [self enqueAndTryExecCommandBatch:queuedCommandsJSON];
}

#pragma mark Privates

- (void)executePending
{
    if (self->currentlyExecuting)
    {
        return;
    }
    @try
    {
        self->currentlyExecuting = YES;

        for (NSUInteger i = 0; i < [self->queue count]; ++i)
        {
            NSString *value = [self->queue objectAtIndex:i];

            // 解析JSON array.
            NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* commandBatch = [data mutableObjectFromJSONString];

            // 遍历commandBatch并执行所有的commands.
            for (NSArray* jsonEntry in commandBatch)
            {
                XCommand* command = [XCommand commandFromJson:jsonEntry];

                if (![self execute:command])
                {
#ifdef DEBUG
                    NSString* commandJson = [jsonEntry JSONString];
                    static NSUInteger maxLogLength = MAX_LOG_LENGTH;
                    NSString* commandString = ([commandJson length] > maxLogLength) ?
                    [NSString stringWithFormat:@"%@[...]", [commandJson substringToIndex:maxLogLength]] :
                    commandJson;

                    XLogE(@"FAILED extensionJSON = %@", commandString);
#endif
                }
            }
        }

        [self->queue removeAllObjects];
    }
    @finally
    {
        self->currentlyExecuting = NO;
    }
}

- (BOOL)execute:(XCommand*)command
{
    BOOL ret = [_app.extMgr exec:command];
    return ret;
}

- (BOOL)isRequestFlushed:(NSInteger)requestId
{
    BOOL ret = (requestId <= lastFlushedRequestId);
    return ret;
}

- (void)clearJsCommandQueue
{
    UIWebView* webView = (UIWebView*)[_app appView];
    [webView stringByEvaluatingJavaScriptFromString:@"xFace.require('xFace/exec').nativeFetchMessages()"];
    lastFlushedRequestId = 0;
}

@end
