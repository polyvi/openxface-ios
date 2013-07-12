
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  XIdleWatcherExt.m
//  xFaceLib
//
//
#ifdef __XIdleWatcherExt__

#import "XIdleWatcherExt.h"
#import "XExtensionResult.h"
#import "XJsCallback.h"
#import "XJavaScriptEvaluator.h"
#import "XConstants.h"
#import "XApplication.h"
#import "XQueuedMutableArray.h"
#import "XUtils.h"

#define DEFAULT_TIMEOUT_INTERVAL    @(300)

//FIXME:有多个app时，每个app的超时时间不是独自的超时时间，而是最后调用该扩展的app的超时时间

@implementation XIdleWatcherExt

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeout:)
                                                     name:XUIAPPLICATION_TIMEOUT_NOTIFICATION object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSNumber *timeout = [arguments objectAtIndex:0 withDefault:DEFAULT_TIMEOUT_INTERVAL];
    XExtensionResult* result;
    if ([timeout intValue] <= 0) {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR];
        [result setKeepCallback:NO];
    } else {
        self->registeredApp = [self getApplication:options];
        result = [XExtensionResult resultWithStatus:STATUS_OK];
        [result setKeepCallback:YES];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UPDATE_TIMEOUT_INTERVAL_NOTIFICATION object:nil userInfo:@{@"timeout": timeout}]];
    }
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (void)stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self->registeredApp == nil) {
        return;
    }

    NSString *callbackKey = [self getCallbackKey];
    [self->registeredApp unregisterJsCallback:callbackKey];

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:UPDATE_TIMEOUT_INTERVAL_NOTIFICATION object:nil userInfo:@{@"timeout": @(0)}]];
    self->registeredApp = nil;
}

-(void)timeout:(NSNotification*)notification
{
    if (self->registeredApp == nil) {
        return;
    }

    NSString *callbackKey = [self getCallbackKey];
    XExtensionResult *result = nil;
    XJsCallback *callback = nil;
    NSDictionary* dict = @{@"type":@"timeout"};

    result = [XExtensionResult resultWithStatus:STATUS_PROGRESS_CHANGING
                                messageAsObject:dict];
    NSSet *callbackSet = [self->registeredApp getCallbackSet:callbackKey];
    NSEnumerator *callbackEnum = [callbackSet objectEnumerator];
    while ((callback = [callbackEnum nextObject]))
    {
        [result setKeepCallback:YES];
        [callback setExtensionResult:result];
        // 将扩展结果返回给js端
        [self->jsEvaluator eval:callback];
    }
}

-(NSString*)getCallbackKey
{
    return [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self class]) withMethod:NSStringFromSelector(@selector(start:withDict:))];
}
@end

#endif
