
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  XXMLHttpRequestExt.m
//  xFaceLib
//
//
#ifdef __XXMLHttpRequestExt__

#import "XXMLHttpRequestExt.h"
#import "XMutableURLRequest.h"
#import "XJsCallback.h"
#import "XJavaScriptEvaluator.h"
#import "XExtensionResult.h"
#import "XQueuedMutableArray.h"

@implementation XXMLHttpRequestExt

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self) {
        _requests = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSString* requestId = [arguments objectAtIndex:0];
    NSString* method = [arguments objectAtIndex:1];
    NSString* url = [arguments objectAtIndex:2];

    //TODO: set timeout
    XMutableURLRequest *newRequest = [XMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    newRequest.Id = requestId;

    //成功回调返回ajax的js对象
    newRequest.successCallBack = ^(NSDictionary* ajaxObject)
    {
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK
                                                      messageAsObject:ajaxObject];
        [result setKeepCallback:YES];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    };

    newRequest.errorCallBack = ^(NSDictionary* error)
    {
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR
                                                      messageAsObject:error];
        [result setKeepCallback:YES];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    };
    [_requests setObject:newRequest forKey:requestId];

    [newRequest open:method url:url];
}

- (void)send:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* requestId = [arguments objectAtIndex:0];
    NSString* data = [arguments objectAtIndex:1 withDefault:nil];
    XMutableURLRequest* request = [_requests objectForKey:requestId];
    [request sendData:data];
}

- (void)setRequestHeader:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* requestId = [arguments objectAtIndex:0];
    NSString* field     = [arguments objectAtIndex:1];
    NSString* value     = [arguments objectAtIndex:2];

    XMutableURLRequest* request = [_requests objectForKey:requestId];
    [request setValue:value forHTTPHeaderField:field];

}

- (void)abort:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* requestId = [arguments objectAtIndex:0];
    XMutableURLRequest* request = [_requests objectForKey:requestId];
    [request abort];
}

- (void) onPageStarted:(NSString*)appId
{
    [_requests removeAllObjects];
}

@end

#endif
