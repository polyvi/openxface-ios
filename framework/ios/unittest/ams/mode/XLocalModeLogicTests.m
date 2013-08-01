
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
//  XLocalModeLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XLocalMode.h"
#import "XApplication.h"
#import "XApplicationFactory.h"
#import "XConstants.h"
#import "XConfiguration.h"

#define XLOCAL_MODE_LOGIC_TESTS_APP_ID        @"appId"

@interface XLocalModeLogicTests : SenTestCase
{
@private
    XLocalMode *localMode;
}

@end

@implementation XLocalModeLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:@"app"];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    self->localMode = [[XLocalMode alloc] initWithApp:app];
    STAssertNotNil(self->localMode, @"Failed to create localmode instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

- (void)testGetURLWhenSrcRootIsEmpty
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLOCAL_MODE_LOGIC_TESTS_APP_ID];
    [appInfo setEntry:DEFAULT_APP_START_PAGE];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    NSURL *url = [self->localMode getURL:app];
    NSURL *expected = [NSURL fileURLWithPath:[[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", XLOCAL_MODE_LOGIC_TESTS_APP_ID, FILE_SEPARATOR, DEFAULT_APP_START_PAGE]];

    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);

    [appInfo setEntry:@"/index.html"];
    url = [self->localMode getURL:app];
    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);

    [appInfo setEntry:@"//index.html"];
    url = [self->localMode getURL:app];
    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);
}

- (void)testGetURLWhenSrcRootIsNotEmpty
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLOCAL_MODE_LOGIC_TESTS_APP_ID];
    [appInfo setEntry:DEFAULT_APP_START_PAGE];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [NSString stringWithFormat:@"%@%@%@%@%@", APPLICATION_PREPACKED_PACKAGE_FOLDER, FILE_SEPARATOR, XFACE_WORKSPACE_NAME_UNDER_APP, FILE_SEPARATOR, APPLICATION_INSTALLATION_FOLDER];
    NSString *srcRoot = [bundle pathForResource:DEFAULT_APP_ID_FOR_PLAYER ofType:nil inDirectory:bundlePath];

    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    NSURL *url = [self->localMode getURL:app];
    NSURL *expected = [NSURL fileURLWithPath:[srcRoot stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, DEFAULT_APP_START_PAGE]];

    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);

    [appInfo setEntry:@"/index.html"];
    url = [self->localMode getURL:app];
    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);

    [appInfo setEntry:@"//index.html"];
    url = [self->localMode getURL:app];
    STAssertTrue([[url absoluteString] isEqualToString:[expected absoluteString]], nil);
}

- (void)testGetIconURL
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLOCAL_MODE_LOGIC_TESTS_APP_ID];
    [appInfo setIcon:@"img/icon.png"];

    id<XApplication> app = [XApplicationFactory create:appInfo];

    NSString *pathPrefix = @"file://localhost";
    NSString *pathSuffix = @"appId/img/icon.png";

    NSString *iconPath = [app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);
    STAssertTrue([iconPath hasSuffix:pathSuffix], nil);
}

- (void)testGetIconURLAbnormal
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLOCAL_MODE_LOGIC_TESTS_APP_ID];
    [appInfo setIcon:@"../icon.png"];

    id<XApplication> app = [XApplicationFactory create:appInfo];

    NSString *iconPath = [app getIconURL];
    STAssertNil(iconPath, nil);
}

@end
