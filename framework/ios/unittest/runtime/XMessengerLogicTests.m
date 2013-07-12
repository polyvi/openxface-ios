
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
//  XMessengerLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XMessenger.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XExtensionResult.h"
#import "XApplication.h"
#import "XApplicationFactory.h"

#define XMESSENGER_LOGIC_TESTS_CALLBACK_ID    @"NetworkConnection0"
#define XMESSENGER_LOGIC_TESTS_CALLBACK_KEY   @"XNetworkConnectionExt_getConnectionInfo:withDict:"

@interface XMessengerLogicTests : SenTestCase
{
@private
    XMessenger *messenger;
    XJavaScriptEvaluator *jsEvaluator;
}
@end

@implementation XMessengerLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->messenger = [[XMessenger alloc] init];
    STAssertNotNil(self->messenger, @"Failed to create XMessenger instance");
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    self->jsEvaluator = webApp.jsEvaluator;
    STAssertNotNil(self->jsEvaluator, @"Failed to create XJavaScriptEvaluator instance");
}

- (void)testSendAsyncResultToMsgHandlerWithNilArgs
{
    STAssertNoThrow([self->messenger sendAsyncResult:nil toMsgHandler:nil], nil);
}

- (void)testSendAsyncResultToMsgHandlerWhenAppInvalid
{
    NSString *callbackId  = XMESSENGER_LOGIC_TESTS_CALLBACK_ID;
    NSString *callbackKey = XMESSENGER_LOGIC_TESTS_CALLBACK_KEY;
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];
    STAssertNoThrow([self->messenger sendAsyncResult:jsCallback toMsgHandler:self->jsEvaluator], nil);
}

- (void)testSendSyncResultWithNoThrow
{
    NSString *callbackId  = XMESSENGER_LOGIC_TESTS_CALLBACK_ID;
    NSString *callbackKey = XMESSENGER_LOGIC_TESTS_CALLBACK_KEY;
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    STAssertNoThrow([self->messenger sendSyncResult:jsCallback toMsgHandler:self->jsEvaluator], nil);
}

@end
