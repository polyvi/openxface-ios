
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
//  XBase64DataLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>

#import "XBase64Data.h"

@interface XBase64DataLogicTests : SenTestCase

@end

@implementation XBase64DataLogicTests

- (void)setUp
{
    [super setUp];
    // setup code here
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void) testBase64Encode
{
    NSString* decodedString = @"abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&";
    NSData* decodedData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];

    NSString* expectedEncodedString = @"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY3ODkwIUAjJCVeJg==";
    NSString* actualEncodedString = [decodedData base64EncodedString];

    STAssertTrue([expectedEncodedString isEqualToString:actualEncodedString], nil);
}

- (void) testBase64Decode
{
    NSString* encodedString = @"YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY3ODkwIUAjJCVeJg==";
    NSString* decodedString = @"abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&";
    NSData* encodedData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
    NSData* decodedData = [NSData dataFromBase64String:encodedString];

    STAssertTrue([encodedData isEqualToData:decodedData], nil);
}

@end
