
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
//  XAmsExt.m
//  xFace
//
//

#import "XAmsExt.h"
#import "XAms.h"
#import "XAppInstallListener.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XAppList.h"
#import "XConfiguration.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XJsCallback.h"
#import "XAmsExt_Privates.h"
#import "XQueuedMutableArray.h"

// 定义构造ExtResult使用的key常量
#define EXTENSION_RESULT_APP_ID             @"appid"
#define EXTENSION_RESULT_APP_NAME           @"name"
#define EXTENSION_RESULT_APP_ICON           @"icon"
#define EXTENSION_RESULT_APP_ICON_BGCOLOR   @"icon_background_color"
#define EXTENSION_RESULT_APP_VERSION        @"version"
#define EXTENSION_RESULT_APP_TYPE           @"type"
#define EXTENSION_RESULT_APP_WIDTH          @"width"
#define EXTENSION_RESULT_APP_HEIGHT         @"height"

@implementation XAmsExt

- (id)init:(id<XAms>)amsObj withMessenger:(XMessenger *)msger withMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self) {
        self->ams = amsObj;
        self->messenger = msger;
    }
    return self;
}

- (void) installApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString *pkgPath= [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* appId = [app getAppId];

    // 实现应用的异步安装功能
    NSArray *installArgs = [self buildArgsWithOperationType:INSTALL packagePath:pkgPath appId:appId callback:callback];
    [XUtils performSelectorInBackgroundWithTarget:self->ams selector:@selector(installApp:) withObject:installArgs];
}

- (void) updateApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    id<XApplication> app = [self getApplication:options];
    NSString* appId = [app getAppId];
    NSString *pkgPath= [arguments objectAtIndex:0];

    // 实现应用的异步更新功能
    NSArray *updateArgs = [self buildArgsWithOperationType:UPDATE packagePath:pkgPath appId:appId callback:callback];
    [XUtils performSelectorInBackgroundWithTarget:self->ams selector:@selector(updateApp:) withObject:updateArgs];
}

- (void) uninstallApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString *appId = [arguments objectAtIndex:0];

    // 实现应用的异步卸载功能
    NSArray *uninstallArgs = [self buildArgsWithOperationType:UNINSTALL packagePath:nil appId:appId callback:callback];
    [XUtils performSelectorInBackgroundWithTarget:self->ams selector:@selector(uninstallApp:) withObject:uninstallArgs];
    return;
}

- (void) startApplication:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString *appId = [arguments objectAtIndex:0];
    NSString *params = [arguments objectAtIndex:1 withDefault:nil];

    BOOL successful = [self->ams startApp:appId withParameters:params];
    STATUS status = successful ? STATUS_OK : STATUS_ERROR;
    XExtensionResult *result = [XExtensionResult resultWithStatus:status messageAsObject:appId];
    [callback setExtensionResult:result];

    // 将扩展结果返回给js端
    [self->jsEvaluator eval:callback];
}

- (void) listInstalledApplications:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    // 组装扩展结果，结果中不包括默认应用
    XAppList *appList = [self->ams getAppList];
    @synchronized(appList)
    {
        XJsCallback *callback = [self getJsCallback:options];
        NSEnumerator *enumerator = [appList getEnumerator];
        id<XApplication> app = nil;

        NSMutableArray *message = [NSMutableArray arrayWithCapacity:1];
        while ((app = [enumerator nextObject]))
        {
            if (![app.getAppId isEqualToString:appList.defaultAppId])
            {
                [message addObject:[self translateAppInfoToDictionary:app]];
            }
        }

        XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:message];
        [callback setExtensionResult:result];

        // 将扩展结果返回给js端
        [self->jsEvaluator eval:callback];
    }
}

- (void) listPresetAppPackages:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSMutableArray *packageNames = [self->ams getPresetAppPackages];
    if(!packageNames)
    {
        packageNames = [[NSMutableArray alloc] init];
    }

    // 将包名转换为相对路径（相对于app workspace）
    const int count = [packageNames count];
    for(int i = 0; i < count; i++)
    {
        NSString *packageName = [packageNames objectAtIndex:i];
        NSString *relativePath = [PRE_SET_DIR_NAME stringByAppendingPathComponent:packageName];
        [packageNames replaceObjectAtIndex:i withObject:relativePath];
    }

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:packageNames];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (void) getStartAppInfo:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    XJsCallback *callback = [self getJsCallback:options];
    id<XApplication> defaultApp = [[ams getAppList] getDefaultApp];
    NSDictionary *infoDict = [self translateAppInfoToDictionary:defaultApp];
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:infoDict];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

#pragma mark private methods

- (NSArray *) buildArgsWithOperationType:(OPERATION_TYPE)type packagePath:(NSString *)pkgPath appId:(NSString *)appId callback:(XJsCallback *)callback
{
    XAppList *appList = [self->ams getAppList];
    id<XApplication> app = [appList getAppById:appId];

    id<XInstallListener> listener = [[XAppInstallListener alloc] initWithMessenger:self->messenger messageHandler:self->jsEvaluator callback:callback];

    NSArray *args = nil;
    switch (type) {
        case INSTALL:
        case UPDATE:
            args = [NSArray arrayWithObjects:app, pkgPath, listener, nil];
            break;
        case UNINSTALL:
            args = [NSArray arrayWithObjects:appId, listener, nil];
            break;
        default:
            NSAssert(NO, nil);
            break;
    }
    return args;
}

- (NSDictionary *) translateAppInfoToDictionary:(id<XApplication>)app
{
    XAppInfo* info = app.appInfo;
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:7];
    [item setObject:CAST_TO_NSNULL_IF_NIL([info appId]) forKey:EXTENSION_RESULT_APP_ID];
    [item setObject:CAST_TO_NSNULL_IF_NIL([info name]) forKey:EXTENSION_RESULT_APP_NAME];
    [item setObject:CAST_TO_NSNULL_IF_NIL([info version]) forKey:EXTENSION_RESULT_APP_VERSION];
    [item setObject:CAST_TO_NSNULL_IF_NIL([info type]) forKey:EXTENSION_RESULT_APP_TYPE];
    [item setObject:[NSNumber numberWithInt:[info width]] forKey:EXTENSION_RESULT_APP_WIDTH];
    [item setObject:[NSNumber numberWithInt:[info height]] forKey:EXTENSION_RESULT_APP_HEIGHT];

    [item setObject:CAST_TO_NSNULL_IF_NIL([app getIconURL]) forKey:EXTENSION_RESULT_APP_ICON];
    [item setObject:CAST_TO_NSNULL_IF_NIL(info.iconBgColor) forKey:EXTENSION_RESULT_APP_ICON_BGCOLOR];
    return item;
}

@end
