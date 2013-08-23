
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
//  XAppManagementLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppManagement.h"
#import "XAmsDelegate.h"
#import "XAppList.h"
#import "XAppInfo.h"
#import "XApplication.h"
#import "XAppManagement_Privates.h"
#import "NSMutableArray+XStackAdditions.h"
#import "XAppViewStub.h"
#import "XLogicTests.h"
#import "XInstallListenerStub.h"
#import "XApplicationFactory.h"
#import "XConstants.h"
#import "XApplicationPersistence.h"
#import "XApplicationPersistence_Privates.h"
#import "XConfiguration.h"

#define XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID                 @"defaultAppId"
#define XAPPMANAGEMENT_LOGIC_TESTS_APP_ID                         @"appId"
#define XAPPMANAGEMENT_LOGIC_TESTS_ANOTHER_APP_ID                 @"anotherAppId"
#define XAPPMANAGEMENT_LOGIC_TESTS_START_PARAMS                   @"Admin;123"
#define XAPPMANAGEMENT_LOGIC_TESTS_START_PARAMS_DATA              @"Admin;123"
#define XAPPMANAGEMENT_LOGIC_TESTS_APP_PACKAGE_FILE_NAME          @"app.zip"
#define XAPPMANAGEMENT_LOGIC_TESTS_NATIVE_APP_PACKAGE_FILE_NAME   @"nativeApp.zip"

@interface XAmsDelegateStub : NSObject <XAmsDelegate>

@property (strong, nonatomic) XAppManagement *appManagement;

@end

@implementation XAmsDelegateStub
@synthesize appManagement;

-(void) startApp:(id<XApplication>)app
{
    NSAssert(![app isActive], nil);
    XAppViewStub *viewStub = [[XAppViewStub alloc] init];
    [app setAppView:viewStub];
}

-(void) closeApp:(id<XApplication>)app
{
    NSAssert([app isActive], nil);
    [app setAppView:nil];
}

@end

@interface XAppManagementLogicTests : XLogicTests
{
@private
    XAppManagement *appManagement;
    XAmsDelegateStub *amsDelegateStub; // 增加此变量的目的是避免amsDelegate被释放（amsDelegate property使用的是weak reference）
}

@end

@implementation XAppManagementLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    amsDelegateStub = [[XAmsDelegateStub alloc] init];

    appManagement = [[XAppManagement alloc] initWithAmsDelegate:amsDelegateStub];
    [amsDelegateStub setAppManagement:appManagement];
    STAssertNotNil(appManagement, @"Failed to create rootViewController instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

- (void)testInitWithAmsDelegate
{
    XAppManagement *applicationManagement = [[XAppManagement alloc] initWithAmsDelegate:[[XAmsDelegateStub alloc] init]];

    STAssertNotNil(applicationManagement, @"Failed to initialize XAppManagement");
    STAssertNotNil([applicationManagement appList], nil);
    STAssertEquals((NSUInteger)0, [[[applicationManagement.appList getEnumerator] allObjects] count], nil);
}

- (void)testStartDefaultAppWithNilDefaultAppId
{
    // 测试没有设置default app的情况
    // 测试前检查
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);

    STAssertNoThrow([appManagement startDefaultAppWithParams:nil], nil);

    // 测试后检查
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
}

- (void)testStartDefaultAppWithNilParams
{
    // 搭建测试环境
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:app];
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];

    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
    STAssertNil([app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertNoThrow([appManagement startDefaultAppWithParams:nil], nil);

    // 测试后检查
    STAssertTrue([app isActive], nil);
    STAssertNil([app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);
}

- (void)testStartDefaultAppWithParams
{
    STAssertNoThrow([self->appManagement startDefaultAppWithParams:nil], nil);

    // 搭建测试环境
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:app];
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];

    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
    STAssertNil([app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertNoThrow([appManagement startDefaultAppWithParams:XAPPMANAGEMENT_LOGIC_TESTS_START_PARAMS], nil);

    // 测试后检查
    STAssertTrue([app isActive], nil);
    STAssertTrue([XAPPMANAGEMENT_LOGIC_TESTS_START_PARAMS_DATA isEqualToString:[app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS]], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);
}

- (void)testIsDefaultAppWithTrueResult
{
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    BOOL ret = [appManagement isDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    STAssertTrue(ret, nil);
}

- (void)testIsDefaultAppWithFalseResult
{
    // 测试没有设置默认应用的情况
    BOOL ret = [appManagement isDefaultApp:nil];
    STAssertFalse(ret, nil);

    ret = [appManagement isDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    STAssertFalse(ret, nil);

    // 测试设置默认应用的情况
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    ret = [appManagement isDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    STAssertFalse(ret, nil);
}

- (void)testStartAppWithInvalidApp
{
    // 测试applist为空的情况
    STAssertFalse([appManagement startApp:nil withParameters:nil], nil);
    STAssertFalse([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试applist非空的情况
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:app];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);

    STAssertFalse([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试后检查
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
}

- (void)testStartAppWithParams
{
    // 搭建测试环境
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [[appManagement appList] add:app];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
    STAssertNil([app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS], nil);

    STAssertTrue([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:XAPPMANAGEMENT_LOGIC_TESTS_START_PARAMS], nil);

    // 测试后检查
    STAssertTrue([app isActive], nil);
    STAssertTrue([XAPPMANAGEMENT_LOGIC_TESTS_START_PARAMS_DATA isEqualToString:[app getDataForKey:APP_DATA_KEY_FOR_START_PARAMS]], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    // 测试启动active app的情况
    STAssertFalse([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试后检查：正在运行的应用数量没有增加
    STAssertTrue([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);
}

- (void)testStartApp
{
    // 搭建测试环境
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [[appManagement appList] add:app];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);

    STAssertTrue([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试后检查
    STAssertTrue([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    // 测试启动active app的情况
    STAssertFalse([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试后检查：正在运行的应用数量没有增加
    STAssertTrue([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);
}

- (void)testCloseAppWithInvalidApp
{
    // 测试applist为空的情况
    STAssertNoThrow([appManagement closeApp:nil], nil);
    STAssertNoThrow([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID], nil);

    // 搭建测试环境
    XAppInfo *defaultAppInfo = [[XAppInfo alloc] init];
    id<XApplication> defaultApp = [XApplicationFactory create:defaultAppInfo];
    [[defaultApp appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:defaultApp];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // applist中没有找到相应的app
    STAssertNoThrow([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID], nil);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [[appManagement appList] add:app];
    STAssertEquals((NSUInteger)2, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    [[appManagement activeApps] push:app];
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    // applist中找到相应的app,但app并没有正在运行，即关闭一个没有启动的应用
    STAssertThrows([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID], nil);

    // 测试后检查：正在运行的应用数量没有减少
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);
}

- (void)testCloseApp
{
    // 搭建测试环境:添加两个app
    XAppInfo *defaultAppInfo = [[XAppInfo alloc] init];
    id<XApplication> defaultApp = [XApplicationFactory create:defaultAppInfo];
    [[defaultApp appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:defaultApp];
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [[appManagement appList] add:app];
    STAssertEquals((NSUInteger)2, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID withParameters:nil], nil);

    // 测试前检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    // 测试当前有正在运行的应用，但是关闭一个没有启动的应用的情况
    STAssertThrows([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID], nil);

    // 测试后检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试前检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertTrue([app isActive], nil);
    STAssertTrue((2 == [[appManagement activeApps] count]), nil);

    // 测试关闭已启动的应用的情况
    STAssertNoThrow([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID], nil);

    // 测试后检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    // 测试多次关闭一个应用的情况
    STAssertThrows([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID], nil);

    // 测试后检查：对一个已经关闭或没有启动的应用执行关闭操作，对当前环境没有造成任何影响
    STAssertTrue([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    // 测试关闭默认应用的情况
    STAssertNoThrow([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID], nil);

    // 测试后检查
    STAssertFalse([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
}

- (void)testCloseAppMultipleActiveApps
{
    // 测试启动多个应用，不按特定顺序关闭的情况
    // 搭建测试环境:添加三个app
    XAppInfo *defaultAppInfo = [[XAppInfo alloc] init];
    id<XApplication> defaultApp = [XApplicationFactory create:defaultAppInfo];
    [[defaultApp appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:defaultApp];
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    XAppInfo *firstAppInfo = [[XAppInfo alloc] init];
    id<XApplication> firstApp = [XApplicationFactory create:firstAppInfo];
    [[firstApp appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [[appManagement appList] add:firstApp];
    STAssertEquals((NSUInteger)2, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    XAppInfo *secondAppInfo = [[XAppInfo alloc] init];
    id<XApplication>secondApp = [XApplicationFactory create:secondAppInfo];
    [[secondApp appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_ANOTHER_APP_ID];
    [[appManagement appList] add:secondApp];
    STAssertEquals((NSUInteger)3, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    // 测试前检查
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);

    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID withParameters:nil], nil);
    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);
    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_ANOTHER_APP_ID withParameters:nil], nil);

    // 应用启动后检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertTrue([firstApp isActive], nil);
    STAssertTrue([secondApp isActive], nil);
    STAssertTrue((3 == [[appManagement activeApps] count]), nil);

    // 执行测试
    STAssertNoThrow([appManagement closeApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID], nil);

    // 测试后检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertFalse([firstApp isActive], nil);
    STAssertTrue([secondApp isActive], nil);
    STAssertTrue((2 == [[appManagement activeApps] count]), nil);

    // 测试acitive app是否正确
    STAssertEqualObjects([[appManagement activeApps] peek], secondApp, nil);
}

- (void)testCloseAllAppsWithNoAcitveApp
{
    STAssertNoThrow([appManagement closeAllApps], nil);
}

- (void)testCloseAllApps
{
    // 搭建测试环境:添加并启动两个app
    XAppInfo *defaultAppInfo = [[XAppInfo alloc] init];
    id<XApplication> defaultApp = [XApplicationFactory create:defaultAppInfo];
    [[defaultApp appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    [[appManagement appList] add:defaultApp];
    [[appManagement appList] markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID];
    STAssertEquals((NSUInteger)1, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [[appManagement appList] add:app];
    STAssertEquals((NSUInteger)2, [[[appManagement.appList getEnumerator] allObjects] count], nil);

    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_DEFAULT_APP_ID withParameters:nil], nil);

    // 测试前检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((1 == [[appManagement activeApps] count]), nil);

    STAssertNoThrow([appManagement startApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID withParameters:nil], nil);

    // 测试前检查
    STAssertTrue([defaultApp isActive], nil);
    STAssertTrue([app isActive], nil);
    STAssertTrue((2 == [[appManagement activeApps] count]), nil);

    // 执行测试
    STAssertNoThrow([appManagement closeAllApps], nil);

    // 测试后检查
    STAssertFalse([defaultApp isActive], nil);
    STAssertFalse([app isActive], nil);
    STAssertTrue((0 == [[appManagement activeApps] count]), nil);
}

- (void)testMarkAsDefaultApp
{
    // 测试前检查
    STAssertNil([[self->appManagement appList] defaultAppId], nil);
    STAssertNil([[self->appManagement appPersistence] getDefaultAppId], nil);

    // 环境准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    NSString *srcRoot = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@", XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    STAssertNoThrow([[self->appManagement appPersistence] addAppToConfig:app], nil);

    // 执行测试
    [self->appManagement markAsDefaultApp:XAPPMANAGEMENT_LOGIC_TESTS_APP_ID];

    // 测试后检查
    STAssertEquals(XAPPMANAGEMENT_LOGIC_TESTS_APP_ID, [[self->appManagement appList] defaultAppId], nil);
    STAssertEquals(XAPPMANAGEMENT_LOGIC_TESTS_APP_ID, [[self->appManagement appPersistence] getDefaultAppId], nil);
}

- (void)testShouldUseLightweightInstallerWithTrueResult
{
    STAssertTrue([self->appManagement shouldUseLightweightInstaller:nil], nil);
    STAssertTrue([self->appManagement shouldUseLightweightInstaller:[[XConfiguration getInstance] systemWorkspace]], nil);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appSrcPath = [bundle pathForResource:XFACE_WORKSPACE_NAME_UNDER_APP ofType:nil inDirectory:APPLICATION_WWW_FOLDER];
    STAssertTrue([self->appManagement shouldUseLightweightInstaller:appSrcPath], nil);
}

- (void)testShouldUseLightweightInstallerWithFalseResult
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appPackageFilePath = [bundle pathForResource:XAPPMANAGEMENT_LOGIC_TESTS_APP_PACKAGE_FILE_NAME ofType:nil inDirectory:APPLICATION_WWW_FOLDER];
    STAssertTrueNoThrow(([appPackageFilePath length] > 0), nil);

    // 执行测试
    STAssertFalse([self->appManagement shouldUseLightweightInstaller:appPackageFilePath], nil);

    NSString *nativeAppPackageFilePath = [bundle pathForResource:XAPPMANAGEMENT_LOGIC_TESTS_NATIVE_APP_PACKAGE_FILE_NAME ofType:nil inDirectory:APPLICATION_WWW_FOLDER];
    STAssertTrueNoThrow(([nativeAppPackageFilePath length] > 0), nil);

    // 执行测试
    STAssertFalse([self->appManagement shouldUseLightweightInstaller:nativeAppPackageFilePath], nil);
}

@end
