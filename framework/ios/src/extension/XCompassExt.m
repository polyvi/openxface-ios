
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
//  XCompassExt.m
//  xFaceLib
//
//

#ifdef __XCompassExt__

#import "XCompassExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XCompassExt_Privates.h"
#import "XJsCallback.h"
#import "XQueuedMutableArray.h"

#pragma mark -
#pragma mark XHeadingData

// simple object to keep track of heading information
@interface XHeadingData : NSObject
{

}

@property (nonatomic, assign) HeadingStatus headingStatus;
@property (nonatomic, strong) CLHeading* headingInfo;
@property (nonatomic, strong) NSMutableArray* headingCallbacks;
@property (nonatomic, strong) XJsCallback* headingFilter;
@property (nonatomic, strong) NSDate* headingTimestamp;
@property (assign) NSInteger timeout;

@end

@implementation XHeadingData

@synthesize headingStatus;
@synthesize headingInfo;
@synthesize headingCallbacks;
@synthesize headingFilter;
@synthesize headingTimestamp;
@synthesize timeout;

-(XHeadingData*) init
{
    self = (XHeadingData*)[super init];
    if (self)
    {
        self.headingStatus = HEADING_STOPPED;
        self.headingInfo = nil;
        self.headingCallbacks = nil;
        self.headingFilter = nil;
        self.headingTimestamp = nil;
        self.timeout = 10;
    }
    return self;
}

@end

#pragma mark -
#pragma mark XCompassExt

@implementation XCompassExt

@synthesize locationManager;
@synthesize headingData;

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        // Tells the location manager to send updates to this object
        self.locationManager.delegate = self;
        self.headingData = nil;
    }
    return self;
}

- (BOOL) hasHeadingSupport
{
    return [CLLocationManager headingAvailable];
}

- (void)getHeading:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSDictionary *jsOptions = [arguments objectAtIndex:0 withDefault:nil];
    NSNumber* filter = [jsOptions valueForKey:@"filter"];
    XExtensionResult *result = nil;

    if (filter)
    {
        [self watchHeadingFilter: arguments withDict: options];
        return;
    }
    if (NO == [self hasHeadingSupport])
    {
        // return error
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:COMPASS_NOT_SUPPORTED];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    }
    else
    {
        // heading 可以正常使用不受 location services 不可用或未授权的影响
        if (!self.headingData)
        {
            self.headingData = [[XHeadingData alloc] init];
        }
        XHeadingData* head = self.headingData;

        if (!head.headingCallbacks)
        {
            head.headingCallbacks = [NSMutableArray arrayWithCapacity:1];
        }
        // add the callbackId into the array so we can call back when get data
        [head.headingCallbacks addObject:callback];

        if (head.headingStatus != HEADING_RUNNING && head.headingStatus != HEADING_ERROR)
        {
            // Tell the location manager to start notifying us of heading updates
            [self startHeadingWithFilter: 0.2];
        }
        else
        {
            [self returnHeadingInfo: callback keepCallback:NO];
        }
    }
}

- (void)returnHeadingInfo: (XJsCallback*) callback keepCallback: (BOOL) theRetain
{
    XExtensionResult* result = nil;
    XHeadingData* head = self.headingData;

    self.headingData.headingTimestamp = [NSDate date];

    if (HEADING_ERROR == head.headingStatus && head)
    {
        // return error
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:COMPASS_INTERNAL_ERR];
    }
    else if (HEADING_RUNNING == head.headingStatus && head && head.headingInfo)
    {
        // if there is heading info, return it
        CLHeading* hInfo = head.headingInfo;
        NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:4];
        NSNumber* timestamp = [NSNumber numberWithDouble:([hInfo.timestamp timeIntervalSince1970]*1000)];
        [returnInfo setObject:timestamp forKey:@"timestamp"];
        [returnInfo setObject:[NSNumber numberWithDouble: hInfo.magneticHeading] forKey:@"magneticHeading"];
        //当同时启动location定位的时候,trueHeading才具有一个有效值
        id trueHeading = (id)[NSNumber numberWithDouble:hInfo.trueHeading];
        [returnInfo setObject:trueHeading forKey:@"trueHeading"];
        [returnInfo setObject:[NSNumber numberWithDouble: hInfo.headingAccuracy] forKey:@"headingAccuracy"];

        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject: returnInfo];
        [result setKeepCallback:theRetain];
    }
    if (result)
    {
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    }
}

- (void)watchHeadingFilter:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSDictionary *jsOptions = [arguments objectAtIndex:0 withDefault:nil];
    NSNumber* filter = [jsOptions valueForKey:@"filter"];
    XHeadingData* head = self.headingData;

    if (NO == [self hasHeadingSupport])
    {
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:COMPASS_NOT_SUPPORTED];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    }
    else
    {
        if (!head)
        {
            self.headingData = [[XHeadingData alloc] init];
            head = self.headingData;
        }
        if (head.headingStatus != HEADING_RUNNING)
        {
            // Tell the location manager to start notifying us of heading updates
            [self startHeadingWithFilter: [filter doubleValue]];
        }
        else
        {
            // if already running, check to see if due to existing watch filter
            if (head.headingFilter && ![head.headingFilter.callbackId isEqualToString:callback.callbackId])
            {
                // new watch filter being specified
                // send heading data one last time to clear old successCallback
                [self returnHeadingInfo:head.headingFilter keepCallback: NO];
            }

        }
        // save the new filter callback and update the headingFilter setting
        head.headingFilter = callback;
        // check if need to stop and restart in order to change value???
        self.locationManager.headingFilter = [filter doubleValue];
    }
}

- (void)stopHeading:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (self.headingData && self.headingData.headingStatus != HEADING_STOPPED)
    {
        if (self.headingData.headingFilter)
        {
            // callback one last time to clear callback
            [self returnHeadingInfo: self.headingData.headingFilter keepCallback:NO];
            self.headingData.headingFilter = nil;
        }
        [self.locationManager stopUpdatingHeading];
        XLogI(@"heading STOPPED");
        self.headingData = nil;
    }
}

- (void) startHeadingWithFilter: (CLLocationDegrees) filter
{
    self.locationManager.headingFilter = filter;
    [self.locationManager startUpdatingHeading];
    self.headingData.headingStatus = HEADING_STARTING;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading
{
    XHeadingData* head = self.headingData;

    // no heddingInfo
    if (nil == head)
    {
        return;
    }

    // save the data for next call into getHeadingData
    head.headingInfo = heading;
    BOOL isTimeout = NO;
    if (!head.headingFilter && head.headingTimestamp)
    {
        isTimeout = fabs([head.headingTimestamp timeIntervalSinceNow ]) > head.timeout;
    }

    if (HEADING_STARTING == head.headingStatus)
    {
        head.headingStatus = HEADING_RUNNING; // so returnHeading info will work
        //this is the first update
        for (XJsCallback* callback in head.headingCallbacks)
        {
            [self returnHeadingInfo:callback keepCallback:NO];
        }
        [head.headingCallbacks removeAllObjects];
    }

    if (head.headingFilter)
    {
        [self returnHeadingInfo: head.headingFilter keepCallback:YES];
    }
    else if (isTimeout)
    {
        [self stopHeading:nil withDict:nil];
    }
    head.headingStatus = HEADING_RUNNING;  // to clear any error
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    XLogE(@"locationManager::didFailWithError %@", [error localizedFailureReason]);
    // Compass Error
    if (kCLErrorHeadingFailure == [error code])
    {
        XHeadingData* head = self.headingData;
        if (head)
        {
            if (HEADING_STARTING == head.headingStatus)
            {
                // heading error during startup - report error
                for (XJsCallback* callback in head.headingCallbacks)
                {
                    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:COMPASS_INTERNAL_ERR];
                    [callback setExtensionResult:result];
                    [self->jsEvaluator eval:callback];
                }
                [head.headingCallbacks removeAllObjects];
            } // else for frequency watches next call to getCurrentHeading will report error
            if (head.headingFilter)
            {
                XExtensionResult* resultFilter = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt:COMPASS_INTERNAL_ERR];
                XJsCallback *callback = head.headingFilter;
                [callback setExtensionResult:resultFilter];
                [self->jsEvaluator eval:callback];
            }
            head.headingStatus = HEADING_ERROR;
        }
    }
}

@end

#endif
