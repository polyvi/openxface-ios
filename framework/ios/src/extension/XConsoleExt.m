
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
//  XConsoleExt.m
//  xFace
//
//

#ifdef __XConsoleExt__

#import "XConsoleExt.h"
#import "XJsCallback.h"

#define LOG_LEVEL_INFO   @"INFO"
#define LOG_LEVEL_WARN   @"WARN"
#define LOG_LEVEL_ERROR  @"ERROR"

#define JS_TAG           @"[xface-js]"

@implementation XConsoleExt

- (void)log:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
#pragma unused(callback)
    NSString* message = [NSString stringWithFormat:@"%@%@", JS_TAG, [arguments objectAtIndex:0]];

    NSDictionary* levelDictionary= [arguments objectAtIndex:1];
    NSString* logLevel = [levelDictionary objectForKey:@"logLevel"];

    if ((nil  == logLevel) ||
        (NSOrderedSame == [logLevel compare:LOG_LEVEL_INFO])) {
        XLogI(@"%@", message);
    }
    else if(NSOrderedSame == [logLevel compare:LOG_LEVEL_WARN])
    {
        XLogW(@"%@", message);
    }
    else if(NSOrderedSame == [logLevel compare:LOG_LEVEL_ERROR])
    {
        XLogE(@"%@", message);
    } else
    {
        XLogI(@"%@", message);
    }
}

@end

#endif
