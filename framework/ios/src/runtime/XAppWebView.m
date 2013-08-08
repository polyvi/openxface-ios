
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
//  XAppWebView.m
//  xFace
//
//

#import "XAppWebView.h"
#import "XUtils.h"
#import "XConstants.h"

#define URL_REQUEST_TIMEOUT_INTERVAL 20.0

@implementation XAppWebView

@synthesize valid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self->isValid = NO;

        self.scalesPageToFit = YES;

        // 指定DisallowOverscroll为true时,webview不弹跳
        BOOL disallowBounce = [[XUtils getPreferenceForKey:DISALLOW_OVERSCROLL] boolValue];
        if (disallowBounce) {
            if ([self respondsToSelector:@selector(scrollView)]) {
                ((UIScrollView*)[self scrollView]).bounces = NO;
            } else {
                for (id subview in self.subviews) {
                    if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
                        ((UIScrollView*)subview).bounces = NO;
                    }
                }
            }
        }

    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark XAppView

- (void)loadApp:(NSURL *)url
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:URL_REQUEST_TIMEOUT_INTERVAL];

    [self loadRequest:req];
}

- (void)show
{
    self.hidden = NO;
}

- (void) close
{
    [self removeFromSuperview];
}

@end
