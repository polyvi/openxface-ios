
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
//  XTelephonyExtLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XTelephonyExt.h"
#import "XTelephonyExt_Privates.h"
#import "XJsCallback.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XAppInfo.h"
#import "XApplicationFactory.h"

@interface XTelephonyExtLogicTests: SenTestCase

@end

@implementation XTelephonyExtLogicTests

- (void) testInitWithMsgHandler
{
    XJavaScriptEvaluator *msgHandler = [[XJavaScriptEvaluator alloc] init];
    XTelephonyExt *telephony = [[XTelephonyExt alloc] initWithMsgHandler:msgHandler];
    STAssertNotNil(telephony,nil);
}

- (void) testInitiateVoiceCall
{
    XJavaScriptEvaluator *msgHandler = [[XJavaScriptEvaluator alloc] init];
    XTelephonyExt *telephony = [[XTelephonyExt alloc] initWithMsgHandler:msgHandler];
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([XTelephonyExt class]) withMethod:NSStringFromSelector(@selector(initiateVoiceCall:withDict:))];
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:@"Telephony0" withCallbackKey:callbackKey];
    NSString *phoneNumber = @"114";
    id<XApplication> app = [XApplicationFactory create:[[XAppInfo alloc] init]];
    [app registerJsCallback:callbackKey withCallback:callback];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    [arguments addObject:phoneNumber];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    app, APPLICATION_KEY, nil];
    [telephony initiateVoiceCall:arguments withDict:options];
}

- (void) testIsTelePhoneNumber
{
    XJavaScriptEvaluator *msgHandler = [[XJavaScriptEvaluator alloc] init];
    XTelephonyExt *telephony = [[XTelephonyExt alloc] initWithMsgHandler:msgHandler];
    STAssertNotNil(telephony,nil);

    STAssertTrue([telephony isTelePhoneNumber:@"10086"], nil);
    STAssertTrue([telephony isTelePhoneNumber:@"+10086"], nil);
    STAssertTrue([telephony isTelePhoneNumber:@"100#86"], nil);
    STAssertTrue([telephony isTelePhoneNumber:@"1008*6"], nil);
    STAssertTrue([telephony isTelePhoneNumber:@"10#08*6"], nil);
    STAssertTrue([telephony isTelePhoneNumber:@"10#0+8*6"], nil);
    STAssertFalse([telephony isTelePhoneNumber:@"abcabcdefdef"], nil);
    STAssertFalse([telephony isTelePhoneNumber:@"11c2fd"], nil);
    STAssertFalse([telephony isTelePhoneNumber:@"010-ab2d3f4"], nil);
    STAssertFalse([telephony isTelePhoneNumber:@""], nil);
}

@end
