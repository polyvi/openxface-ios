
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
//  XLightweightSystemBootstrap.m
//  xFaceLib
//
//

#import "XLightweightSystemBootstrap.h"
#import "XLightweightSystemBootstrap_Privates.h"
#import "XConfiguration.h"
#import "XAppManagement.h"
#import "XAppPreinstallListener.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XFileUtils.h"
#import "XAppManagement.h"
#import "XFileUtils.h"
#import "iToast.h"
#import "XAmsImpl.h"
#import "XAmsExt.h"
#import "XExtensionManager.h"
#import "XMessenger.h"

@implementation XLightweightSystemBootstrap

@synthesize bootDelegate;
@synthesize isIpaUpdated;

-(void) prepareWorkEnvironment
{
    BOOL ret = YES;
    NSString* errorDescription = [[NSString alloc] init];

    // ipa包版本更新时，记录ipa版本到userDefaults中
    if ((self.isIpaUpdated = [self ipaUpdated]))
    {
        [self saveIpaVersion];
    }

    // 准备系统工作空间
    if (ret && (NO == (ret = [[XConfiguration getInstance] prepareSystemWorkspace])))
    {
        errorDescription= @"Failed to prepare system workspace!";
    }

    if (ret)
    {
        [[self bootDelegate] didFinishPreparingWorkEnvironment];
    }
    else
    {
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : errorDescription};
        NSError *anError = [[NSError alloc] initWithDomain:@"xface" code:0 userInfo:errorDictionary];
        [[self bootDelegate] didFailToPrepareEnvironmentWithError:anError];
    }
}

-(void) boot:(XAppManagement*)appManagement
{
    if ([self isIpaUpdated])
    {
        [self preinstallInBackground:appManagement];
    }
    else
    {
        [self startDefaultApp:appManagement];
    }
}

- (void) preinstallInBackground:(XAppManagement *)appManagement
{
    // 异步安装所有预置应用
    [XUtils performSelectorInBackgroundWithTarget:self selector:@selector(preinstall:)
                                       withObject:appManagement];
}

#pragma mark Privates

- (BOOL) ipaUpdated
{
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:BUNDLE_VERSION_KEY];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedVersion = [defaults objectForKey:USER_DEFAULTS_SAVED_VERSION_KEY];

    // 版本号不同即认为ipa更新
    BOOL ret = [currentVersion isEqualToString:savedVersion];
    return !ret;
}

- (void) saveIpaVersion
{
    // TODO:考虑数据安全问题
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:BUNDLE_VERSION_KEY];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:currentVersion forKey:USER_DEFAULTS_SAVED_VERSION_KEY];
    [defaults synchronize];
    return;
}

- (void) preinstall:(XAppManagement *)appManagement
{
    id<XInstallListener> listener = [[XAppPreinstallListener alloc] init:appManagement];

    NSString *defaultAppId = nil;
    NSMutableArray *preinstallApps = [[XConfiguration getInstance] preinstallApps];
    NSAssert((nil != preinstallApps), nil);

    for (NSString *appId in preinstallApps)
    {
        //NOTE:此处的实现约定应用源码目录名与appId一致
        NSString *preinstallAppSrcPath = [XUtils buildPreinstalledAppSrcPath:appId];

        if ([[appManagement appList] containsApp:appId])
        {
            [appManagement updateApp:preinstallAppSrcPath withListener:listener];
        }
        else
        {
            [appManagement installApp:preinstallAppSrcPath withListener:listener];
        }

        if (!defaultAppId && [[appManagement appList] containsApp:appId])
        {
            defaultAppId = appId;
        }
    }

    if (!defaultAppId)
    {
        XLogE(@"Failed to preinstall default app, please verify app config file exists!");
        [[[[iToast makeText:@"Failed to preinstall default app, please verify app config file exists!"] setGravity:iToastGravityCenter] setDuration:iToastDurationLong] show];
        return;
    }

    NSString *originalDefaultAppId = [[appManagement appList] defaultAppId];
    if (!originalDefaultAppId)
    {
        @synchronized(appManagement)
        {
            [appManagement markAsDefaultApp:defaultAppId];
        }
    }
    else if (![defaultAppId isEqualToString:originalDefaultAppId])
    {
        XLogE(@"Cannot update the default app with a different app id!");
        [[[[iToast makeText:@"Cannot update the default app with a different app id!"] setGravity:iToastGravityCenter] setDuration:iToastDurationLong] show];
    }

    // 通知主线程，所有预置应用已经安装完成
    [self performSelectorOnMainThread:@selector(onPostPreinstall:)
                           withObject:appManagement waitUntilDone:YES];
    return;
}

- (void) onPostPreinstall:(XAppManagement *)appManagement
{
    [self startDefaultApp:appManagement];
}

- (void) startDefaultApp:(XAppManagement *)appManagement
{
    // 为defaultApp注册ams扩展
    XAppList *appList = [appManagement appList];
    NSString *defaultAppId = [[appManagement appList] defaultAppId];
    id<XApplication> defaultApp = [appList getAppById:defaultAppId];
    XAmsImpl *amsImpl = [[XAmsImpl alloc] init:appManagement];
    XAmsExt *amsExt = [[XAmsExt alloc] init:amsImpl withMessenger:[[XMessenger alloc] init] withMsgHandler:defaultApp.jsEvaluator];
    [defaultApp.extMgr registerExtension:amsExt withName:EXTENSION_AMS_NAME];

    // TODO:处理启动参数中的appId
    NSString *params = [[self bootDelegate] bootParams];
    BOOL ret = [appManagement startDefaultAppWithParams:params];
    if (!ret)
    {
        [[[[iToast makeText:@"Failed to start default app, please verify the default app is installed!"] setGravity:iToastGravityCenter] setDuration:iToastDurationLong] show];
    }
    return;
}

@end
