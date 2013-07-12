
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
//  XDeviceExt.m
//  xFace
//
//

#ifdef __XDeviceExt__

#import "XDeviceExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XQueuedMutableArray.h"
#import "XJsCallback.h"
#import "XConfiguration.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "XNetworkReachability.h"
#import "XUtils+Additions.h"
#import "XDeviceProperties.h"

@implementation XDeviceExt

- (void)getDeviceInfo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    XExtensionResult *result = nil;

    NSDictionary *deviceProperties = [[[XDeviceProperties alloc] init] deviceProperties];
    result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:deviceProperties];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

@end

#endif
