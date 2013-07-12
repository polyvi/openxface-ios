
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
//  XCommandLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XCommand.h"


#define XCOMMAND_INSTANCE_CALLBACK_ID        @"cmdClassName12345"
#define XCOMMAND_INSTANCE_CLASS_NAME         @"cmdClassName"
#define XCOMMAND_INSTANCE_METHOD_NAME        @"cmdMethodName"
#define XCOMMAND_INSTANCE_ARG1               @"arg1"
#define XCOMMAND_INSTANCE_ARG2               @"arg2"

@interface XCommandLogicTests : SenTestCase

@end

@implementation XCommandLogicTests

- (void)testCommandFromJsonWithNilArg
{
    XCommand *cmd = [XCommand commandFromJson:nil];
    STAssertNotNil(cmd, nil);

    STAssertNil([cmd arguments], nil);
    STAssertNil([cmd callbackId], nil);
    STAssertNil([cmd className], nil);
    STAssertNil([cmd methodName], nil);
}

- (void)testCommandFromJson
{
    NSArray *jsonEntry = [NSArray arrayWithObjects:
                          XCOMMAND_INSTANCE_CALLBACK_ID,
                          XCOMMAND_INSTANCE_CLASS_NAME,
                          XCOMMAND_INSTANCE_METHOD_NAME,
                          [[NSMutableArray alloc] initWithObjects:XCOMMAND_INSTANCE_ARG1, XCOMMAND_INSTANCE_ARG2, nil],
                          nil];

    XCommand *cmd = [XCommand commandFromJson:jsonEntry];
    STAssertNotNil(cmd, nil);

    STAssertEqualObjects(XCOMMAND_INSTANCE_CALLBACK_ID, [cmd callbackId], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_CLASS_NAME, [cmd className], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_METHOD_NAME, [cmd methodName], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_ARG1, [[cmd arguments] objectAtIndex:0], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_ARG2, [[cmd arguments] objectAtIndex:1], nil);
}

- (void)testInitWithArguments
{
    XCommand *cmd = [[XCommand alloc] initWithArguments:[[NSMutableArray alloc] initWithObjects:XCOMMAND_INSTANCE_ARG1, XCOMMAND_INSTANCE_ARG2, nil] callbackId:XCOMMAND_INSTANCE_CALLBACK_ID className:XCOMMAND_INSTANCE_CLASS_NAME methodName:XCOMMAND_INSTANCE_METHOD_NAME];
    STAssertNotNil(cmd, nil);

    STAssertEqualObjects(XCOMMAND_INSTANCE_CALLBACK_ID, [cmd callbackId], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_CLASS_NAME, [cmd className], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_METHOD_NAME, [cmd methodName], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_ARG1, [[cmd arguments] objectAtIndex:0], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_ARG2, [[cmd arguments] objectAtIndex:1], nil);
}

- (void)testInitFromJsonWithNilArg
{
    XCommand *cmd = [[XCommand alloc] initFromJson:nil];
    STAssertNotNil(cmd, nil);

    STAssertNil([cmd arguments], nil);
    STAssertNil([cmd className], nil);
    STAssertNil([cmd methodName], nil);
    STAssertNil([cmd callbackId], nil);
}

- (void)testInitFromJsonWithNSNULLObj
{
    NSArray *jsonEntry = [NSArray arrayWithObjects:
                          [NSNull null],
                          [NSNull null],
                          XCOMMAND_INSTANCE_METHOD_NAME,
                          [NSNull null],
                          nil];

    XCommand *cmd = [[XCommand alloc] initFromJson:jsonEntry];
    STAssertNotNil(cmd, nil);

    STAssertEqualObjects([NSNull null], [cmd callbackId], nil);
    STAssertEqualObjects([NSNull null], [cmd className], nil);
    STAssertEqualObjects(XCOMMAND_INSTANCE_METHOD_NAME, [cmd methodName], nil);
    STAssertEqualObjects([NSNull null], [cmd arguments], nil);
}

@end
