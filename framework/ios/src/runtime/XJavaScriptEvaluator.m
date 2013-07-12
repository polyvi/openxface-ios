
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
//  XJavaScriptEvaluator.m
//  xFace
//
//

#import "XJavaScriptEvaluator.h"
#import "XJavaScriptEvaluator_Privates.h"
#import "XAppWebView.h"
#import "XAppList.h"
#import "XJsCallback.h"
#import "XApplication.h"
#import "XCommandQueue.h"
#import "XExtensionManager.h"

@implementation XJavaScriptEvaluator

- (id) initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self)
    {
        self->_app = app;
    }
    return self;
}

- (void) eval:(XJsCallback *)jsCallback
{
    if(![jsCallback isValid:_app])
    {
        return;
    }

    NSString *jsScript = [jsCallback genCallbackScript];
    if(jsScript)
    {
        [self evalJsHelper:jsScript];
    }
    return;
}

#pragma mark privates

- (void)evalJsHelper:(NSString*)js
{
    // Cycle the run-loop before executing the JS.
    // This works around a bug where sometimes alerts() within callbacks can cause
    // dead-lock.
    // If the commandQueue is currently executing, then we know that it is safe to
    // execute the callback immediately.
    // Using    (dispatch_get_main_queue()) does *not* fix deadlocks for some reaon,
    // but performSelectorOnMainThread: does.


    if (![NSThread isMainThread] || !_app.extMgr.commandQueue.currentlyExecuting)
    {
        [self performSelectorOnMainThread:@selector(evalJs:) withObject:js waitUntilDone:NO];
    }
    else
    {
        [self evalJs:js];
    }
}

- (void)evalJs:(NSString *)js
{
    UIWebView* webView = (UIWebView*)[_app appView];
    NSString *commandsJSON = [webView stringByEvaluatingJavaScriptFromString:js];

    [_app.extMgr.commandQueue enqueAndTryExecCommandBatch:commandsJSON];
}

@end
