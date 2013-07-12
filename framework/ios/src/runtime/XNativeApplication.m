
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
//  XNativeApplication.m
//  xFaceLib
//
//

#import "XNativeApplication.h"
#import "XAppInfo.h"
#import "XStoreProductPresenter.h"
#import "XConstants.h"
#import "XUtils.h"

@implementation XNativeApplication

@synthesize appInfo;
@synthesize appView;
@synthesize whitelist;

- (id) initWithAppInfo:(XAppInfo *)applicationInfo
{
    self = [super init];
    if (self)
    {
        self.appInfo = applicationInfo;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xAppDidFinishInstall:)
                                                     name:XAPPLICATION_DID_FINISH_INSTALL_NOTIFICATION object:self];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *) getAppId
{
    NSAssert((nil != [self appInfo]), nil);
    return [[self appInfo] appId];
}

- (BOOL) isInstalled
{
    NSString *urlStr = [[self appInfo] entry];
    NSURL *url = [NSURL URLWithString:[self validateEntry:urlStr]];
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:url];
    return isInstalled;
}

- (BOOL) isNative
{
    return YES;
}

- (BOOL) loadWithParameters:(NSString *)params
{
    NSURL *url = nil;
    BOOL ret = [self isInstalled];
    if (ret)
    {
        //已安装时，通过custom URL启动native app
        //如果启动参数非空，则将custom URL scheme与启动参数进行组装后传递给native app
        NSString *urlStr = [self validateEntry:[[self appInfo] entry]];
        if ([params length])
        {
            urlStr = [urlStr stringByAppendingString:params];
        }

        url = [NSURL URLWithString:urlStr];
        ret = [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        //未安装时，展示native app安装界面
        ret = [[XStoreProductPresenter getInstance] presentStoreProductWithAppInfo:[self appInfo]];
    }

    return ret;
}

- (NSString*) getIconURL
{
    NSString* relativeIconPath = [appInfo icon];
    if (0 == [relativeIconPath length])
    {
        return nil;
    }

    NSString* appId = appInfo.appId;
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:appId relativeIconPath:relativeIconPath];

    NSString *iconURL = (nil == iconPath) ? nil : [[NSURL fileURLWithPath:iconPath] absoluteString];
    return iconURL;
}

#pragma mark app event

- (void) xAppDidFinishInstall:(NSNotification*)notification
{
    NSAssert(self == [notification object], nil);

    if (![self isInstalled])
    {
        NSAssert([self isNative], nil);
        [[XStoreProductPresenter getInstance] presentStoreProductWithAppInfo:[self appInfo]];
    }
    return;
}

#pragma mark Privates

-(NSString *)validateEntry:(NSString *)entry
{
    NSString *validatedEntry = entry;
    NSRange range = [validatedEntry rangeOfString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];

    if(NSNotFound == range.location)
    {
        validatedEntry = [validatedEntry stringByAppendingString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];
    }
    return validatedEntry;
}

@end
