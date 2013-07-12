
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
//  NSMutableArray+XStackAdditionsLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSMutableArray+XStackAdditions.h"

@interface NSMutableArray_XStackAdditionsLogicTests : SenTestCase
{
@private
    NSMutableArray *stack;
}

@end

@implementation NSMutableArray_XStackAdditionsLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    stack = [[NSMutableArray alloc] init];
    STAssertNotNil(stack, @"Failed to create stack instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [stack removeAllObjects];
    [super tearDown];
}

- (void)testPush
{
    STAssertTrue((0 == [stack count]), nil);

    [stack push:[NSNumber numberWithInt:1]];

    STAssertTrue((1 == [stack count]), nil);
    STAssertEquals(1, [[stack peek] intValue], nil);

    [stack push:[NSNumber numberWithInt:2]];

    STAssertTrue((2 == [stack count]), nil);
    STAssertEquals(2, [[stack peek] intValue], nil);
}

- (void)testPop
{
    STAssertTrue((0 == [stack count]), nil);
    STAssertNil([stack pop], nil);

    [stack push:[NSNumber numberWithInt:1]];
    [stack push:[NSNumber numberWithInt:2]];

    STAssertTrue((2 == [stack count]), nil);

    STAssertEquals(2, [[stack pop] intValue], nil);
    STAssertTrue((1 == [stack count]), nil);

    STAssertEquals(1, [[stack pop] intValue], nil);
    STAssertTrue((0 == [stack count]), nil);

    STAssertNil([stack pop], nil);
    STAssertTrue((0 == [stack count]), nil);

    // 测试栈中有重复对象的情况
    NSNumber *item = [NSNumber numberWithInt:1];
    [stack push:item];
    [stack push:item];
    [stack push:item];

    STAssertTrue((3 == [stack count]), nil);
    STAssertEquals(1, [[stack pop] intValue], nil);
    STAssertTrue((2 == [stack count]), nil);
}

- (void)testPeek
{
    STAssertTrue((0 == [stack count]), nil);
    STAssertNil([stack peek], nil);

    [stack push:[NSNumber numberWithInt:1]];
    [stack push:[NSNumber numberWithInt:2]];

    STAssertTrue((2 == [stack count]), nil);

    STAssertEquals(2, [[stack peek] intValue], nil);
    STAssertTrue((2 == [stack count]), nil);

    STAssertEquals(2, [[stack pop] intValue], nil);
    STAssertTrue((1 == [stack count]), nil);

    STAssertEquals(1, [[stack peek] intValue], nil);
    STAssertTrue((1 == [stack count]), nil);

    STAssertEquals(1, [[stack pop] intValue], nil);
    STAssertTrue((0 == [stack count]), nil);

    STAssertNil([stack peek], nil);
    STAssertTrue((0 == [stack count]), nil);
}

@end
