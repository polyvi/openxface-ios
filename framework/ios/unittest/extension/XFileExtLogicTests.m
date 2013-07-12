
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
//  XFileExtLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XFileExt.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XApplicationFactory.h"

@interface XFileExtLogicTests : SenTestCase
{
@private
    XFileExt *fileExt;
}
@end

@implementation XFileExtLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XJavaScriptEvaluator *jsEvaluator = webApp.jsEvaluator;

    fileExt = [[XFileExt alloc] initWithMsgHandler:jsEvaluator];
    STAssertNotNil(fileExt, @"Failed to create rootViewController instance");
}

- (void)testInitWithMsgHandler
{
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XJavaScriptEvaluator *jsEvaluator = webApp.jsEvaluator;
    XFileExt *FileExtention = [[XFileExt alloc] initWithMsgHandler:jsEvaluator];

    STAssertNotNil(FileExtention, nil);
}

- (void)testShouldExecuteInBackground
{
    BOOL ret = [fileExt shouldExecuteInBackground:nil];
    STAssertTrue(ret, nil);
}

@end
