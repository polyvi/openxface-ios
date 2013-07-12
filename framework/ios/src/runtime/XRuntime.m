
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
//  XRuntime.m
//  xFace
//
//

#import "XRuntime.h"
#import "XRootViewController.h"
#import "XAppManagement.h"
#import "XApplication.h"
#import "XAppView.h"
#import "XConstants.h"
#import "XAppList.h"
#import "NSObject+JSONSerialization.h"
#import "XRuntime_Privates.h"
#import "XAppUpdater.h"
#import "XUtils.h"
#import "XSystemBootstrapFactory.h"
#import "XSystemEventHandler.h"
#import "XAnalyzer.h"
#import "XConfiguration.h"

// TODO:日后需要增加本地化操作
// 系统初始化失败时，相关的提示信息
static NSString * const SYSTEM_INITIALIZE_FAILED_ALERT_TITLE        = @"Initialisation Failed";
static NSString * const SYSTEM_INITIALIZE_FAILED_ALERT_MESSAGE      = @"Please press Home key to exit and try to reinstall!";
static NSString * const SYSTEM_INITIALIZE_FAILED_ALERT_BUTTON_TITLE = @"OK";

@implementation XRuntime

@synthesize rootViewController;
@synthesize appManagement;
@synthesize systemBootstrap;
@synthesize sysEventHandler;
@synthesize appUpdater;
@synthesize pushDelegate;
@synthesize bootParams;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.rootViewController = [[XRootViewController alloc] init];
        self.analyzer = [[XAnalyzer alloc] init];

        // 加载系统配置信息
        BOOL ret = [[XConfiguration getInstance] loadConfiguration];
        if (ret)
        {
            // 由于初始化操作比较耗时，所以这里使用performSelectorOnMainThread进行异步调用
            [self performSelectorOnMainThread:@selector(doInitialization) withObject:nil waitUntilDone:NO];
        }
        else
        {
            NSError *anError = [[NSError alloc] initWithDomain:@"xface" code:0
                                                      userInfo:@{NSLocalizedDescriptionKey:@"Failed to load config.xml!"}];
            [self showErrorAlert:anError];
        }
    }
    return self;
}

- (void)pushNotification:(NSDictionary *)userInfo
{
    if (self.pushDelegate) {
        [self.pushDelegate fire:[userInfo JSONString]];
    }
}

/**
  进行runtime的初始化操作，然后启动应用
 */
- (void) doInitialization
{
    // try to register push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];

    //执行检测更新
    self->appUpdater = [[XAppUpdater alloc] init];
    [self->appUpdater run];

    self.systemBootstrap = [XSystemBootstrapFactory createWithDelegate:self];
    [self.systemBootstrap prepareWorkEnvironment];
}

-(void) handleOpenURL:(NSString *)url
{
    NSString *params = nil;
    NSRange range = [url rangeOfString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];
    if(NSNotFound != range.location)
    {
        params = [url substringFromIndex:(range.location + range.length)];
    }

    [self setBootParams:params];

    // TODO:兼容PG
}

-(void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [XUtils setValueToDataForKey:XFACE_DATA_KEY_DEVICETOKEN value:deviceToken];
}

#pragma mark XSystemBootstrapDelegate

//系统环境准备好了之后继续初始化
-(void) didFinishPreparingWorkEnvironment
{
    [self initialize];
}

//系统环境准备失败
-(void)didFailToPrepareEnvironmentWithError:(NSError *)error
{
    [self showErrorAlert:error];
}

#pragma mark Privates

-(void) initialize
{
    // Initialize components
    self.appManagement = [[XAppManagement alloc] initWithAmsDelegate:self];

    self.sysEventHandler = [[XSystemEventHandler alloc] initWithAppManagement:[self appManagement]];

    [self.systemBootstrap boot:self.appManagement];
}

-(void)showErrorAlert:(NSError *)error
{
    // 系统环境准备失败时,给出相应的提示信息
    NSString* msg = [NSString stringWithFormat:@"%@. %@", error.localizedDescription, SYSTEM_INITIALIZE_FAILED_ALERT_MESSAGE];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SYSTEM_INITIALIZE_FAILED_ALERT_TITLE message:msg delegate:nil cancelButtonTitle:SYSTEM_INITIALIZE_FAILED_ALERT_BUTTON_TITLE otherButtonTitles:nil];

    [alert show];
    return;
}

- (void) removeAppView:(id<XApplication>)app
{
    id<XAppView> appView = [app appView];
    // TODO:对app view进行缓存
    [self.rootViewController closeView:appView];
    [appView setValid:NO];
    [app setAppView:nil];
}

#pragma mark XAmsDelegate

-(void) startApp:(id<XApplication>)app
{
    NSAssert((app && ![app isActive]), nil);
    [self.rootViewController createView:app];

    [app load];

    [self.appManagement handleAppEvent:app event:kAppEventStart msg:nil];
}

-(void) closeApp:(id<XApplication>)app
{
    NSAssert([app isActive], nil);
    [self removeAppView:app];
    [self.appManagement handleAppEvent:app event:kAppEventClose msg:nil];
}

@end
