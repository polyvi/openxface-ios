
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
//  XAppInstallListener.m
//  xFace
//
//

#import "XAppInstallListener.h"
#import "XExtensionResult.h"
#import "XMessenger.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XJsCallback.h"

// 定义构造ExtResult使用的key常量
#define EXTENSION_RESULT_APP_ID         @"appid"
#define EXTENSION_RESULT_ERROR_CODE     @"errorcode"
#define EXTENSION_RESULT_PROGRESS       @"progress"
#define EXTENSION_RESULT_ACTION_TYPE    @"type"

// 定义构造ExtResult使用的value常量
#define EXTENSION_RESULT_VALUE_NO_ID    @"noId"

@implementation XAppInstallListener

- (id)initWithMessenger:(XMessenger *)msger messageHandler:(XJavaScriptEvaluator *)msgHandler callback:(XJsCallback *)callback
{
    self = [super init];
    if (self) {
        self->messenger = msger;
        self->jsEvaluator = msgHandler;
        self->jsCallback = callback;
    }
    return self;
}

#pragma mark XInstallListener

- (void) onProgressUpdated:(OPERATION_TYPE)type withStatus:(PROGRESS_STATUS)progressStatus
{
    // 将type与progressStatus作为message返回给js端，并通知js端有进度事件发生
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:2];
    [message setObject:[NSNumber numberWithInt:type] forKey:EXTENSION_RESULT_ACTION_TYPE];
    [message setObject:[NSNumber numberWithInt:progressStatus] forKey:EXTENSION_RESULT_PROGRESS];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_PROGRESS_CHANGING messageAsObject:message];

    // 由于还需执行后续的onSuccess或onError,故需做此标记以通知js端保留之前设置的回调
    [result setKeepCallback:YES];
    [self->jsCallback setExtensionResult:result];

    // 需要保证process进度显示准确，这里同步发送结果给js端
    [self->messenger sendSyncResult:self->jsCallback toMsgHandler:self->jsEvaluator];
}

- (void) onSuccess:(OPERATION_TYPE)type withAppId:(NSString *)appId
{
    NSAssert([appId length], nil);

    // 将type与app id作为message返回给js端，并通知js端操作执行成功
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:2];
    [message setObject:[NSNumber numberWithInt:type] forKey:EXTENSION_RESULT_ACTION_TYPE];
    [message setObject:appId forKey:EXTENSION_RESULT_APP_ID];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:message];
    [self->jsCallback setExtensionResult:result];

    [self->messenger sendAsyncResult:self->jsCallback toMsgHandler:self->jsEvaluator];
}

- (void) onError:(OPERATION_TYPE)type withAppId:(NSString *)appId withError:(AMS_ERROR)error
{
    // 将type，app id与error code作为message返回给js端，并通知js端操作执行失败
    if (![appId length])
    {
        appId = EXTENSION_RESULT_VALUE_NO_ID;
    }
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:3];
    [message setObject:[NSNumber numberWithInt:type] forKey:EXTENSION_RESULT_ACTION_TYPE];
    [message setObject:appId forKey:EXTENSION_RESULT_APP_ID];
    [message setObject:[NSNumber numberWithInt:error] forKey:EXTENSION_RESULT_ERROR_CODE];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:message];
    [self->jsCallback setExtensionResult:result];

    [self->messenger sendAsyncResult:self->jsCallback toMsgHandler:self->jsEvaluator];
}

@end
