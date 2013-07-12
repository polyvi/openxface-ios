
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
//  XEchoExt.m
//  xFaceLib
//
//

#ifdef __XEchoExt__

#import "XEchoExt.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XExtensionResult.h"
#import "XUtils.h"

@implementation XEchoExt

- (void)echo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:CAST_TO_NIL_IF_NSNULL([arguments objectAtIndex:0])];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (void)echoAsync:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:CAST_TO_NIL_IF_NSNULL([arguments objectAtIndex:0])];
    [callback setExtensionResult:result];

    [self->jsEvaluator performSelector:@selector(eval:) withObject:callback afterDelay:0];
}

@end

#endif
