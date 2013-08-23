
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
//  XApplication.m
//  xFace
//
//

#import "XWebApplication.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XAppView.h"
#import "XAppInfo.h"
#import "XUtils.h"
#import "XConfiguration.h"
#import "XAppRunningMode.h"
#import "XSecurityPolicyFactory.h"
#import "XWhitelist.h"
#import "XWebApplication_Privates.h"
#import "XExtensionManager.h"
#import "XJavaScriptEvaluator.h"
#import "XURLProtocol.h"
#import "XAppController.h"
#import "XHTTPSURLProtocol.h"
#import "XResourceURLProtocol.h"

@implementation XWebApplication

@synthesize appInfo;
@synthesize appView;
@synthesize mode;
@synthesize registeredCallbacks;
@synthesize whitelist;
@synthesize jsEvaluator;
@synthesize extMgr;
@synthesize appController;

+(void)initialize
{
    [NSURLProtocol registerClass:[XHTTPSURLProtocol class]];
    [NSURLProtocol registerClass:[XResourceURLProtocol class]];
}

- (id) initWithAppInfo:(XAppInfo *)applicationInfo
{
    self = [super init];
    if (self)
    {
        self.appInfo = applicationInfo;
        self.mode = [XAppRunningMode modeWithName:applicationInfo.runningMode app:self];
        self.registeredCallbacks = [NSMutableDictionary dictionaryWithCapacity:2];
        self.whitelist = [[XWhitelist alloc] initWithArray:[self.appInfo whitelistHosts]];
        self->data = [[NSMutableDictionary alloc] initWithCapacity:1];

        self.jsEvaluator = [[XJavaScriptEvaluator alloc] initWithApp:self];
        self.extMgr = [[XExtensionManager alloc] initWithApp:self];
        self.appController = [[XAppController alloc] initWithApp:self];
        [XURLProtocol registerApp:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xAppDidFinishClose:)
                                                     name:XAPPLICATION_DID_FINISH_CLOSE_NOTIFICATION object:self];
    }
    return self;
}

- (BOOL) load
{
    [self.mode loadApp:self policy:[XSecurityPolicyFactory createPolicy]];
    return YES;
}

- (NSString *) installedDirectory
{
    NSAssert((nil != [self getAppId]), nil);

    // 应用安装目录路径形如：~/Documents/xface3/apps/appId
    NSString *appsPath = [[XConfiguration getInstance] appInstallationDir];
    NSString *installedDir = [appsPath stringByAppendingPathComponent:[self getAppId]];

    return installedDir;
}

- (NSString *) getWorkspace
{
    // 应用工作空间路径形如：~/Documents/xface3/apps/appId/workspace
    NSString *appInstalledDir = [self installedDirectory];
    NSString *workspace = [appInstalledDir stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:workspace])
    {
        NSError * __autoreleasing error = nil;
        BOOL ret = [fileManager createDirectoryAtPath:workspace withIntermediateDirectories:YES attributes:nil error:&error];
        if(!ret)
        {
            XLogE(@"%@", [error localizedDescription]);
            workspace = nil;
        }
    }
    return workspace;
}

//TODO:该方法和getWorkspace基本类似，可以精简代码
- (NSString *) getDataDir
{
    // 应用数据目录路径形如：~/Documents/xface3/apps/appId/data
    NSString *appInstalledDir = [self installedDirectory];
    NSString *dataDir = [appInstalledDir stringByAppendingPathComponent:APP_DATA_DIR_FOLDER];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dataDir])
    {
        NSError * __autoreleasing error = nil;
        BOOL ret = [fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:&error];
        if(!ret)
        {
            XLogE(@"%@", [error localizedDescription]);
            dataDir = nil;
        }
    }
    return dataDir;
}

- (NSString *) getAppId
{
    NSAssert((nil != [self appInfo]), nil);
    return [[self appInfo] appId];
}

- (void) registerJsCallback:(NSString *)key withCallback:(XJsCallback *)callback
{
    NSMutableSet *callbackSet = [registeredCallbacks valueForKey:key];
    if(!callbackSet)
    {
        callbackSet = [NSMutableSet setWithCapacity:1];
        [registeredCallbacks setValue:callbackSet forKey:key];
    }
    [callbackSet addObject:callback];
}

- (void) unregisterJsCallback:(NSString *)key
{
    [registeredCallbacks removeObjectForKey:key];
}

- (NSSet *) getCallbackSet:(NSString *)key
{
    return [registeredCallbacks objectForKey:key];
}

- (void) clearJsCallbacks
{
    [registeredCallbacks removeAllObjects];
}

- (BOOL) isActive
{
    return (nil != [self appView]);
}

- (BOOL) isInstalled
{
    return YES;
}

- (BOOL) isNative
{
    return NO;
}

- (void) setData:(id)value forKey:(NSString *)key
{
    if (!key || !value)
    {
        return;
    }
    [self->data setObject:value forKey:key];
}

- (void) removeDataForKey:(NSString *)key
{
    if (!key)
    {
        return;
    }
    [self->data removeObjectForKey:key];
}

- (id) getDataForKey:(NSString *)key
{
    id value = [self->data objectForKey:key];
    return value;
}

-(NSURL*) getURL
{
    return [self.mode getURL:self];
}

-(id) getResourceIterator
{
    return [self.mode getResourceIterator:self];
}

- (RUNNING_MODE) getRunningMode
{
    return self.mode.mode;
}

- (NSString*) getIconURL
{
    return [self.mode getIconURL:[self appInfo]];
}

-(void) setAppView:(id<XAppView>)view
{
    appView = view;
    if (view != nil) {
        ((UIWebView*)self.appView).delegate = self.appController;
    }
}

- (void)dealloc
{
    [XURLProtocol unregisterApp:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark app event

- (void) xAppDidFinishClose:(NSNotification*)notification
{
    NSAssert(self == [notification object] , nil);
    [self->extMgr onAppClosed:[self getAppId]];
}

@end
