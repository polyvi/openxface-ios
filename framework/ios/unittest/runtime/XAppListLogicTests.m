
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
//  XAppListLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppList.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XAppViewStub.h"
#import "XApplicationFactory.h"

#define XAPPLIST_LOGIC_TESTS_APP_ID                @"appId"
#define XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID        @"defaultAppId"
#define XAPPLIST_LOGIC_TESTS_APP_VIEW_ID           123456

@interface XAppListLogicTests : SenTestCase
{
@private
    XAppList *appList;
}
@end

@implementation XAppListLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    appList = [[XAppList alloc] init];
    STAssertNotNil(appList, @"Failed to create XAppList instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

- (void)testInit
{
    STAssertNil([appList defaultAppId], nil);
    STAssertEquals((NSUInteger)0, [[[appList getEnumerator] allObjects] count], nil);
}

- (void)testAddWithNilObj
{
    [appList add:nil];
    STAssertEquals((NSUInteger)0, [[[appList getEnumerator] allObjects] count], nil);
    [appList add:nil];
    STAssertEquals((NSUInteger)0, [[[appList getEnumerator] allObjects] count], nil);
}

- (void)testAdd
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];
    STAssertEquals((NSUInteger)1, [[[appList getEnumerator] allObjects] count], nil);

    appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLIST_LOGIC_TESTS_APP_ID];
    app = [XApplicationFactory create:appInfo];

    [appList add:app];
    STAssertEquals((NSUInteger)2, [[[appList getEnumerator] allObjects] count], nil);
}

- (void)testGetAppByIdWithNilResult
{
    // 测试app collection为空的情况
    id<XApplication> foundApp = [appList getAppById:nil];
    STAssertNil(foundApp, nil);

    foundApp = [appList getAppById:XAPPLIST_LOGIC_TESTS_APP_ID];
    STAssertNil(foundApp, nil);

    // 测试app collection非空时，没有找到匹配的app的情况
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];
    STAssertEquals((NSUInteger)1, [[[appList getEnumerator] allObjects] count], nil);

    foundApp = [appList getAppById:XAPPLIST_LOGIC_TESTS_APP_ID];
    STAssertNil(foundApp, nil);
}

- (void)testGetAppById
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLIST_LOGIC_TESTS_APP_ID];
    [appList add:app];
    STAssertEquals((NSUInteger)1, [[[appList getEnumerator] allObjects] count], nil);

    id<XApplication> foundApp = [appList getAppById:XAPPLIST_LOGIC_TESTS_APP_ID];
    STAssertNotNil(foundApp, nil);
    STAssertEquals(app, foundApp, nil);
}

- (void)testContainsAppWithNoResult
{
    // 测试app id为nil的情况
    BOOL ret = [appList containsApp:nil];
    STAssertFalse(ret, nil);

    // 测试app id有效，但app list为空的情况
    ret = [appList containsApp:XAPPLIST_LOGIC_TESTS_APP_ID];
    STAssertFalse(ret, nil);

    // 测试app list非空，但指定app不存在的情况
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];
    [appList add:app];

    ret = [appList containsApp:XAPPLIST_LOGIC_TESTS_APP_ID];
    STAssertFalse(ret, nil);
}

- (void)testContainsAppWithYesResult
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];
    [appList add:app];

    BOOL ret = [appList containsApp:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];
    STAssertTrue(ret, nil);
}

- (void)testRemoveAppByIdWithNilObj
{
    [appList removeAppById:nil];
    [appList removeAppById:XAPPLIST_LOGIC_TESTS_APP_ID];
}

- (void)testRemoveAppById
{
    // 搭建测试环境，生成app与app view,并将app添加到conllection中
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    id<XAppView> appView = [XAppViewStub alloc];

    [[app appInfo] setAppId:XAPPLIST_LOGIC_TESTS_APP_ID];
    [app setAppView:appView];
    [appList add:app];

    // 测试前检查
    STAssertEquals((NSUInteger)1, [[[appList getEnumerator] allObjects] count], nil);

    [appList removeAppById:XAPPLIST_LOGIC_TESTS_APP_ID];

    // 测试后检查
    STAssertEquals((NSUInteger)0, [[[appList getEnumerator] allObjects] count], nil);
}

- (void)testMarkAsDefaultAppWithNilObj
{
    // 测试前检查
    STAssertNil([appList defaultAppId], nil);

    [appList markAsDefaultApp:nil];

    // 测试后检查
    STAssertNil([appList defaultAppId], nil);
}

- (void)testMarkAsDefaultApp
{
    // 测试前检查
    STAssertNil([appList defaultAppId], nil);

    [appList markAsDefaultApp:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];

    // 测试后检查
    STAssertNotNil([appList defaultAppId], nil);
    STAssertEquals(XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID, [appList defaultAppId], nil);
}

- (void)testGetDefaultAppWithNilResult
{
    // 测试defaultApp id为nil的情况
    id<XApplication> foundApp = [appList getDefaultApp];
    STAssertNil(foundApp, nil);

    // 测试defaultApp id有效,但已安装列表中没有任何app的情况
    [appList markAsDefaultApp:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];

    foundApp = [appList getDefaultApp];
    STAssertNil(foundApp, nil);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLIST_LOGIC_TESTS_APP_ID];
    [appList add:app];

    // 测试在已安装列表中没有找到匹配的default app的情况
    foundApp = [appList getDefaultApp];
    STAssertNil(foundApp, nil);
}

- (void)testGetDefaultApp
{
    // 搭建测试环境，生成一个app添加到已安装列表中
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];
    [appList add:app];

    [appList markAsDefaultApp:XAPPLIST_LOGIC_TESTS_DEFAULT_APP_ID];

    id<XApplication> foundApp = [appList getDefaultApp];
    STAssertNotNil(foundApp, nil);
    STAssertEquals(app, foundApp, nil);
}

- (void)testGetEnumerator
{
    NSEnumerator *enumerator = [appList getEnumerator];
    STAssertNotNil(enumerator, nil);
    STAssertEquals((NSUInteger)0, [[enumerator allObjects] count], nil);

    // 搭建测试环境，生成app添加到conllection中
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];

    enumerator = [appList getEnumerator];
    STAssertEquals((NSUInteger)1, [[enumerator allObjects] count], nil);
}

@end
