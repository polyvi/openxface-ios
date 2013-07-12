
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
//  XMessengerApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplicationTests.h"
#import "XMessenger.h"
#import "XJavaScriptEvaluator.h"
#import "XAppList.h"
#import "XJsCallback.h"
#import "XExtensionResult.h"
#import "XRuntime_Privates.h"
#import "XRuntime.h"
#import "XAppWebView.h"
#import "XApplication.h"

#define XMESSENGER_APPLICATION_TESTS_CALLBACK_ID    @"NetworkConnection0"
#define XMESSENGER_APPLICATION_TESTS_CALLBACK_KEY   @"XNetworkConnectionExt_getConnectionInfo:withDict:"
#define XMESSENGER_APPLICATION_TESTS_CALLBACK_JS    @"none"

@interface XMessengerApplicationTests : XApplicationTests
{
@private
    XMessenger *messenger;
    XJavaScriptEvaluator *jsEvaluator;
}
@end

@implementation XMessengerApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->messenger = [[XMessenger alloc] init];
    self->jsEvaluator = [[self app] jsEvaluator];

    STAssertNotNil(self->messenger, @"Failed to get XMessenger instance");
    STAssertNotNil(self->jsEvaluator, @"Failed to get XJavaScriptEvaluator instance");
}

- (void)testSendAsyncResultToMsgHandlerWhenAppNotRegistered
{
    NSString *callbackId  = XMESSENGER_APPLICATION_TESTS_CALLBACK_ID;
    NSString *callbackKey = XMESSENGER_APPLICATION_TESTS_CALLBACK_KEY;
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    STAssertNoThrow([self->messenger sendAsyncResult:jsCallback toMsgHandler:self->jsEvaluator], nil);
}

- (void)testSendAsyncResultToMsgHandlerWithNilResult
{
    NSString *callbackId  = XMESSENGER_APPLICATION_TESTS_CALLBACK_ID;
    NSString *callbackKey = XMESSENGER_APPLICATION_TESTS_CALLBACK_KEY;
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];
    [jsCallback setJsScript:XMESSENGER_APPLICATION_TESTS_CALLBACK_JS];

    [[self app] registerJsCallback:callbackKey withCallback:jsCallback];
    STAssertNoThrow([self->messenger sendAsyncResult:jsCallback toMsgHandler:self->jsEvaluator], nil);
}

- (void)testSendAsyncResultToMsgHandlerNormal
{
    NSString *callbackId  = XMESSENGER_APPLICATION_TESTS_CALLBACK_ID;
    NSString *callbackKey = XMESSENGER_APPLICATION_TESTS_CALLBACK_KEY;
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    [[self app] registerJsCallback:callbackKey withCallback:jsCallback];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:@"none"];
    [result setKeepCallback:YES];
    [jsCallback setExtensionResult:result];

    STAssertNoThrow([self->messenger sendAsyncResult:jsCallback toMsgHandler:self->jsEvaluator], nil);
}

@end
