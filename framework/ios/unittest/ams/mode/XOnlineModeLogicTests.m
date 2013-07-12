
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
//  XOnlineModeLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XOnlineMode.h"
#import "XApplication.h"
#import "XOnlineMode_Privates.h"
#import "XApplicationFactory.h"
#import "XConstants.h"
#import "XConfiguration.h"

#define XONLINE_MODE_LOGIC_TESTS_APP_ID        @"appId"

@interface XOnlineModeLogicTests : SenTestCase
{
@private
    XOnlineMode *onlineMode;
}

@end

@implementation XOnlineModeLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:@"app"];
    [appInfo setRunningMode:ONLINE_RUNNING_MODE];

    id<XApplication> app = [XApplicationFactory create:appInfo];
     self->onlineMode = [[XOnlineMode alloc] initWithApp:app];
    STAssertNotNil( self->onlineMode, @"Failed to create Onlinemode instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

- (void)testURL
{
    NSString* urlStr = @"http://polyvi.com";
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XONLINE_MODE_LOGIC_TESTS_APP_ID];
    [appInfo setRunningMode:ONLINE_RUNNING_MODE];
    [appInfo setEntry:urlStr];

    id<XApplication> app = [XApplicationFactory create:appInfo];
    NSURL *url = [self->onlineMode getURL:app];
    NSURL *expected = [NSURL URLWithString:urlStr];

    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);

}

- (void)testGetIconURLAbnormal
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setRunningMode:ONLINE_RUNNING_MODE];
    appInfo.appId = XONLINE_MODE_LOGIC_TESTS_APP_ID;
    id<XApplication> app = [XApplicationFactory create:appInfo];

    STAssertNil([app getIconURL], nil);

    [app appInfo].icon = @"";
    STAssertNil([app getIconURL], nil);

    [app appInfo].icon = @"../icon.png";
    STAssertNil([app getIconURL], nil);

    [app appInfo].icon = @"..\\icon.png";
    STAssertNil([app getIconURL], nil);
}


- (void)testtGetIconURLNormal
{
    NSString *pathPrefix = @"file://localhost";
    NSString *pathSuffix = @"appId/img/icon.png";

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setRunningMode:ONLINE_RUNNING_MODE];
    appInfo.appId = XONLINE_MODE_LOGIC_TESTS_APP_ID;
    appInfo.icon = @"icon.png";
    id<XApplication> app = [XApplicationFactory create:appInfo];

    NSString *iconPath = [app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);

    [app appInfo].icon = @"img/icon.png";
    iconPath = [app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);
    STAssertTrue([iconPath hasSuffix:pathSuffix], nil);

    [app appInfo].icon = @"/img/icon.png";
    iconPath = [app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);
    STAssertTrue([iconPath hasSuffix:pathSuffix], nil);
}

@end
