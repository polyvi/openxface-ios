
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
//  XLightweightAppInstallerLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XLightweightAppInstaller.h"
#import "XLightweightAppInstaller_Privates.h"
#import "XApplicationPersistence.h"
#import "XApplicationPersistence_Privates.h"
#import "XAppList.h"
#import "XLogicTests.h"
#import "XInstallListenerStub.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XApplicationFactory.h"
#import "XFileUtils.h"
#import "XUtils.h"

#define XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_INVALID_APP_SRC_PATH1      @"invalidAppSrcPath"
#define XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_INVALID_APP_SRC_PATH2      @"invalidAppSrcPath"
#define XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID                @"testAppId"
#define XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_SRC_DIR           @"testAppId"
#define XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_INVALID_TEST_APP_SRC_DIR   @"invalidTestApp"
#define LIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_APP_ICON                    @"//image/icon.png"

#define kAppIdWithDot           @"test.App.Id"

@interface XLightweightAppInstallerLogicTests : XLogicTests
{
@private
    XLightweightAppInstaller  *appInstaller;
    XAppList                  *appList;
    XApplicationPersistence   *appPersistence;
    XInstallListenerStub      *installListener;
    NSString                  *appSrcPath;
    NSString                  *appSrcPathWithDot;
    NSString                  *appSrcRoot;
    NSString                  *invalidAppSrcRoot;
}

@end

@implementation XLightweightAppInstallerLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->appList = [[XAppList alloc] init];
    STAssertNotNil(self->appList, @"Failed to create XAppList instance");

    self->appPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(self->appPersistence, @"Failed to create XApplicationPersistence instance");

    self->appInstaller = [[XLightweightAppInstaller alloc] initWithAppList:self->appList appPersistence:self->appPersistence];
    STAssertNotNil(self->appInstaller, @"Failed to create XLightweightAppInstaller instance");

    self->installListener = [[XInstallListenerStub alloc] init];
    STAssertNotNil(self->installListener, @"Failed to create XInstallListenerStubs instance");

    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *preinstalledAppsPath = [mainBundle pathForResource:PREINSTALLED_APPLICATIONS_FLODER ofType:nil inDirectory:APPLICATION_WWW_FOLDER];
    STAssertNotNil(preinstalledAppsPath, nil);

    self->appSrcPath = [preinstalledAppsPath stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_SRC_DIR, FILE_SEPARATOR];
    STAssertNotNil(self->appSrcPath, nil);

    self->appSrcPathWithDot = [preinstalledAppsPath stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, kAppIdWithDot, FILE_SEPARATOR];
    STAssertNotNil(self->appSrcPathWithDot, nil);


    self->appSrcRoot = APP_ROOT_PREINSTALLED;

    self->invalidAppSrcRoot = [preinstalledAppsPath stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_INVALID_TEST_APP_SRC_DIR, FILE_SEPARATOR];
    STAssertNotNil(self->invalidAppSrcRoot, nil);
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

- (void)testInit
{
    XAppList *applicationList = [[XAppList alloc] init];
    STAssertNotNil(applicationList, @"Failed to create XAppList instance");

    XApplicationPersistence *applicationPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(applicationPersistence, @"Failed to create XApplicationPersistence instance");

    XLightweightAppInstaller *applicationInstaller = [[XLightweightAppInstaller alloc] init];
    STAssertNotNil(applicationInstaller, @"Failed to create XLightweightAppInstaller instance");
}

- (void)testInstallWithNilArgs
{
    STAssertNoThrow([self->appInstaller install:nil withListener:nil], nil);
}

- (void)testInstallWithNoSrcError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:nil withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试:测试app src路径为无效路径的情况
    STAssertNoThrow([self->appInstaller install:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_INVALID_APP_SRC_PATH1 withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
}

- (void)testInstallWithNoAppConfigFileError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    NSString *userAppsFilePath =  [[XConfiguration getInstance] userAppsFilePath];
    STAssertNoThrow([self->appInstaller install:userAppsFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_APP_CONFIG_FILE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 测试path为应用安装包的情况
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appPackageFilePath = [bundle pathForResource:@"app.zip" ofType:nil inDirectory:@"www"];
    STAssertTrueNoThrow(([appPackageFilePath length] > 0), nil);

    // 执行测试:测试app src路径为无效路径的情况
    STAssertNoThrow([self->appInstaller install:appPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_APP_CONFIG_FILE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
}

- (void)testInstall
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->appSrcPath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertTrue([self->appList containsApp:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] isNative], nil);
    STAssertTrue([[[[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] appInfo] srcPath] isEqualToString:self->appSrcPath], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);
    STAssertTrue([[[self->appPersistence getAppsDict] objectForKey:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] isEqualToString:self->appSrcRoot], nil);
}

- (void)testInstallWithAppIDWithDot
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:kAppIdWithDot], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->appSrcPathWithDot withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:kAppIdWithDot], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertTrue([self->appList containsApp:kAppIdWithDot], nil);
    STAssertFalse([[self->appList getAppById:kAppIdWithDot] isNative], nil);
    STAssertTrue([[[[self->appList getAppById:kAppIdWithDot] appInfo] srcPath] isEqualToString:self->appSrcPathWithDot], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);
    STAssertTrue([[[self->appPersistence getAppsDict] objectForKey:kAppIdWithDot] isEqualToString:self->appSrcRoot], nil);
}

- (void)testUpdateWithNilArgs
{
    STAssertNoThrow([self->appInstaller update:nil withListener:nil], nil);
}

- (void)testUpdateWithNoSrcError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:nil withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试：测试安装包路径为无效路径的情况
    STAssertNoThrow([self->appInstaller update:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_INVALID_APP_SRC_PATH1 withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
}

- (void)testUpdateWithNoAppConfigFileError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    NSString *userAppsFilePath =  [[XConfiguration getInstance] userAppsFilePath];
    STAssertNoThrow([self->appInstaller update:userAppsFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], NO_APP_CONFIG_FILE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
}

- (void)testUpdate
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->appSrcPath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertTrue([self->appList containsApp:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] isNative], nil);
    STAssertTrue([[[[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] appInfo] srcPath] isEqualToString:self->appSrcPath], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appSrcPath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue([[[[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] appInfo] srcPath] isEqualToString:self->appSrcPath], nil);
    STAssertTrue([[[self->appPersistence getAppsDict] objectForKey:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] isEqualToString:self->appSrcRoot], nil);
}

- (void)testUsePreinstallAppUpdatePackagedApp
{
    // 数据准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    NSString *srcRootUnderDocuments = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@", XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID, FILE_SEPARATOR];
    [appInfo setSrcRoot:srcRootUnderDocuments];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [self->appList add:app];
    [self->appPersistence addAppToConfig:app];

    // 测试前检查
    STAssertTrue([self->appList containsApp:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] isNative], nil);
    STAssertTrue([[[[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] appInfo] srcPath] isEqualToString:srcRootUnderDocuments], nil);
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appSrcPath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue([[[[self->appList getAppById:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID] appInfo] srcPath] isEqualToString:self->appSrcPath], nil);
}

// 测试私有方法
- (void)testCopyAppConfigFileWithAppInfoWhenAppSrcIsNil
{
    STAssertFalseNoThrow([self->appInstaller copyAppConfigFileWithAppInfo:nil], nil);
    STAssertFalseNoThrow([self->appInstaller copyAppConfigFileWithAppInfo:[[XAppInfo alloc] init]], nil);
}

- (void)testCopyAppConfigFileWithAppInfoWhenAppConfigNonexistent
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setSrcRoot:self->invalidAppSrcRoot];

    NSString *appConfigSrcPath = [[appInfo srcRoot] stringByAppendingPathComponent:APPLICATION_CONFIG_FILE_NAME];
    NSString *appConfigDstPath = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", [appInfo appId], FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];
    STAssertNotNil(appConfigDstPath, nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:appConfigSrcPath], nil);

    // 执行测试
    STAssertFalse([self->appInstaller copyAppConfigFileWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:appConfigDstPath], nil);
}

- (void)testCopyAppConfigFileWithAppInfo
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setSrcRoot:self->appSrcPath];

    NSString *appConfigSrcPath = [[appInfo srcRoot] stringByAppendingPathComponent:APPLICATION_CONFIG_FILE_NAME];
    NSString *appConfigDstPath = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", [appInfo appId], FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];
    STAssertNotNil(appConfigDstPath, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:appConfigSrcPath], nil);

    // 执行测试
    STAssertTrue([self->appInstaller copyAppConfigFileWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:appConfigDstPath], nil);

    // 清理测试环境
    [XFileUtils removeItemAtPath:appConfigDstPath error:nil];
}

- (void)testCopyAppIconWithAppInfoThrows
{
    STAssertThrows([self->appInstaller copyAppIconWithAppInfo:nil], nil);
    STAssertThrows([self->appInstaller copyAppIconWithAppInfo:[[XAppInfo alloc] init]], nil);
}

- (void)testCopyAppIconWithAppInfoWhenIconPathEmpty
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setSrcRoot:self->invalidAppSrcRoot];

    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:[appInfo srcRoot]];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];
    STAssertNotNil(iconDstPath, nil);
    STAssertTrue([iconSrcPath isEqualToString:[appInfo srcRoot]], nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller copyAppIconWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);
}

- (void)testCopyAppIconWithAppInfoWhenIconNonexistent
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setIcon:LIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_APP_ICON];
    [appInfo setSrcRoot:self->invalidAppSrcRoot];

    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:[appInfo srcRoot]];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];
    STAssertNotNil(iconDstPath, nil);
    STAssertFalse([iconSrcPath isEqualToString:[appInfo srcRoot]], nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller copyAppIconWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);
}

- (void)testCopyAppIconWithAppInfo
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setIcon:LIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_APP_ICON];
    [appInfo setSrcRoot:self->appSrcPath];

    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:[appInfo srcRoot]];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];
    STAssertNotNil(iconDstPath, nil);
    STAssertFalse([iconSrcPath isEqualToString:[appInfo srcRoot]], nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 测试前检查
    STAssertTrue([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller copyAppIconWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertTrue([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:iconDstPath], nil);

    // 清理测试环境
    [XFileUtils removeItemAtPath:iconDstPath error:nil];
}

- (void)testUnpackAppDataWithAppInfoWhenAppSrcIsNil
{
    STAssertTrueNoThrow([self->appInstaller unpackAppDataWithAppInfo:nil], nil);
    STAssertTrueNoThrow([self->appInstaller unpackAppDataWithAppInfo:[[XAppInfo alloc] init]], nil);
}

- (void)testUnpackAppDataWithAppInfoWhenAppDataNonexistent
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setSrcRoot:self->invalidAppSrcRoot];

    NSString *dataPkgSrcPath = [[appInfo srcRoot] stringByAppendingFormat:@"%@%@%@", APP_WORKSPACE_FOLDER, FILE_SEPARATOR, APP_DATA_PACKAGE_NAME_UNDER_WORKSPACE];
    NSString *appDataDstPath =  [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", [appInfo appId], FILE_SEPARATOR, APP_WORKSPACE_FOLDER];
    STAssertNotNil(appDataDstPath, nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:dataPkgSrcPath], nil);

    // 执行测试
    STAssertTrue([self->appInstaller unpackAppDataWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:appDataDstPath], nil);
}

- (void)testUnpackAppDataWithAppInfo
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XLIGHTWEIGHT_APP_INSTALLER_LOGIC_TESTS_TEST_APP_ID];
    [appInfo setSrcRoot:self->appSrcPath];

    NSString *dataPkgSrcPath = [[appInfo srcRoot] stringByAppendingFormat:@"%@%@%@", APP_WORKSPACE_FOLDER, FILE_SEPARATOR, APP_DATA_PACKAGE_NAME_UNDER_WORKSPACE];
    NSString *appDataDstPath =  [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@%@", [appInfo appId], FILE_SEPARATOR, APP_WORKSPACE_FOLDER];
    STAssertNotNil(appDataDstPath, nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:dataPkgSrcPath], nil);

    // 执行测试
    STAssertTrue([self->appInstaller unpackAppDataWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:appDataDstPath], nil);

    // 清理测试环境
    [XFileUtils removeItemAtPath:appDataDstPath error:nil];
}

@end
