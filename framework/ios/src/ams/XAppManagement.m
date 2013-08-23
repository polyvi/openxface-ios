
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
//  XAppManagement.m
//  xFace
//
//

#import "XAppManagement.h"
#import "XApplication.h"
#import "XAmsDelegate.h"
#import "XAppInstaller.h"
#import "XAppList.h"
#import "NSMutableArray+XStackAdditions.h"
#import "XJavaScriptEvaluator.h"
#import "XAppManagement_Privates.h"
#import "XJsCallback.h"
#import "XAppInfo.h"
#import "XConstants.h"
#import "XApplicationPersistence.h"
#import "XLightweightAppInstaller.h"
#import "XUtils.h"
#import "NSString+XStartParams.h"
#import "iToast.h"

#define jsForFireAppEvent(event, arg) [NSString stringWithFormat:\
                      @"(function() { \
                      try { \
                          xFace.require('xFace/app').fireAppEvent(\'%@\'%@); \
                        } catch (e) { \
                            console.log('exception in fireAppEvent:' + e);\
                        } \
                    })()",\
                    event, arg];


@implementation XAppManagement

@synthesize amsDelegate;
@synthesize activeApps;
@synthesize appList;
@synthesize appPersistence;

- (id)initWithAmsDelegate:(id<XAmsDelegate>) delegate
{
    self = [super init];
    if (self) {
        self.amsDelegate = delegate;
        self.appList = [[XAppList alloc] init];
        self.appPersistence = [[XApplicationPersistence alloc] init];

        self->appInstaller = [[XAppInstaller alloc] initWithAppList:[self appList] appPersistence:[self appPersistence]];
        self->lightweightAppInstaller = [[XLightweightAppInstaller alloc] initWithAppList:[self appList] appPersistence:[self appPersistence]];

        [self.appPersistence readAppsFromConfig:[self appList]];
        self.activeApps = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xAppClose:)
                                                     name:XAPPLICATION_CLOSE_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xAppSendMessage:)
                                                     name:XAPPLICATION_SEND_MESSAGE_NOTIFICATION object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) installApp:(NSString *)resPath withListener:(id<XInstallListener>)listener
{
    if ([self shouldUseLightweightInstaller:resPath])
    {
        [self->lightweightAppInstaller install:resPath withListener:listener];
    }
    else
    {
        [self->appInstaller install:resPath withListener:listener];
    }
}

- (void) uninstallApp:(NSString *)appId withListener:(id<XInstallListener>)listener
{
    [self->appInstaller uninstall:appId withListener:listener];
}

- (void) updateApp:(NSString *)resPath withListener:(id<XInstallListener>)listener
{
    if ([self shouldUseLightweightInstaller:resPath])
    {
        [self->lightweightAppInstaller update:resPath withListener:listener];
    }
    else
    {
        [self->appInstaller update:resPath withListener:listener];
    }
}

- (BOOL) verifyAppConfig:(id<XApplication>)app
{
    return YES;
}

- (void)checkAppRequiredEngineVersion:(NSString*)requiredVersion
{
    NSString* engineVersion = [XUtils getPreferenceForKey:ENGINE_VERSION];
    if ([engineVersion compare:requiredVersion] == NSOrderedAscending) {
        [[[iToast makeText:(@"The engine is older than what the app requires, Please update the engine to avoid potential issues.")] setDuration:iToastDurationNormal] show];
    }
}

- (BOOL) startApp:(NSString *)appId withParameters:(NSString *)params
{
    BOOL ret = NO;
    id<XApplication> app = [self.appList getAppById:appId];
    if (nil == app) {
        XLogE(@"Error:failed to start app, cannot find app by id: %@", appId);
        return ret;
    }

    if (![self verifyAppConfig:app])
    {
        XLogE(@"Error:failed to verify app config for app with id: %@", appId);
        return ret;
    }

    [self checkAppRequiredEngineVersion:app.appInfo.engineVersion];

    if ([app isNative])
    {
        ret = [app loadWithParameters:params];
    }
    else
    {
        // FIXME:对于active app,是否应该bringToTop?
        if (![app isActive])
        {
            [[self activeApps] push:app];

            if ([params.startPage length])
            {
                [[app appInfo] setEntry:params.startPage];
            }

            if ([params.data length])
            {
                // 设置启动参数
                [app setData:params.data forKey:APP_DATA_KEY_FOR_START_PARAMS];
            }
            [[self amsDelegate] startApp:app];
            ret = YES;
        }
    }

    return ret;
}

- (void) closeApp:(NSString *)appId
{
    id<XApplication> app = [self.appList getAppById:appId];
    if (nil == app) {
        XLogE(@"Error:failed to close app, cannot find app by id: %@", appId);
        return;
    }

    [[self amsDelegate] closeApp:app];
    [[self activeApps] removeObject:app];

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_DID_FINISH_CLOSE_NOTIFICATION object:app]];
}

- (BOOL) startDefaultAppWithParams:(NSString *)params
{
    NSString *defaultAppId = [[self appList] defaultAppId];

    //分离appId
    if ([params length] > 0) {
        NSString* query = [[NSURL URLWithString:params] query];
        params = [query length] >0 ? query : params;
    }

    //TODO:启动参数中指定的appid
    BOOL ret = [self startApp:defaultAppId withParameters:params];
    return ret;
}

- (void) markAsDefaultApp:(NSString *)appId
{
    [[self appList] markAsDefaultApp:appId];
    [[self appPersistence] markAsDefaultApp:appId];
}

- (BOOL) isDefaultApp:(NSString *)appId
{
    NSString *defaultAppId = [[self appList] defaultAppId];

    BOOL ret = [appId isEqualToString:defaultAppId];
    return ret;
}

-(void)handleAppEvent:(id<XApplication>)app event:(NSString*)event msg:(NSString*)msg
{
    NSString* arg = [kAppEventMessage isEqualToString:event] ?
                    [@"," stringByAppendingString:msg] : @"";
    NSString *jsString = jsForFireAppEvent(event, arg);

    XJsCallback *callback = [[XJsCallback alloc] init];
    [callback setJsScript:jsString];
    BOOL isDefaultApp = [self isDefaultApp: [app getAppId]];
    id<XApplication> defaultApp = [[self appList] getDefaultApp];

    if ([kAppEventMessage isEqualToString:event]) {
    if (isDefaultApp)
    {
            [[self activeApps] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 id<XApplication> targetApp = obj;
                 if (![self isDefaultApp:[targetApp getAppId]])
                 {
                     [targetApp.jsEvaluator eval:callback];
                 }
             }];
        }
        else
        {
            // 普通应用向default app发送信息
            [defaultApp.jsEvaluator eval:callback];
        }
    }
    else if([kAppEventStart isEqualToString:event])
    {
        if (!isDefaultApp)
        {
            [[defaultApp jsEvaluator] eval:callback];
        }
    }
    else if([kAppEventClose isEqualToString:event])
    {
        [[defaultApp jsEvaluator] eval:callback];
    }
    else
    {
        XLogW(@"[%@] unknown event:%@", NSStringFromSelector(_cmd), event);
    }
}

- (void) closeAllApps
{
    while (0 != [[self activeApps] count])
    {
        id<XApplication> app = [[self activeApps] peek];
        [self closeApp:[app getAppId]];
    }
}

#pragma mark Privates

-(BOOL) shouldUseLightweightInstaller:(NSString *)resPath
{
    //当资源路径没有后缀名时，使用lightweight app installer
    BOOL ret = [[resPath pathExtension] length];
    return !ret;
}

- (void) xAppClose:(NSNotification*)notification
{
    id<XApplication> app  = [notification object];
    NSString *appId = [app getAppId];

    // 由于平台自身的特点，不允许通过js端关闭默认应用
    BOOL isDefaultApp = [self isDefaultApp:appId];
    if (isDefaultApp)
    {
        return;
    }

    [self closeApp:appId];
}

- (void) xAppSendMessage:(NSNotification*)notification
{
    NSString *msgId  = [[notification userInfo] objectForKey:@"msgId"];
    id<XApplication> app  = [notification object];
    [self handleAppEvent:app event:kAppEventMessage msg:msgId];
}

@end
