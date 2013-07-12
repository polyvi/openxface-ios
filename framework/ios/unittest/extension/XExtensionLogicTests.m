
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
//  XExtensionLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XExtension.h"
#import "XAppList.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XApplication.h"
#import "XApplicationFactory.h"


#define XEXTENSION_LOGIC_TESTS_CALLBACK_ID    @"NetworkConnection0"
#define XEXTENSION_LOGIC_TESTS_CALLBACK_KEY   @"XNetworkConnectionExt_getConnectionInfo:withDict:"

@interface XExtensionLogicTests : SenTestCase
{
@private
    XExtension *extension;
}
@end

@implementation XExtensionLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XJavaScriptEvaluator *jsEvaluator = webApp.jsEvaluator;
    self->extension = [[XExtension alloc] initWithMsgHandler:jsEvaluator];
    STAssertNotNil(self->extension, @"Failed to create rootViewController instance");
}

- (void)testInitWithMsgHandler
{
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XJavaScriptEvaluator *jsEvaluator = webApp.jsEvaluator;
    XExtension *ext = [[XExtension alloc] initWithMsgHandler:jsEvaluator];

    STAssertNotNil(ext, nil);
}

- (void)testSendAsyncResult
{
    NSString *callbackId  = XEXTENSION_LOGIC_TESTS_CALLBACK_ID;
    NSString *callbackKey = XEXTENSION_LOGIC_TESTS_CALLBACK_KEY;
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    STAssertNoThrow([self->extension sendAsyncResult:jsCallback], nil);
}

- (void)testSendAsyncResultNoThrow
{
    STAssertNoThrow([self->extension sendAsyncResult:nil], nil);
}

- (void)testShouldRunInBackground
{
    BOOL ret = [self->extension shouldExecuteInBackground:nil];
    STAssertFalse(ret,nil);
}

@end
