
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
//  XNativeApplicationLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XNativeApplication.h"
#import "XAppInfo.h"
#import "XConstants.h"
#import "XApplicationFactory.h"
#import "XNativeApplication_Privates.h"

#define XNATIVE_APP_LOGIC_TESTS_APP_ID   @"appId"
#define XNATIVE_APP_CUSTOM_URL_FOR_TEST  @"com.test.testUrl"
#define XNATIVE_APP_ENTRY                @"nappScheme"
#define XNATIVE_APP_VALIDATED_ENTRY      @"nappScheme://"
#define XNATIVE_APP_VALIDATED_ENTRY_2    @"https://itunes.apple.com/us/album/toy-story-original-walt-disney/id156093462?i=156093464"

@interface XNativeApplicationLogicTests : SenTestCase
{
@private
    id<XApplication> app;
}
@end

@implementation XNativeApplicationLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setType:APP_TYPE_NAPP];
    self->app = [XApplicationFactory create:appInfo];
    STAssertNotNil(self->app, @"Failed to create native application instance");
}

- (void)testIsInstalledWithFalseResult
{
    [[self->app appInfo] setEntry:XNATIVE_APP_CUSTOM_URL_FOR_TEST];
    STAssertFalse([self->app isInstalled], nil);
}

- (void)testIsNative
{
    STAssertTrue([self->app isNative], nil);
}

- (void)testGetWhitelist
{
    STAssertNil([app whitelist], nil);
}

- (void)testLoad
{
    STAssertThrows([app load], nil);
}

- (void)testValidateEntryWithNilArg
{
    STAssertNil([(XNativeApplication *)app validateEntry:nil], nil);
}

- (void)testValidateEntry
{
    NSString *entry = XNATIVE_APP_ENTRY;
    STAssertTrue([[(XNativeApplication *)app validateEntry:entry] isEqualToString:XNATIVE_APP_VALIDATED_ENTRY], nil);

    entry = XNATIVE_APP_VALIDATED_ENTRY;
    STAssertTrue([[(XNativeApplication *)app validateEntry:entry] isEqualToString:XNATIVE_APP_VALIDATED_ENTRY], nil);

    entry = XNATIVE_APP_VALIDATED_ENTRY_2;
    STAssertTrue([[(XNativeApplication *)app validateEntry:entry] isEqualToString:XNATIVE_APP_VALIDATED_ENTRY_2], nil);
}

- (void)testGetIconURLAbnormal
{
    [self->app appInfo].appId = XNATIVE_APP_LOGIC_TESTS_APP_ID;
    [self->app appInfo].icon = nil;
    STAssertNil([self->app getIconURL], nil);

    [self->app appInfo].icon = @"";
    STAssertNil([self->app getIconURL], nil);

    [self->app appInfo].icon = @"../icon.png";
    STAssertNil([self->app getIconURL], nil);

    [self->app appInfo].icon = @"..\\icon.png";
    STAssertNil([self->app getIconURL], nil);
}

- (void)testtGetIconURLNormal
{
    NSString *pathPrefix = @"file://localhost";
    NSString *pathSuffix = @"appId/img/icon.png";

    [self->app appInfo].appId = XNATIVE_APP_LOGIC_TESTS_APP_ID;
    [self->app appInfo].icon = @"icon.png";
    NSString *iconPath = [self->app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);

    [self->app appInfo].icon = @"img/icon.png";
    iconPath = [self->app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);
    STAssertTrue([iconPath hasSuffix:pathSuffix], nil);

    [self->app appInfo].icon = @"/img/icon.png";
    iconPath = [self->app getIconURL];
    STAssertNotNil(iconPath, nil);
    STAssertTrue([iconPath hasPrefix:pathPrefix], nil);
    STAssertTrue([iconPath hasSuffix:pathSuffix], nil);
}

@end
