
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
//  XAccelerometerExt.m
//  xFaceLib
//
//

#ifdef __XAccelerometerExt__

#import "XAccelerometerExt.h"
#import "XQueuedMutableArray.h"
#import "XExtensionResult.h"
#import "XApplication.h"
#import "XJavaScriptEvaluator.h"
#import "XUtils.h"
#import "XJsCallback.h"

// defaults to 10 msec
#define kAccelerometerInterval      40
// g constant: -9.81 m/s^2
#define kGravitionalConstant        -9.81

@interface XAccelerometerExt()

@property (assign) BOOL isRunning;                              /**< 是否正在监听 */
@property (nonatomic, strong) NSMutableSet *registeredApps;     /**< 注册管理多个js callback对应的应用 */

@end

@implementation XAccelerometerExt

@synthesize isRunning;
@synthesize registeredApps;

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if(self)
    {
        x = 0;
        y = 0;
        z = 0;
        timestamp = 0;
        self.isRunning = NO;
        self.registeredApps = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)start:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id<XApplication> app = [self getApplication:options];
    [registeredApps addObject:app];

	UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer];
	// accelerometer expects fractional seconds, but we have msecs
	accelerometer.updateInterval = kAccelerometerInterval / 1000;

	if(!self.isRunning)
	{
		accelerometer.delegate = self;
		self.isRunning = YES;
	}
}

- (void)stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id<XApplication> app = [self getApplication:options];

    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self class]) withMethod:NSStringFromSelector(@selector(start:withDict:))];
    [registeredApps removeObject:app];
    [app unregisterJsCallback:callbackKey];

    // 如果是最后一个app取消注册，则停止监控
    if ([self.registeredApps count] == 0)
    {
        UIAccelerometer*  accelerometer = [UIAccelerometer sharedAccelerometer];
        accelerometer.delegate = nil;
        self.isRunning = NO;
    }
}

- (void)returnAccelInfo
{
    // Create an acceleration object
    NSMutableDictionary *accelProps = [NSMutableDictionary dictionaryWithCapacity:4];
    [accelProps setValue:[NSNumber numberWithDouble:x * kGravitionalConstant] forKey:@"x"];
    [accelProps setValue:[NSNumber numberWithDouble:y * kGravitionalConstant] forKey:@"y"];
    [accelProps setValue:[NSNumber numberWithDouble:z * kGravitionalConstant] forKey:@"z"];
    [accelProps setValue:[NSNumber numberWithDouble:timestamp] forKey:@"timestamp"];

    // Update every registered callback
    NSEnumerator *enumerator = [self.registeredApps objectEnumerator];
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self class]) withMethod:NSStringFromSelector(@selector(start:withDict:))];
    id<XApplication> app = nil;
    while ((app = [enumerator nextObject]))
    {
        NSEnumerator *callbackEnum = [[app getCallbackSet:callbackKey] objectEnumerator];
        XJsCallback *callback = nil;
        if ((callback = [callbackEnum nextObject]))
        {
            XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:accelProps];
            [result setKeepCallback:YES];
            [callback setExtensionResult:result];
            [self->jsEvaluator eval:callback];
        }
        app = [enumerator nextObject];
    }
}

/**
 * Picks up accel updates from device and stores them in this class
 */
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if(self.isRunning)
    {
        x = acceleration.x;
        y = acceleration.y;
        z = acceleration.z;
        timestamp = ([[NSDate date] timeIntervalSince1970] * 1000);
        [self returnAccelInfo];
    }
}

@end

#endif
