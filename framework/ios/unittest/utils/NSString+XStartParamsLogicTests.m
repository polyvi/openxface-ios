
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
//  NSString+XStartParamsLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSString+XStartParams.h"

@interface NSString_XStartParamsLogicTests : SenTestCase

@end

@implementation NSString_XStartParamsLogicTests

- (void)testWithNilResults
{
    NSString *startParams = nil;
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);

    startParams = @"";
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);

    startParams = @"  ";
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);

}

- (void)testNormal
{
    NSString *startParams = @"startpage=a/b.html;data=webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
 }


- (void)testStartPage
{
    NSString *startParams = @"startpage=a/b.html;";
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);

    //没有";"的情况
    startParams = @"startpage=a/b.html";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams data], nil);

    startParams = @"startpage=a/b.html;webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);

    startParams = @"startpage=../a/b.html;webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);

    //大小写问题
    startParams = @"startPage=../a/b.html;webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);

    //startpage出现多次
    startParams = @"startPage=startpage/../a/b.html;webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"startpage/../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
}

- (void)testStartPageWithNilResult
{
    NSString *startParams = @"startpage=";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);

    startParams = @"startpage=;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);


    startParams = @"startpage= ;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);

    startParams = @"teststartPage=startpage/../a/b.html;webdata";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"teststartPage=startpage/../a/b.html;webdata"], nil);
}

- (void)testData
{
    //有";"的情况
    NSString *startParams = @"data=a/b.html;";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);

    startParams = @"noprefix";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"noprefix"], nil);

    startParams = @"a/b.html;";
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);

    //大小写情况
    startParams = @"dAtA=a/b.html;";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);

    //没有";"的情况
    startParams = @"data=a/b.html";
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);

    //含有"data"的情况
    startParams = @"data=data2";
    STAssertTrue([[startParams data] isEqualToString:@"data2"], nil);
    STAssertNil([startParams startPage], nil);

    //没有"data="的情况
    startParams = @"a/b.html";
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);

    startParams = @"a/b.html;";
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);

    startParams = @"startpage=a/b.html;webdata=";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata="], nil);
}


- (void)testDataWithWhitespace
{
    //有";"的情况
    NSString *startParams = @"data = a/b.html;";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);

    startParams = @"   noprefix";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"noprefix"], nil);

    startParams = @"  a/b.html;";
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);

    //大小写情况
    startParams = @" dAtA = a/b.html;";
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);

    //没有";"的情况
    startParams = @"data = a/b.html";
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);

    //含有"data"的情况
    startParams = @"data = data2";
    STAssertTrue([[startParams data] isEqualToString:@"data2"], nil);
    STAssertNil([startParams startPage], nil);

    startParams = @"startpage = a/b.html; webdata = ";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata = "], nil);
}

- (void)testStartPageWithWhitespace
{
    NSString *startParams = @" startpage   =a/b.html;";
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);

    //没有";"的情况
    startParams = @" startpage   = a/b.html";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams data], nil);

    startParams = @"startpage  =  a/b.html; webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);

    startParams = @"startpage  =  ../a/b.html; webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);

    //大小写问题
    startParams = @" startPage  =  ../a/b.html;webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);

    //startpage出现多次
    startParams = @" startPage = startpage/../a/b.html; webdata";
    STAssertTrue([[startParams startPage] isEqualToString:@"startpage/../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
}

@end
