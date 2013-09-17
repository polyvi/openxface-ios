
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
//  XPushNotificationExt.m
//  xFaceLib
//
//

#ifdef __XPushNotificationExt__

#import "XPushNotificationExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XQueuedMutableArray.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XApplication.h"
#import "XAppInfo.h"

@interface XPushNotificationExt()

@property (nonatomic, strong) NSMutableSet *registeredApps;

@end // end of private

@implementation XPushNotificationExt

@synthesize registeredApps;

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self.registeredApps = [[NSMutableSet alloc] init];

        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        XRuntime *runtime = [appDelegate performSelector:@selector(runtime)];
        runtime.pushDelegate = self;
    }

    return self;
}

- (void)getDeviceToken:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    XExtensionResult *result = nil;

    NSData *deviceToken = (NSData *)[XUtils getValueFromDataForKey:XFACE_DATA_KEY_DEVICETOKEN];
    if (deviceToken) {
        // NSData ==> hex string
        NSString *tokenString = [deviceToken description];
        tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
        // success callback
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:tokenString];
        [callback setExtensionResult:result];
    } else {
        // error callback
        result = [XExtensionResult resultWithStatus:STATUS_ERROR];
        [callback setExtensionResult:result];
    }

    [jsEvaluator eval:callback];
}

- (void)registerOnReceivedListener:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    id<XApplication> app = [self getApplication:options];
    [registeredApps addObject:app];
}

- (void)fire:(NSString *)pushString
{
    XJsCallback *callback = [[XJsCallback alloc] init];
    [callback setJsScript:[NSString stringWithFormat:@"xFace.require('xFace/extension/PushNotification').fire('%@');", pushString]];
    [jsEvaluator eval:callback];
}

@end

#endif
