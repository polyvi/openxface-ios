/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  XExtensionResultLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XExtensionResult.h"
#import "XExtensionResult_Privates.h"
#import "NSObject+JSONSerialization.h"

#define XEXTENTION_RESULT_LOGIC_TEST_INVALID_STATUS  ((STATUS)20)

@interface XExtensionResultLogicTests : SenTestCase

@end

@implementation XExtensionResultLogicTests

- (void)testInitWithStatusWithNilMessage
{
    XExtensionResult *result = [[XExtensionResult alloc] initWithStatus:STATUS_OK message:nil];

    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:STATUS_OK] isEqual:status], nil);
    STAssertTrue([[NSNull null] isEqual:message], nil);
}

- (void)testInitWithStatus
{
    NSString *msgString = @"message string";
    XExtensionResult *result = [[XExtensionResult alloc] initWithStatus:STATUS_OK message:msgString];

    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:STATUS_OK] isEqual:status], nil);
    STAssertTrue([msgString isEqual:message], nil);
}

- (void)testResultWithInvalidStatus
{
    STAssertThrows([XExtensionResult resultWithStatus:XEXTENTION_RESULT_LOGIC_TEST_INVALID_STATUS], nil);
}

- (void)testResultWithStatusOK
{
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:STATUS_OK] isEqual:status], nil);
    STAssertTrue([message isEqual:@"OK"], nil);
}

- (void)testResultWithStatusError
{
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_ERROR];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:STATUS_ERROR] isEqual:status], nil);
    STAssertTrue([message isEqual:@"Error"], nil);
}

- (void)testResultWithStatusMessageAsInt
{
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsInt:5];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *message = [dic objectForKey:@"message"];
    STAssertTrue([[NSNumber numberWithInt:5] isEqual:message], nil);
}

- (void)testResultWithStatusMessageAsDouble
{
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsDouble:5.5];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *message = [dic objectForKey:@"message"];
    STAssertTrue([[NSNumber numberWithDouble:5.5] isEqual:message], nil);
}

- (void)testResultWithStatusMessageAsArray
{
    NSArray *testValues = [NSArray arrayWithObjects:
                           [NSNull null],
                           @"string",
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithDouble:5.5],
                           [NSNumber numberWithBool:true],
                           nil];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:testValues];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSArray *message = [dic objectForKey:@"message"];

    STAssertTrue([message isKindOfClass:[NSArray class]], nil);
    STAssertTrue([testValues count] == [message count], nil);

    for (NSInteger i = 0; i < [testValues count]; i++)
    {
        STAssertTrue([[testValues objectAtIndex:i] isEqual:[message objectAtIndex:i]], nil);
    }
}

- (void) testDictionary:(NSDictionary*)dictA withDictionary:(NSDictionary*)dictB
{
    STAssertTrue([dictA isKindOfClass:[NSDictionary class]], nil);
    STAssertTrue([dictB isKindOfClass:[NSDictionary class]], nil);

    STAssertTrue([[dictA allKeys ]count] == [[dictB allKeys] count], nil);

    for (NSInteger i = 0; i < [dictA count]; i++)
    {
        id keyA =  [[dictA allKeys] objectAtIndex:i];
        id objA = [dictA objectForKey:keyA];
        id objB = [dictB objectForKey:keyA];

        STAssertTrue([[dictB allKeys] containsObject:keyA], nil);

        if ([objA isKindOfClass:[NSDictionary class]])
        {
            [self testDictionary:objA withDictionary:objB];
        }
        else
        {
            STAssertTrue([objA isEqual:objB], nil);
        }
    }
}

- (void) testResultWithStatusMessageAsDictionary
{
    NSMutableDictionary *testValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null], @"nullItem",
                                       @"string",  @"stringItem",
                                       [NSNumber numberWithInt:5],  @"intItem",
                                       [NSNumber numberWithDouble:5.5], @"doubleItem",
                                       [NSNumber numberWithBool:true],  @"boolItem",
                                       nil];

    NSDictionary *nestedDict = [testValues copy];
    [testValues setValue:nestedDict forKey:@"nestedDict"];

    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:testValues];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSDictionary *message = [dic objectForKey:@"message"];

    [self testDictionary:testValues withDictionary:message];
}

- (void)testResultWithStatusMessageAsStringContainingQuotes
{
    NSString *quotedString = @"\"quoted\"";
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:quotedString];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSString *message = [dic objectForKey:@"message"];
    STAssertTrue([quotedString isEqual:message], nil);
}

- (void)testResultWithStatusMessageAsStringThatIsNil
{
    NSString *nilString = nil;
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:nilString];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSString *message = [dic objectForKey:@"message"];
    STAssertTrue([[NSNull null] isEqual:message], nil);
}

- (void)testResultWithStatusMessageAsString
{
    NSString *msgString = @"message string";
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:msgString];
    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSString *message = [dic objectForKey:@"message"];
    STAssertTrue([msgString isEqual:message], nil);
}

- (void)testResultWithStatusMessageToErrorObject
{
	int errorCode = 1;
    NSDictionary* errDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:errorCode] forKey:@"code"];
	XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageToErrorObject:errorCode];
	NSDictionary *dic = [[result getJSONString] JSONObject];
	NSDictionary *test = [dic objectForKey:@"message"];
	STAssertTrue([test isEqual:errDict],nil);
}

- (void)testGetJSONString
{
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK];
    NSString *jsonStr = [result getJSONString];
    STAssertNotNil(jsonStr, nil);

    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:STATUS_OK] isEqual:status], nil);
    STAssertTrue([message isEqual:@"OK"], nil);
}

- (void)testGetJSONStringWithNilMessage
{
    XExtensionResult *result = [[XExtensionResult alloc] initWithStatus:STATUS_OK message:nil];
    NSString *jsonStr = [result getJSONString];
    STAssertNotNil(jsonStr, nil);

    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:STATUS_OK] isEqual:status], nil);
    STAssertTrue([[NSNull null] isEqual:message], nil);
}

- (void)testGetJSONStringWithInvalidStatusAndNilMessage
{
    XExtensionResult *result = [[XExtensionResult alloc] initWithStatus:XEXTENTION_RESULT_LOGIC_TEST_INVALID_STATUS message:nil];
    NSString *jsonStr = [result getJSONString];
    STAssertNotNil(jsonStr, nil);

    NSDictionary *dic = [[result getJSONString] JSONObject];
    NSNumber *status = [dic objectForKey:@"status"];
    NSString *message = [dic objectForKey:@"message"];

    STAssertTrue([[NSNumber numberWithInt:XEXTENTION_RESULT_LOGIC_TEST_INVALID_STATUS] isEqual:status], nil);
    STAssertTrue([[NSNull null] isEqual:message], nil);
}

- (void)testToCallbackString
{
    // ok
    NSString *msgString = @"message string";
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:msgString];
    NSString *callbackStr = [result toCallbackString:nil];
    STAssertNotNil(callbackStr, nil);
    STAssertTrue([callbackStr hasPrefix:@"xFace.callbackSuccess("], nil);

    //error
    result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:msgString];
    callbackStr = [result toCallbackString:nil];
    STAssertNotNil(callbackStr, nil);
    STAssertTrue([callbackStr hasPrefix:@"xFace.callbackError("], nil);

    // progress change
    result = [XExtensionResult resultWithStatus:STATUS_PROGRESS_CHANGING messageAsObject:msgString];
    callbackStr = [result toCallbackString:nil];
    STAssertNotNil(callbackStr, nil);
    STAssertTrue([callbackStr hasPrefix:@"xFace.callbackStatusChanged("], nil);
}

@end
