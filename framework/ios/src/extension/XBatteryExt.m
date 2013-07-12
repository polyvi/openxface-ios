
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
//  XBatteryExt.m
//  xFace
//
//

#ifdef __XBatteryExt__

#import "XBatteryExt.h"
#import "XBatteryExt_Privates.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XQueuedMutableArray.h"
#import "XUtils.h"
#import "XJsCallback.h"

#define UNKNOWN_BATTERY_LEVEL   (-1.0)

@implementation XBatteryExt

@synthesize state;
@synthesize level;
@synthesize isPlugged;
@synthesize registeredApps;

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self.state = UIDeviceBatteryStateUnknown;
        self.level = UNKNOWN_BATTERY_LEVEL;
        self.isPlugged = NO;
        self.registeredApps = [[NSMutableSet alloc] init];
    }

    return self;
}

- (void)start:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    id<XApplication> app = [self getApplication:options];
    [registeredApps addObject:app];

    if ( NO == [UIDevice currentDevice].batteryMonitoringEnabled )
    {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryStatus:)
                                                     name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryStatus:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    }
}

- (void)stopObserving
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

- (void)stop:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    id<XApplication> app = [self getApplication:options];

    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self class]) withMethod:NSStringFromSelector(@selector(start:withDict:))];
    NSSet *callbackSet = [app getCallbackSet:callbackKey];
    [registeredApps removeObject:app];
    [app unregisterJsCallback:callbackKey];
    NSEnumerator *callBackEnum = [callbackSet objectEnumerator];
    XJsCallback *callback = nil;
    while((callback = [callBackEnum nextObject]))
    {
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:[self getBatteryStatus]];
        [result setKeepCallback:NO];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    }

    // 如果是最后一个app取消注册，则停止监控
    if ([registeredApps count] == 0)
    {
        [self stopObserving];
    }
}

#pragma mark Private Methods

- (void)updateBatteryStatus:(NSNotification *)notification
{
    NSDictionary* batteryData = [self getBatteryStatus];

    // Update every registered callback
    NSEnumerator *enumerator = [registeredApps objectEnumerator];
    id<XApplication> app = nil;
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self class]) withMethod:NSStringFromSelector(@selector(start:withDict:))];
    while ((app = [enumerator nextObject]))
    {
        NSSet *callbackSet = [app getCallbackSet:callbackKey];
        NSEnumerator *callbackEnum = [callbackSet objectEnumerator];
        XJsCallback *callback = nil;
        while ((callback = [callbackEnum nextObject]))
        {
            XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:batteryData];
            [result setKeepCallback:YES];
            [callback setExtensionResult:result];
            [self->jsEvaluator eval:callback];
        }
    }
}

- (NSDictionary *)getBatteryStatus
{
    UIDevice* currentDevice = [UIDevice currentDevice];
    UIDeviceBatteryState currentState = [currentDevice batteryState];

    isPlugged = NO; // UIDeviceBatteryStateUnknown or UIDeviceBatteryStateUnplugged
    if (UIDeviceBatteryStateCharging == currentState || UIDeviceBatteryStateFull == currentState )
    {
        isPlugged = YES;
    }

    float currentLevel = [currentDevice batteryLevel];
    if (currentLevel != self.level || currentState != self.state)
    {
        self.level = currentLevel;
        self.state = currentState;
    }

    // W3C spec says level must be null if it is unknown
    NSObject* w3cLevel = nil;
    if (UIDeviceBatteryStateUnknown == currentState || UNKNOWN_BATTERY_LEVEL == currentLevel)
    {
        w3cLevel = [NSNull null];
    }
    else
    {
        w3cLevel = [NSNumber numberWithFloat:(currentLevel * 100)];
    }

    NSMutableDictionary* batteryData = [NSMutableDictionary dictionaryWithCapacity:2];
    [batteryData setObject: [NSNumber numberWithBool:isPlugged] forKey:@"isPlugged"];
    [batteryData setObject: w3cLevel forKey:@"level"];
    return batteryData;
}

- (void)dealloc
{
    [self stopObserving];
}

@end

#endif
