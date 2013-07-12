
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
//  md5LogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "md5.h"

@interface md5LogicTests : SenTestCase
{
}
@end

@implementation md5LogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}


- (void)testMd5WithString
{
    NSDictionary* md5 = @{@"202cb962ac59075b964b07152d234b70":@"123", @"900150983cd24fb0d6963f7d28e17f72":@"abc", @"8093a32450075324682d01456d6e3919":@"一二三", @"176bbc0476afa36f883b319295188c57":@"123一二三abc"};

    for(NSString *md5Key in md5) {
        NSString* str = (NSString*)[md5 objectForKey:md5Key];
        str = [NSString stringWithCString:[str UTF8String] encoding:NSUTF8StringEncoding];
        STAssertTrue(NSOrderedSame == [[str md5] compare:md5Key], str);
    }
}

- (void)testMd5WithData
{
    NSDictionary* md5 = @{@"202cb962ac59075b964b07152d234b70":@"123", @"900150983cd24fb0d6963f7d28e17f72":@"abc", @"8093a32450075324682d01456d6e3919":@"一二三", @"176bbc0476afa36f883b319295188c57":@"123一二三abc"};

    for(NSString *md5Key in md5) {
        NSString* str = (NSString*)[md5 objectForKey:md5Key];
        NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
        STAssertTrue(NSOrderedSame == [[data md5] compare:md5Key], str);
    }
    
}

@end
