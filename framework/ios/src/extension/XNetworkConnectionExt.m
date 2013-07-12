
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
//  XNetworkConnectionExt.m
//  xFace
//
//

#ifdef __XNetworkConnectionExt__

#import "XNetworkConnectionExt.h"
#import "XNetworkReachability.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XJsCallback.h"
#import "XNetworkConnectionExt_Privates.h"

#define NETWORK_CONNECTION_TYPE_2G          @"2g"
#define NETWORK_CONNECTION_TYPE_WIFI        @"wifi"
#define NETWORK_CONNECTION_TYPE_NONE        @"none"

@implementation XNetworkConnectionExt

@synthesize connectionType;
@synthesize internetReach;
@synthesize registeredApps;

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self.connectionType = NETWORK_CONNECTION_TYPE_NONE;
        self.registeredApps = [[NSMutableSet alloc] init];
        [self prepare];

        if (&UIApplicationDidEnterBackgroundNotification && &UIApplicationWillEnterForegroundNotification)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
    }

    return self;
}

- (void)dealloc
{
    self.internetReach = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];

    if (&UIApplicationDidEnterBackgroundNotification && &UIApplicationWillEnterForegroundNotification)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

- (void) getConnectionInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    id<XApplication> app = [self getApplication:options];
    [registeredApps addObject:app];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:self.connectionType];
    [result setKeepCallback:YES];
    [callback setExtensionResult:result];

    // 将执行结果返回给js端
    [self->jsEvaluator eval:callback];
}

- (NSString*) getConnectionType:(XNetworkReachability*)reachability
{
    NSString *type = NETWORK_CONNECTION_TYPE_NONE;

	NetworkStatus networkStatus = [reachability currentReachabilityStatus];
	switch(networkStatus)
	{
        case ReachableViaWWAN:   // FIXME:无法区分具体类型，使用2g作为connection type
            type = NETWORK_CONNECTION_TYPE_2G;
            break;
        case ReachableViaWiFi:
            type = NETWORK_CONNECTION_TYPE_WIFI;
            break;
        case NotReachable:
		default:
            break;
    }
    return type;
}

- (void) updateReachability:(XNetworkReachability*)reachability
{
    if (reachability)
    {
        //  检查connection类型是否改变,只在connection type改变时，才通知js端
        NSString* newConnectionType = [self getConnectionType:reachability];
        if ([newConnectionType isEqualToString:self.connectionType])
        {
            return;
        }
        else
        {
            self.connectionType = [self getConnectionType:reachability];
        }
    }

    // 将网络类型通知给js端，并由js端触发online offline事件
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:self.connectionType];
    [result setKeepCallback:YES];

    NSEnumerator *enumerator = [self.registeredApps objectEnumerator];
    id<XApplication> app = nil;
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self class]) withMethod:NSStringFromSelector(@selector(getConnectionInfo:withDict:))];
    while (app = [enumerator nextObject])
    {
        NSSet *callbackSet = [app getCallbackSet:callbackKey];
        NSEnumerator *callbackEnum = [callbackSet objectEnumerator];
        XJsCallback *callback = nil;
        while ((callback = [callbackEnum nextObject]))
        {
            [callback setExtensionResult:result];
            [self->jsEvaluator eval:callback];
        }
    }
    return;
}

- (void) updateConnectionType:(NSNotification*)notification
{
    XNetworkReachability* curReach = [notification object];
    if ([curReach isKindOfClass:[XNetworkReachability class]])
    {
        [self updateReachability:curReach];
    }
}

- (void) prepare
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectionType:) name:kReachabilityChangedNotification object:nil];

    self.internetReach = [XNetworkReachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    self.connectionType = [self getConnectionType:self.internetReach];
}

- (void) onPause
{
    [self.internetReach stopNotifier];
}

- (void) onResume
{
    [self.internetReach startNotifier];
    [self updateReachability:self.internetReach];
}

@end

#endif
