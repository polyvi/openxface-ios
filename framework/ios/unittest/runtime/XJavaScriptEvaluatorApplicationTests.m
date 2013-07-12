
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
//  XJavaScriptEvaluatorApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XJavaScriptEvaluator.h"
#import "XAppWebView.h"
#import "XRuntime_Privates.h"
#import "XRuntime.h"
#import "XApplication.h"
#import "XApplicationTests.h"
#import "XJsCallback.h"
#import "XExtensionResult.h"
#import "XConstantsLogicTests.h"

@interface XJavaScriptEvaluatorApplicationTests : XApplicationTests
{
@private
    XJavaScriptEvaluator *jsEvaluator;
}
@end

@implementation XJavaScriptEvaluatorApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->jsEvaluator = [[self app] jsEvaluator];
    STAssertNotNil(self->jsEvaluator, @"Failed to get XJavaScriptEvaluator instance");
}

- (void)testEvalWhenAppNotRegistered
{
    NSString *callbackId = @"NetworkConnection0";
    NSString *callbackKey = @"XNetworkConnectionExt_getConnectionInfo:withDict:";
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];


    STAssertNoThrow([self->jsEvaluator eval:jsCallback], nil);
}

- (void)testEvalWithNilExtensionResult
{
    NSString *callbackId  = @"NetworkConnection0";
    NSString *callbackKey = @"XNetworkConnectionExt_getConnectionInfo:withDict:";
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];
    [jsCallback setJsScript:@"none"];

    [[self app] registerJsCallback:callbackKey withCallback:jsCallback];

    STAssertNoThrow([self->jsEvaluator eval:jsCallback], nil);
}

- (void)testEvalNormal
{
    NSString *callbackId  = @"NetworkConnection0";
    NSString *callbackKey = @"XNetworkConnectionExt_getConnectionInfo:withDict:";
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    [[self app] registerJsCallback:callbackKey withCallback:jsCallback];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:@"none"];
    [result setKeepCallback:YES];
    [jsCallback setExtensionResult:result];

    STAssertNoThrow([self->jsEvaluator eval:jsCallback], nil);
}

- (void)testEvalWithInvalidCallbackId
{
    NSString *callbackId = INVALID_CALLBACK_ID;
    NSString *callbackKey = @"XNetworkConnectionExt_getConnectionInfo:withDict:";
    XJsCallback *jsCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    [[self app] registerJsCallback:callbackKey withCallback:jsCallback];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:@"none"];
    [result setKeepCallback:YES];
    [jsCallback setExtensionResult:result];

    STAssertNoThrow([self->jsEvaluator eval:jsCallback], nil);
}

@end

