
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
//  XJsCallback.m
//  xFaceLib
//
//

#import "NSObject+JSONSerialization.h"
#import "XJsCallback.h"
#import "XApplication.h"

#define INVALID_CALLBACK_ID    @"INVALID"

@implementation XJsCallback

@synthesize callbackId;
@synthesize callbackKey;

- (id)initWithCallbackId:(NSString *)aCallbackId withCallbackKey:(NSString *)key
{
    self = [super init];
    if(self)
    {
        self->callbackId = aCallbackId;
        self->callbackKey = key;
    }
    return self;
}

- (void)setJsScript:(NSString *)script
{
    self->jsScript = script;
}

- (void)setExtensionResult:(XExtensionResult *)result
{
    self->extensionResult = result;
}

- (NSString *)genCallbackScript
{
    NSString* script = nil;
    if(self->extensionResult)
    {
        NSAssert(nil != self->callbackId, nil);

        // 没有指定回调函数时，无需向js端发送扩展执行结果
        if ([callbackId isEqualToString:INVALID_CALLBACK_ID])
        {
            return script;
        }
        
        int status = [self->extensionResult.status intValue];
        BOOL keepCallback = [self->extensionResult keepCallback];
        id message = self->extensionResult.message == nil ? [NSNull null] : self->extensionResult.message;

        // Use an array to encode the message as JSON.
        message = [NSArray arrayWithObject:message];
        NSString* encodedMessage = [message JSONString];
        // And then strip off the outer []s.
        encodedMessage = [encodedMessage substringWithRange:NSMakeRange(1, [encodedMessage length] - 2)];
        script = [NSString stringWithFormat:@"xFace.require('xFace/exec').nativeCallback('%@',%d,%@,%d)",
                            callbackId, status, encodedMessage, keepCallback];

        self->extensionResult = nil;
    }
    else
    {
        NSAssert([self->jsScript length] > 0, nil);
        script = [NSString stringWithFormat:@"xFace.require('xFace/exec').nativeEvalAndFetch(function(){%@})", self->jsScript];
    }

    XLogI(@"[%@] Callback js: %@", NSStringFromSelector(_cmd), script);
    return script;
}

- (BOOL)isValid:(id<XApplication>)app
{
    // 不需要通过callbackId来执行回调，所以不受页面切换的限制
    if(nil == callbackId)
    {
        return YES;
    }
    NSSet *callbackSet = [app getCallbackSet:self->callbackKey];
    return [callbackSet containsObject:self];
}

@end
