
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
//  XQueuedMutableArrayLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XQueuedMutableArray.h"

@interface XQueuedMutableArrayLogicTests : SenTestCase
{
@private
    NSMutableArray *queue;
}
@end

@implementation XQueuedMutableArrayLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    queue = [[NSMutableArray alloc] init];
    STAssertNotNil(queue, @"Failed to create queue instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [queue removeAllObjects];
    [super tearDown];
}

- (void)testEnqueue
{
    STAssertTrue((0 == [queue count]), nil);

    [queue enqueue:[NSNumber numberWithInt:1]];

    STAssertTrue((1 == [queue count]), nil);
    STAssertEquals(1, [[queue head] intValue], nil);

    [queue enqueue:[NSNumber numberWithInt:2]];

    STAssertTrue((2 == [queue count]), nil);
    STAssertEquals(1, [[queue head] intValue], nil);
}

- (void)testDequeue
{
    STAssertTrue((0 == [queue count]), nil);
    STAssertNil([queue dequeue], nil);

    [queue enqueue:[NSNumber numberWithInt:1]];
    [queue enqueue:[NSNumber numberWithInt:2]];

    STAssertTrue((2 == [queue count]), nil);

    STAssertEquals(1, [[queue dequeue] intValue], nil);
    STAssertTrue((1 == [queue count]), nil);

    STAssertEquals(2, [[queue dequeue] intValue], nil);
    STAssertTrue((0 == [queue count]), nil);

    STAssertNil([queue dequeue], nil);
    STAssertTrue((0 == [queue count]), nil);

    // 测试队列中有重复对象的情况
    NSNumber *item = [NSNumber numberWithInt:1];
    [queue enqueue:item];
    [queue enqueue:item];
    [queue enqueue:item];

    STAssertTrue((3 == [queue count]), nil);
    STAssertEquals(1, [[queue dequeue] intValue], nil);
    STAssertTrue((2 == [queue count]), nil);
}

- (void)testHead
{
    STAssertTrue((0 == [queue count]), nil);
    STAssertNil([queue head], nil);

    [queue enqueue:[NSNumber numberWithInt:1]];
    [queue enqueue:[NSNumber numberWithInt:2]];

    STAssertTrue((2 == [queue count]), nil);

    STAssertEquals(1, [[queue head] intValue], nil);
    STAssertTrue((2 == [queue count]), nil);

    STAssertEquals(1, [[queue dequeue] intValue], nil);
    STAssertTrue((1 == [queue count]), nil);

    STAssertEquals(2, [[queue head] intValue], nil);
    STAssertTrue((1 == [queue count]), nil);

    STAssertEquals(2, [[queue dequeue] intValue], nil);
    STAssertTrue((0 == [queue count]), nil);

    STAssertNil([queue head], nil);
    STAssertTrue((0 == [queue count]), nil);
}

@end
