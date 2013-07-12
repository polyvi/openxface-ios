
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
//  XNotificationExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XNotificationExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"
#import "XApplication.h"

@interface XNotificationExtApplicationTests : XApplicationTests
{
    @private
    XNotificationExt* notificationExt;
}
@end

@implementation XNotificationExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->notificationExt = [[XNotificationExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->notificationExt, @"Failed to create notification extension instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}

- (void)testAlert
{
    //创建测试环境
    NSString *callbackId = @"Notification0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"alert"];
    NSString* content = @"alert message";
    NSString* title = @"alert title";
    NSString* button = @"alert button";
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    [arguments addObject:content];
    [arguments addObject:title];
    [arguments addObject:button];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    //正常参数测试
    STAssertNoThrow([self->notificationExt alert:arguments withDict:options], nil);
    STAssertNoThrow([self->notificationExt alert:nil withDict:nil], nil);
    //异常参数测试
    [arguments replaceObjectAtIndex:0 withObject:@""];//alert内容为空
    STAssertNoThrow([self->notificationExt alert:arguments withDict:options], nil);
}

- (void)testConfirm
{
    //创建测试环境
    NSString *callbackId = @"Notification0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"confirm"];
    NSString* content = @"confirm message";
    NSString* title = @"confirm title";
    NSString* button = @"confirm button";
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    [arguments addObject:content];
    [arguments addObject:title];
    [arguments addObject:button];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    //正常参数测试
    STAssertNoThrow([self->notificationExt confirm:arguments withDict:options], nil);
    STAssertNoThrow([self->notificationExt confirm:nil withDict:nil], nil);
    //异常参数测试
    [arguments replaceObjectAtIndex:0 withObject:@""];//confirm内容为空
    STAssertNoThrow([self->notificationExt confirm:arguments withDict:options], nil);
}

- (void)testVibrate
{
    STAssertNoThrow([self->notificationExt vibrate:nil withDict:nil], nil);
}

- (void) testAlertViewClickedButtonAtIndex
{
    NSString *callbackId = @"Notification0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"alert"];
    XAlertView *alertView = [[XAlertView alloc]
                             initWithTitle:@"alert"
                             message:@"alert message"
                             delegate:self
                             cancelButtonTitle:nil
                             otherButtonTitles:nil];

    alertView.callback = callback;
    STAssertNoThrow([self->notificationExt alertView:alertView clickedButtonAtIndex:0], nil);
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsInt:1];
    STAssertEqualObjects([result status], [[callback getXExtensionResult] status], nil);
    STAssertEqualObjects([result message], [[callback getXExtensionResult] message], nil);
}

- (void)testBeep
{
    STAssertNoThrow([self->notificationExt beep:nil withDict:nil], nil);
}

@end
