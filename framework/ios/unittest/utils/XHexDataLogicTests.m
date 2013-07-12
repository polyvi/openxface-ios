
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
//  XHexDataLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XHexData.h"

@interface XHexDataLogicTests : SenTestCase

@end

@implementation XHexDataLogicTests

- (void) testHexString
{
    unsigned char bytes[] = { 0x11, 0x56, 0xFF, 0xCD, 0x34, 0x30, 0xAA, 0x22 };
    NSData* hexData = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString* expectedHexString= @"1156FFCD3430AA22";
    NSString* actualEncodedString = [hexData hexString];

    STAssertTrue([expectedHexString isEqualToString:actualEncodedString], nil);
}

- (void) testDataWithHexString
{
    unsigned char bytes[] = { 0x11, 0x56, 0xFF, 0xCD, 0x34, 0x30, 0xAA, 0x22 };
    NSData* expectedData = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString* hexString = @"1156FFCD3430AA22";
    NSData* decodedData = [NSData dataWithHexString:hexString];

    STAssertTrue([expectedData isEqualToData:decodedData], nil);
}

@end
