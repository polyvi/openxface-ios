
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
//  XApplicationLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XConfiguration.h"
#import "XConstants.h"
#import "XAppInfo.h"
#import "XAppViewStub.h"
#import "XAmsExt.h"
#import "XFileExt.h"
#import "XTelephonyExt.h"
#import "XNetworkConnectionExt.h"
#import "XConsoleExt.h"
#import "XWebApplication.h"
#import "XWhitelist_Privates.h"

#define XAPPLICATION_LOGIC_TESTS_APP_ID                @"appId"
#define XAPPLICATION_LOGIC_TESTS_APP_WORKSPACE_FOLDER  @"workspace"
#define XAPPLICATION_LOGIC_TESTS_APP_DATA_FOLDER       @"data"
#define XAPPLICATION_LOGIC_TESTS_EXTENSION_NAME        @"File"
#define XAPPLICATION_LOGIC_TESTS_START_PARAMS1         @"Admin;123"
#define XAPPLICATION_LOGIC_TESTS_START_PARAMS2         @"Admin;456"

@interface XWebApplicationLogicTests : SenTestCase
{
@private
     id<XApplication> app;
}
@end

@implementation XWebApplicationLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    XConfiguration *config = [XConfiguration getInstance];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    __autoreleasing NSError *error;

    if ([fileManager fileExistsAtPath:[config systemWorkspace]])
    {
        [fileManager removeItemAtPath:[config systemWorkspace] error:&error];
    }

    STAssertFalseNoThrow([fileManager fileExistsAtPath:[config systemWorkspace]], nil);
    BOOL ret = [fileManager createDirectoryAtPath:[config systemWorkspace] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!ret)
    {
        NSLog(@"Failed to create directory at path: %@ in %@ and error is: %@", [config systemWorkspace], self.name, [error localizedDescription]);
    }

    [[XConfiguration getInstance] loadConfiguration];

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    self->app = [[XWebApplication alloc] initWithAppInfo:appInfo];
    STAssertNotNil(self->app, @"Failed to create application instance");

    [[self->app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    [fileManager createDirectoryAtPath:[self->app installedDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[[XConfiguration getInstance] systemWorkspace] error:nil];
    [fileManager removeItemAtPath:[self->app installedDirectory] error:nil];

    [super tearDown];
}

- (void)testGetInstalledDirectory
{
    NSString *appInstalledDir = [app installedDirectory];
    STAssertNotNil(appInstalledDir, nil);

    BOOL ret = [appInstalledDir isAbsolutePath];
    STAssertTrue(ret, nil);

    ret = [appInstalledDir hasPrefix:[[XConfiguration getInstance] appInstallationDir]];
    STAssertTrue(ret, nil);

    ret = [appInstalledDir hasSuffix:[self->app getAppId]];
    STAssertTrue(ret, nil);
}

- (void)testGetWorkspace
{
    NSString *workspace = [app getWorkspace];
    STAssertNotNil(workspace, nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:workspace];
    STAssertTrue(ret, nil);

    ret = [workspace isAbsolutePath];
    STAssertTrue(ret, nil);

    ret = [workspace hasPrefix:[[XConfiguration getInstance] appInstallationDir]];
    STAssertTrue(ret, nil);

    ret = [workspace hasSuffix:XAPPLICATION_LOGIC_TESTS_APP_WORKSPACE_FOLDER];
    STAssertTrue(ret, nil);
}

- (void)testGetDataDir
{
    NSString *dataDir = [app getDataDir];
    STAssertNotNil(dataDir, nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:dataDir];
    STAssertTrue(ret, nil);

    ret = [dataDir isAbsolutePath];
    STAssertTrue(ret, nil);

    ret = [dataDir hasPrefix:[[XConfiguration getInstance] appInstallationDir]];
    STAssertTrue(ret, nil);

    ret = [dataDir hasSuffix:XAPPLICATION_LOGIC_TESTS_APP_DATA_FOLDER];
    STAssertTrue(ret, nil);
}

- (void)testIsActiveWithTrueResult
{
    // 搭建测试环境：创建并设置一个view
    XAppViewStub *stub = [[XAppViewStub alloc] init];
    [app setAppView:stub];

    STAssertTrue([app isActive], nil);
}

- (void)testIsActiveWithFalseResult
{
    STAssertFalse([app isActive], nil);
}

- (void)testIsInstalled
{
    STAssertTrue([app isInstalled], nil);
}

- (void)testIsNative
{
    STAssertFalse([app isNative], nil);
}

- (void)testWhitelist
{
    STAssertNotNil([self->app whitelist], nil);
    STAssertNotNil([[self->app whitelist] whitelist], nil);
    STAssertNotNil([[self->app whitelist] expandedWhitelist], nil);
    STAssertTrue([[self->app whitelist] allowAll], nil);

    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    STAssertTrue([[self->app whitelist] isUrlAllowed:url], nil);
}

- (void)testLoadWithParameters
{
    STAssertThrows([self->app loadWithParameters:nil], nil);
}

- (void)testSetData
{
    STAssertNoThrow([self->app setData:nil forKey:nil], nil);

    STAssertNil([self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 设置APP_DATA_KEY_FOR_START_PARAMS的value值
    STAssertNoThrow([self->app setData:XAPPLICATION_LOGIC_TESTS_START_PARAMS1 forKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertEquals(XAPPLICATION_LOGIC_TESTS_START_PARAMS1, [self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 更新APP_DATA_KEY_FOR_START_PARAMS的value值
    STAssertNoThrow([self->app setData:XAPPLICATION_LOGIC_TESTS_START_PARAMS2 forKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertEquals(XAPPLICATION_LOGIC_TESTS_START_PARAMS2, [self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);
}

- (void)testGetData
{
    STAssertNoThrow([self->app getDataForKey:nil], nil);

    STAssertNil([self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 设置APP_DATA_KEY_FOR_START_PARAMS的value值
    STAssertNoThrow([self->app setData:XAPPLICATION_LOGIC_TESTS_START_PARAMS1 forKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertEquals(XAPPLICATION_LOGIC_TESTS_START_PARAMS1, [self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 更新APP_DATA_KEY_FOR_START_PARAMS的value值
    STAssertNoThrow([self->app setData:XAPPLICATION_LOGIC_TESTS_START_PARAMS2 forKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertEquals(XAPPLICATION_LOGIC_TESTS_START_PARAMS2, [self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);
}

- (void)testRemovedata
{
    STAssertNoThrow([self->app removeDataForKey:nil], nil);

    STAssertNoThrow([self->app removeDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 设置APP_DATA_KEY_FOR_START_PARAMS的value值
    STAssertNoThrow([self->app setData:XAPPLICATION_LOGIC_TESTS_START_PARAMS1 forKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 测试前检查
    STAssertEquals(XAPPLICATION_LOGIC_TESTS_START_PARAMS1, [self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 执行测试
    STAssertNoThrow([self->app removeDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 测试后检查
    STAssertNil([self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 重新设置APP_DATA_KEY_FOR_START_PARAMS的value值
    STAssertNoThrow([self->app setData:XAPPLICATION_LOGIC_TESTS_START_PARAMS2 forKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 测试前检查
    STAssertEquals(XAPPLICATION_LOGIC_TESTS_START_PARAMS2, [self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 执行测试
    STAssertNoThrow([self->app removeDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    // 测试后检查
    STAssertNil([self->app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);
}


@end
