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
//  XAppController.m
//  xFaceLib
//
//

#import "XAppController.h"
#import "XExtensionManager.h"
#import "XApplication.h"
#import "XJavaScriptEvaluator.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XJsCallback.h"
#import "XCommandQueue.h"
#import "XWhitelist.h"
#import "XAppWebView.h"

#define EXTENSION_MAP_INITIAL_CAPACITY                 4

#define URL_SCHEME_XFACE                               @"xface"
#define URL_SCHEME_TEL                                 @"tel"
#define URL_SCHEME_ABOUT                               @"about"
#define URL_SCHEME_DATA                                @"data"

#define XFACE_EXEC_URL                                 @"/!xface_exec"
#define HTTP_HEADER_FIELD_APP                          @"app"
#define HTTP_HEADER_FIELD_REQUEST_ID                   @"rc"
#define HTTP_HEADER_FIELD_CMDS                         @"cmds"

@implementation XAppController

- (id) initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self)
    {
        self->_app = app;
    }
    return self;
}
#pragma mark Commands

- (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    NSURL *theUrl = [theRequest URL];

    if ([[theUrl path] isEqualToString:XFACE_EXEC_URL])
    {
        NSString *queuedCommandsJSON = [theRequest valueForHTTPHeaderField:HTTP_HEADER_FIELD_CMDS];
        NSString *requestIdStr = [theRequest valueForHTTPHeaderField:HTTP_HEADER_FIELD_REQUEST_ID];
        if ([requestIdStr length] <= 0)
        {
            XLogE(@"!xFace request missing rc header");
            return NO;
        }

        XCommandQueue *cmdQueue = _app.extMgr.commandQueue;
        BOOL hasCmds = [queuedCommandsJSON length] > 0;
        if (hasCmds)
        {
            SEL sel = @selector(enqueAndTryExecCommandBatch:);

            [cmdQueue performSelectorOnMainThread:sel withObject:queuedCommandsJSON waitUntilDone:NO];
        }
        else
        {
            SEL sel = @selector(tryFlushCommandsFromJs:);
            NSNumber *requestId = [NSNumber numberWithInteger:[requestIdStr integerValue]];

            [cmdQueue performSelectorOnMainThread:sel withObject:requestId waitUntilDone:NO];
        }
        // Returning NO here would be 20% faster, but it spams WebInspector's console with failure messages.
        // If JS->Native bridge speed is really important for an app, they should use the iframe bridge.
        // Returning YES here causes the request to come through canInitWithRequest two more times.
        // For this reason, we return NO when cmds exist.
        return !hasCmds;
    }

    if ([XWhitelist isSchemeAllowed:[theUrl scheme]])
    {
         // if it FAILS the whitelist, we return TRUE, so we can fail the connection later
        return ![_app.whitelist isUrlAllowed:theUrl];
    }

    return NO;
}

- (BOOL) shouldStartLoadWebView:(UIWebView *)theWebView withRequest:(NSURLRequest *)request
{
    NSURL *url = [request URL];

    // 执行通过js端xFace.exec()方法添加的命令
    if ([[url scheme] isEqualToString:URL_SCHEME_XFACE])
    {
        [_app.extMgr.commandQueue flushCommandsFromJs];
        return NO;
    }
    else if ([url isFileURL]) // 对于file：协议，允许web view加载
    {
        return YES;
    }
    else if (self->_loadFromString) // 允许通过设置页面内容加载webview
    {
        self->_loadFromString = NO;
        return YES;
    }
    else if ([[url scheme] isEqualToString:URL_SCHEME_DATA]) //对于data：协议，允许web view加载
    {
        return YES;
    }
    else if ([[url scheme] isEqualToString:URL_SCHEME_ABOUT]) // 不处理about：协议
    {
        return NO;
    }
    else
    {
        if ([XWhitelist isSchemeAllowed:[url scheme]])
        {
            return [_app.whitelist isUrlAllowed:url];
        }
        else
        {
            // 对于xface，web，local之外的请求，交给Safari处理，如sms:55555555 facetime:55555555 mailto:123@gmail.com
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
            else
            {
                // TODO:处理自定义协议
            }
        }

        return NO;
    }
}

#pragma mark UIWebViewDelegate

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL ret = [self shouldStartLoadWebView:theWebView withRequest:request];

    return ret;
}

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    id<XAppView> appView = (id<XAppView>) theWebView;
    if([appView isValid])
    {
        // 将appId等初始化数据设置到js端
        NSString* appIdResult = [[NSMutableString alloc] initWithFormat:
                                 @"(function() { \
                                 xFace.require('xFace/privateModule').initPrivateData(['%@']); \
                                 })()",
                                 [_app getAppId]];
        XJsCallback *callback = [[XJsCallback alloc] init];
        [callback setJsScript:appIdResult];
        [_app.jsEvaluator eval:callback];

        // 通知js端native ready
        // 当使用XHR js->native bridge mode时，通过xFace.iOSAppAddr来标识app

        NSString *params = [_app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS];
        [_app removeDataForKey:APP_DATA_KEY_FOR_START_PARAMS];

        NSString *nativeReady = [NSString stringWithFormat:@"xFace.iOSAppAddr='%lld';try{xFace.require('xFace/channel').onNativeReady.fire('%@');}catch(e){window._nativeReady = true;}", (long long)_app, params];
        [callback setJsScript:nativeReady];
        [_app.jsEvaluator eval:callback];

        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:WEBVIEW_DID_FINISH_LOAD_NOTIFICATION object:_app]];
    }
    [XUtils performSelectorInBackgroundWithTarget:[XUtils rootViewController] selector:@selector(tryTurnOffSplashAndShowWebView:) withObject:theWebView];

}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self->_loadFromString = YES;

    NSString *html = [NSString stringWithFormat:@"<html><head><meta name='viewport' content='width=device-width, user-scalable=no' /><head><body> %@%@ </body></html>", @"Failed to load webpage with error: ", [error localizedDescription]];
    [webView loadHTMLString:html baseURL:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    id<XAppView> appView = (id<XAppView>) webView;
    // 有可能在webview加载页面的时候，app已经被关闭了
    if([appView isValid])
    {
        [_app.extMgr onPageStarted:[_app getAppId]];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:WEBVIEW_DID_START_LOAD_NOTIFICATION object:_app]];
    }
}

@end
