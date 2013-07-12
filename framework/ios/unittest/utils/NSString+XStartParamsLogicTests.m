
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
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"  ";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"xFace://";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue(0 == [[startParams paramsForNative] length], nil);

    startParams = @"xFace://app id ? webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"xFace:// ?webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"xFace://appid?startpage =a/b.html;data=webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"app id ? webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @" ?webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"appid?startpage =a/b.html;data=webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertNil([startParams paramsForNative], nil);
}

- (void)testNormal
{
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid?startpage=a/b.html;data=webdata"] absoluteString]];
    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid?startpage=a/b.html;data=webdata"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"appid?startpage=a/b.html;data=webdata"] absoluteString]];
    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid?startpage=a/b.html;data=webdata"], nil);
}

- (void)testAppIdWithCustomScheme
{
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid"] absoluteString]];

    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid?webdata"] absoluteString]];
    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid?webdata"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid;?webdata"] absoluteString]];
    STAssertTrue([[startParams appId] isEqualToString:@"appid;"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid;?webdata"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://webdata"] absoluteString]];
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams appId] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"webdata"], nil);
}

- (void)testAppId
{
    NSString *startParams = @"appid";

    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid"], nil);

    startParams = @"appid?webdata";
    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid?webdata"], nil);

    startParams = @"appid;?webdata";
    STAssertTrue([[startParams appId] isEqualToString:@"appid;"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid;?webdata"], nil);

    startParams = @"webdata";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams appId] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"webdata"], nil);
}

- (void)testAppIdWithNilResult
{
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?webdata"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?webdata"], nil);

    startParams = @"?webdata";

    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?webdata"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=a/b.html;data=webdata"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;data=webdata"], nil);

    startParams = @"?startpage=a/b.html;data=webdata";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;data=webdata"], nil);
}

- (void)testStartPageWithCustomScheme
{
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=a/b.html;"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;"], nil);

    //没有";"的情况
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=a/b.html"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=a/b.html;webdata"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;webdata"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=../a/b.html;webdata"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=../a/b.html;webdata"], nil);

    //大小写问题
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startPage=../a/b.html;webdata"] absoluteString]];
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startPage=../a/b.html;webdata"], nil);

    //startpage出现多次
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startPage=startpage/../a/b.html;webdata"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"startpage/../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startPage=startpage/../a/b.html;webdata"], nil);
}

- (void)testStartPage
{
    NSString *startParams = @"?startpage=a/b.html;";

    STAssertNil([startParams appId], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;"], nil);

    //没有";"的情况
    startParams = @"?startpage=a/b.html";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams data], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html"], nil);

    startParams = @"?startpage=a/b.html;webdata";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;webdata"], nil);

    startParams = @"?startpage=../a/b.html;webdata";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=../a/b.html;webdata"], nil);

    //大小写问题
    startParams = @"?startPage=../a/b.html;webdata";
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startPage=../a/b.html;webdata"], nil);

    //startpage出现多次
    startParams = @"?startPage=startpage/../a/b.html;webdata";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"startpage/../a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startPage=startpage/../a/b.html;webdata"], nil);
}

- (void)testStartPageWithNilResult
{
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid"] absoluteString]];
    STAssertNil([startParams startPage], nil);

    startParams = @"appid";
    STAssertNil([startParams startPage], nil);

    startParams = @"xFace://appid?webdata";
    STAssertNil([startParams startPage], nil);

    startParams = @"appid?webdata";
    STAssertNil([startParams startPage], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://startpage=a/b.html;"] absoluteString]];
    STAssertNil([startParams startPage], nil);

    startParams = @"startpage=a/b.html;";
    STAssertNil([startParams startPage], nil);

    startParams = @"xFace://?startpage =a/b.html;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = @"?startpage =a/b.html;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams paramsForNative], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage="] absoluteString]];
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"?startpage=";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=;"] absoluteString]];
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"?startpage=;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"xFace://?startpage= ;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"?startpage= ;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?teststartPage=startpage/../a/b.html;webdata"] absoluteString]];
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"teststartPage=startpage/../a/b.html;webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?teststartPage=startpage/../a/b.html;webdata"], nil);

    startParams = @"?teststartPage=startpage/../a/b.html;webdata";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"teststartPage=startpage/../a/b.html;webdata"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?teststartPage=startpage/../a/b.html;webdata"], nil);
}

- (void)testDataWithCustomScheme
{
    //有";"的情况
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?data=a/b.html;"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?data=a/b.html;"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?a/b.html;"] absoluteString]];
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?a/b.html;"], nil);

    //大小写情况
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?dAtA=a/b.html;"] absoluteString]];    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?dAtA=a/b.html;"], nil);

    //没有";"的情况
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?data=a/b.html"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?data=a/b.html"], nil);

    //含有"data"的情况
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?data=data2"] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"data2"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?data=data2"], nil);

    //没有"data="的情况
    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?a/b.html"] absoluteString]];
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?a/b.html"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?a/b.html;"] absoluteString]];
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?a/b.html;"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid?webdata"] absoluteString]];
    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid?webdata"], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?startpage=a/b.html;webdata="] absoluteString]];

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata="], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;webdata="], nil);
}

- (void)testData
{
    //有";"的情况
    NSString *startParams = @"?data=a/b.html;";

    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?data=a/b.html;"], nil);

    startParams = @"?a/b.html;";
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?a/b.html;"], nil);

    //大小写情况
    startParams = @"?dAtA=a/b.html;";
    STAssertNil([startParams appId], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?dAtA=a/b.html;"], nil);

    //没有";"的情况
    startParams = @"?data=a/b.html";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?data=a/b.html"], nil);

    //含有"data"的情况
    startParams = @"?data=data2";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"data2"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?data=data2"], nil);

    //没有"data="的情况
    startParams = @"?a/b.html";
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?a/b.html"], nil);

    startParams = @"?a/b.html;";
    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams data] isEqualToString:@"a/b.html;"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?a/b.html;"], nil);

    startParams = @"appid?webdata";
    STAssertTrue([[startParams appId] isEqualToString:@"appid"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata"], nil);
    STAssertNil([startParams startPage], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"appid?webdata"], nil);

    startParams = @"?startpage=a/b.html;webdata=";

    STAssertNil([startParams appId], nil);
    STAssertTrue([[startParams startPage] isEqualToString:@"a/b.html"], nil);
    STAssertTrue([[startParams data] isEqualToString:@"webdata="], nil);
    STAssertTrue([[startParams paramsForNative] isEqualToString:@"?startpage=a/b.html;webdata="], nil);
}

- (void)testDataWithNilResult
{
    NSString *startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid"] absoluteString]];
    STAssertNil([startParams data], nil);

    startParams = @"appid";
    STAssertNil([startParams data], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://appid?startpage=a/b.html"] absoluteString]];
    STAssertNil([startParams data], nil);

    startParams = @"appid?startpage=a/b.html";
    STAssertNil([startParams data], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://data=a/b.html"] absoluteString]];
    STAssertNil([startParams data], nil);

    startParams = @"data=a/b.html";
    STAssertNil([startParams data], nil);

    startParams = @"xFace://data =a/b.html";
    STAssertNil([startParams data], nil);

    startParams = @"data =a/b.html";
    STAssertNil([startParams data], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?data="] absoluteString]];
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"?data=";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = [NSString stringWithString:[[NSURL URLWithString:@"xFace://?data=;"] absoluteString]];
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"?data=;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"xFace://?data= ;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);

    startParams = @"?data= ;";
    STAssertNil([startParams data], nil);
    STAssertNil([startParams startPage], nil);
    STAssertNil([startParams appId], nil);
}

@end
