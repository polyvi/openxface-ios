
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
//  XInAppBrowserXHRURLProtocol.m
//  xFace
//
//

#import "XInAppBrowserXHRURLProtocol.h"
#import "XHTTPURLResponse.h"

@implementation XInAppBrowserXHRURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
   if ([[theRequest.URL host] isEqualToString:XFACE_IAB]){
        return YES;
    }
    return NO;
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)request
{
    return request;
}

- (void)startLoading
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XFACE_IAB object:self.request]];
    XHTTPURLResponse* response = [[XHTTPURLResponse alloc] initWithBlankResponse:self.request.URL];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    // TODO:执行清理操作
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest*)requestA toRequest:(NSURLRequest*)requestB
{
    return NO;
}
@end
