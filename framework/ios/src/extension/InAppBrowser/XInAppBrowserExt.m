
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
//  XInAppBrowserExt.m
//  xFace
//
//

#ifdef __XInAppBrowserExt__

#import "XInAppBrowserExt.h"
#import "XBrowserViewController.h"
#import "XExtension.h"
#import "XExtensionResult.h"
#import "XRootViewController.h"
#import "XJsCallback.h"
#import "XJavaScriptEvaluator.h"
#import "XUtils.h"
#import "XApplication.h"
#import "XAppView.h"
#import "XWebApplication.h"

#define kInAppBrowserTargetSelf        @"_self"
#define kInAppBrowserTargetSystem      @"_system"
#define kInAppBrowserTargetBlank       @"_blank"

#pragma mark XInAppBrowserExt

@implementation XInAppBrowserExt

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self->browserViewControllers = [NSMutableDictionary dictionaryWithCapacity:1];
    }

    return self;
}

- (void)close:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id<XApplication> app = [self getApplication:options];

    XBrowserViewController* controller = [self->browserViewControllers objectForKey:[app getAppId]];
    [controller close];
}

- (NSURL*) updateURL:(NSString*)target baseURL:(NSURL*)baseURL
{
    NSURL* url = [NSURL URLWithString:target];

    if ([url scheme] != nil)
    {
        return url;
    }
    else
    {
        return [[NSURL alloc] initWithString:target relativeToURL:baseURL];
    }
}

- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id<XApplication> app = [self getApplication:options];
    XJsCallback* jsCallback = [self getJsCallback:options];
    NSString* urlString = [arguments objectAtIndex:0];
    NSString* target = CAST_TO_NIL_IF_NSNULL([arguments objectAtIndex:1]);
    NSString* jsoptions = CAST_TO_NIL_IF_NSNULL([arguments objectAtIndex:2]);
    NSURL* url = [self updateURL:urlString baseURL:[app getURL]];
    if (target == nil || [target isEqualToString:kInAppBrowserTargetSelf])
    {
        [self openInXFaceWebView:url withApp:app];
    } else if ([target isEqualToString:kInAppBrowserTargetSystem])
    {
        [self openInSystem:url];
    } else
    { // _blank or anything else
        [self openInInAppBrowser:url withOptions:jsoptions app:app jsCallback:jsCallback];
    }
}

- (NSString *)getUserAgent
{
    UIWebView* testWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* originalUA = [testWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* modifiedUA = [NSString stringWithFormat:@"%@ (%@)", originalUA, uuidString];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    return modifiedUA;
}

- (void)openInInAppBrowser:(NSURL*)url withOptions:(NSString*)options app:(id<XApplication>)app jsCallback:(XJsCallback*)jsCallback
{
    XBrowserViewController* controller = [self->browserViewControllers objectForKey:[app getAppId]];
    if (controller == nil) {
        controller = [[XBrowserViewController alloc]
                                      initWithUserAgent:[self getUserAgent]
                                      delegate:self
                                      app:app jsCallback:jsCallback];
        [self->browserViewControllers setObject:controller forKey:[app getAppId]];
    }

     //TODO: set orientation delegate

    XInAppBrowserOptions* browserOptions = [XInAppBrowserOptions parseOptions:options];
    [controller showLocationBar:browserOptions.location];

    if (self.viewController.presentedViewController != controller) {
        [self.viewController presentViewController:controller animated:YES completion:nil];
    }
    [controller navigateTo:url];
}

- (void)openInXFaceWebView:(NSURL*)url withApp:(id<XApplication>)app
{
    id<XAppView> appView = [app appView];
    [appView loadApp:url];
}

- (void)openInSystem:(NSURL*)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        //TODO:handle any custom schemes to plugins
    }
}

- (void)injectScriptCode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id <XApplication> app = [self getApplication:options];
    XJsCallback* jsCallback = [self getJsCallback:options];
    XBrowserViewController* controller = [self->browserViewControllers objectForKey:[app getAppId]];

    NSString* ret = [controller evaljs:[arguments objectAtIndex:0]];

    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:ret];
    [jsCallback setExtensionResult:result];
    [self->jsEvaluator eval:jsCallback];

}

- (void)injectScriptFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id <XApplication> app = [self getApplication:options];
    XJsCallback* jsCallback = [self getJsCallback:options];
    XBrowserViewController* controller = [self->browserViewControllers objectForKey:[app getAppId]];

    [controller loadJsFile:[arguments objectAtIndex:0] callback:^()
     {
         XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK];
         [jsCallback setExtensionResult:result];
         [self->jsEvaluator eval:jsCallback];
         return result.keepCallback;//返回值表示是否保留回调
     }];
}

- (void)injectStyleCode:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id <XApplication> app = [self getApplication:options];
    XJsCallback* jsCallback = [self getJsCallback:options];
    XBrowserViewController* controller = [self->browserViewControllers objectForKey:[app getAppId]];

    [controller insertCSS:[arguments objectAtIndex:0] callback:^()
     {
         XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK];
         [jsCallback setExtensionResult:result];
         [self->jsEvaluator eval:jsCallback];
         return result.keepCallback;
     }];

}

- (void)injectStyleFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id <XApplication> app = [self getApplication:options];
    XJsCallback* jsCallback = [self getJsCallback:options];
    XBrowserViewController* controller = [self->browserViewControllers objectForKey:[app getAppId]];

    [controller loadCSSFile:[arguments objectAtIndex:0] callback:^()
     {
         XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK];
         [jsCallback setExtensionResult:result];
         [self->jsEvaluator eval:jsCallback];
         return result.keepCallback;
     }];
}

#pragma mark XInAppBrowserNavigationDelegate

- (void)browserLoadStart:(NSURL*)url app:(id<XApplication>)app callback:(XJsCallback*)jsCallback;
{
    XExtensionResult *result = nil;
    NSDictionary* dict = @{@"type":@"loadstart", @"url":[url absoluteString]};
    result = [XExtensionResult resultWithStatus:STATUS_OK
                                messageAsObject:dict];
    [result setKeepCallback:YES];
    [jsCallback setExtensionResult:result];
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:jsCallback];
}

- (void)browserLoadStop:(NSURL*)url app:(id<XApplication>)app callback:(XJsCallback*)jsCallback;
{
    NSDictionary* dict = @{@"type":@"loadstop", @"url":[url absoluteString]};
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK
                                                  messageAsObject:dict];
    [result setKeepCallback:YES];
    [jsCallback setExtensionResult:result];
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:jsCallback];
}

- (void)browserExitWithApp:(id<XApplication>)app callback:(XJsCallback*)jsCallback;
{
    NSDictionary* dict = @{@"type":@"exit"};
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK
                                                  messageAsObject:dict];
    [result setKeepCallback:YES];
    [jsCallback setExtensionResult:result];
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:jsCallback];
    [self->browserViewControllers removeObjectForKey:[app getAppId]];
}

@end

#endif
