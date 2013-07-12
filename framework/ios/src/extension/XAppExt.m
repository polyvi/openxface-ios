
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
//  XAppExt.m
//  xFaceLib
//
//

#ifdef __XAppExt__

#import "XAppExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XQueuedMutableArray.h"

@implementation XAppExt

- (void) openUrl:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 1, callback)

    NSString *urlStr = [arguments objectAtIndex:0];
    [self openURL:urlStr callback:callback];
}

- (void) getChannel:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    id<XApplication> app = [self getApplication:options];

    XExtensionResult *result = nil;
    if (app.appInfo.channelId.length > 0 && app.appInfo.channelName.length > 0)
    {
        NSDictionary* channel = @{@"id": app.appInfo.channelId, @"name":app.appInfo.channelName};
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:channel];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR];
    }

    [callback setExtensionResult:result];
    // 将执行结果返回给js端
    [self->jsEvaluator eval:callback];
}

- (void) startNativeApp:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    VERIFY_ARGUMENTS(arguments, 2, callback)

    NSString *appURL = [arguments objectAtIndex:0];
    NSString *parameter = [arguments objectAtIndex:1 withDefault:nil];
    NSString *url = [appURL stringByAppendingFormat:@"%@", parameter];
    [self openURL:url callback:callback];
}

#pragma mark Privates

-(void) openURL:(NSString*)urlStr callback:(XJsCallback*)callback
{
    NSURL *url = [NSURL URLWithString:urlStr];
    BOOL ret = [[UIApplication sharedApplication] canOpenURL:url] &&
           [[UIApplication sharedApplication] openURL:url];

    XExtensionResult *result = [XExtensionResult resultWithStatus:ret ? STATUS_OK : STATUS_ERROR];

    [callback setExtensionResult:result];
    // 将执行结果返回给js端
    [self->jsEvaluator eval:callback];
}

@end

#endif
