
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
//  XJsCallbackLogicTests.m
//  xFaceLib
//
//

#import "SenTestingKit/SenTestingKit.h"
#import "XJsCallback.h"
#import "XExtensionResult.h"
#import "XConstantsLogicTests.h"

@interface XJsCallbackLogicTests : SenTestCase

@end

@implementation XJsCallbackLogicTests

- (void)testInitWithCallbackId
{
    NSString *callbackId = @"Callback_Id_1";
    NSString *callbackKey = @"Callback_Key_1";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];
    STAssertNotNil(callback, nil);
    STAssertEqualObjects(callbackId, [callback callbackId], nil);
    STAssertEqualObjects(callbackKey, [callback callbackKey], nil);
}

- (void)testGenCallbackScript
{
    NSString *callbackId = @"Callback_Id_1";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:nil];

    NSString *script = @"java script string";
    [callback setJsScript:script];
    STAssertEqualObjects(@"xFace.require('xFace/exec').nativeEvalAndFetch(function(){java script string})", [callback genCallbackScript], nil);
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK];
    [callback setExtensionResult:result];
    script = [result toCallbackString:callbackId];
    STAssertEqualObjects(@"xFace.require('xFace/exec').nativeCallback('Callback_Id_1',2,\"OK\",0)", [callback genCallbackScript], nil);
}

- (void)testGenCallbackScriptWithNilResult
{
    NSString *callbackId = INVALID_CALLBACK_ID;
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:nil];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK];
    [callback setExtensionResult:result];
    STAssertNil([callback genCallbackScript], nil);
}

@end
