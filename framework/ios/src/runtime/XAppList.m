
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
//  XAppList.m
//  xFace
//
//

#import "XAppList.h"
#import "XApplication.h"
#import "XAppView.h"

@implementation XAppList

@synthesize defaultAppId;

- (id) init
{
    self = [super init];
    if (self)
    {
        self->appCollection = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) add:(id<XApplication>)app
{
    @synchronized(self)
    {
        if (nil != app)
        {
            NSAssert(![self containsApp:[app getAppId]], @"Shouldn't add an application with duplicate app id!");
            [self->appCollection addObject: app];
        }
    }
}

- (id<XApplication>) getAppById:(NSString*)appId
{
    for (id<XApplication> app in self->appCollection)
    {
        if([appId isEqualToString:[app getAppId]])
        {
            return app;
        }
    }

    return nil;
}

- (BOOL) containsApp:(NSString *)appId
{
    id<XApplication> app = [self getAppById:appId];
    return (nil != app);
}

- (void) removeAppById:(NSString *)appId
{
    @synchronized(self)
    {
        id<XApplication> appToDel = [self getAppById:appId];
        [self->appCollection removeObject:appToDel];
    }
}

- (void) markAsDefaultApp:(NSString *)appId
{
    self->defaultAppId = appId;
}

- (id<XApplication>) getDefaultApp
{
    id<XApplication> defaultApp = [self getAppById:[self defaultAppId]];
    return defaultApp;
}

- (NSEnumerator *)getEnumerator
{
    return [self->appCollection objectEnumerator];
}

@end
