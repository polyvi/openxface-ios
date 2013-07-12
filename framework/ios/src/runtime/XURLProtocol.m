
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
//  XURLProtocol.m
//  xFaceLib
//
//

#import "XURLProtocol.h"
#import "XHTTPURLResponse.h"
#import "XWhitelist.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XAppController.h"

#define XFACE_EXEC_URL                     @"/!xface_exec"
#define HTTP_HEADER_FIELD_APP              @"app"
#define HTTP_HEADER_FIELD_REQUEST_ID       @"rc"
#define HTTP_HEADER_FIELD_CMDS             @"cmds"

// 记录了所有注册了的app的address
static NSMutableSet *sRegisteredApps = nil;

@implementation XURLProtocol

+ (void)registerApp:(id<XApplication>)app
{
    if (!sRegisteredApps)
    {
        [NSURLProtocol registerClass:[XURLProtocol class]];
        sRegisteredApps = [[NSMutableSet alloc] initWithCapacity:8];
    }

    @synchronized(sRegisteredApps)
    {
        [sRegisteredApps addObject:[NSNumber numberWithLongLong:(long long)app]];
    }
}

+ (void)unregisterApp:(id<XApplication>)app
{
    [sRegisteredApps removeObject:[NSNumber numberWithLongLong:(long long)app]];
}

+ (id)appForRequest:(NSURLRequest *)theRequest
{
    NSURL *theUrl = [theRequest URL];
    NSString *appAddressStr = [theRequest valueForHTTPHeaderField:HTTP_HEADER_FIELD_APP];
    if ([appAddressStr length] <= 0)
    {
        if ([[theUrl path] isEqualToString:XFACE_EXEC_URL])
        {
            XLogE(@"Request missing app header, the request will be handled improperly");
        }
        return nil;
    }

    long long appAddress = [appAddressStr longLongValue];
    @synchronized(sRegisteredApps)
    {
        if (![sRegisteredApps containsObject:[NSNumber numberWithLongLong:appAddress]])
        {
            return nil;
        }
        id<XApplication> app = (__bridge id<XApplication>)(void *)appAddress;
        return app;
    }
    return nil;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    NSURL *theUrl = [theRequest URL];
    //TODO:处理WebSocket的情况
    if ([XWhitelist isSchemeAllowed:[theUrl scheme]] || [[theUrl path] isEqualToString:XFACE_EXEC_URL])
    {
        id<XApplication> app = [self appForRequest:theRequest];
        return [app.appController canInitWithRequest:theRequest];
    }
    return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)request
{
    return request;
}

- (void)startLoading
{
    NSURL* url = [[self request] URL];

    if ([[url path] isEqualToString:XFACE_EXEC_URL])
    {
        XHTTPURLResponse* response = [[XHTTPURLResponse alloc] initWithBlankResponse:url];
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocolDidFinishLoading:self];
        return;
    }

    NSString* body = [XWhitelist errorStringForUrl:url];
    XHTTPURLResponse* response = [[XHTTPURLResponse alloc] initWithUnauthorizedURL:url];

    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:[body dataUsingEncoding:NSASCIIStringEncoding]];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    // NOTE:如有清理工作，可以在此处添加
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest*)requestA toRequest:(NSURLRequest*)requestB
{
    return NO;
}

@end

