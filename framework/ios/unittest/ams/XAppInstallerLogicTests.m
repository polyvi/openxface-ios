
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
//  XAppInstallerLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppInstaller.h"
#import "XApplicationPersistence.h"
#import "XApplicationPersistence_Privates.h"
#import "XAppList.h"
#import "XLogicTests.h"
#import "XInstallListenerStub.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XAppInstaller_Privates.h"
#import "XApplicationFactory.h"
#import "XFileUtils.h"
#import "XUtils.h"

#define XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME                        @"app.zip"
#define XAPPINSTALLER_LOGIC_TESTS_APP_UPDATE_PACKAGE_FILE_NAME                 @"updateApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_APP_BACKUP_PACKAGE_FILE_NAME                 @"backupApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_APP_UPDATE_BACKUP_PACKAGE_FILE_NAME          @"backupUpdateApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_FILE_NAME                 @"nativeApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_UPDATE_PACKAGE_FILE_NAME          @"updateNativeApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_BACKUP_PACKAGE_FILE_NAME          @"backupNativeApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_UPDATE_BACKUP_PACKAGE_FILE_NAME   @"backupUpdateNativeApp.zip"
#define XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FOLDER                           @"www"
#define XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID                           @"testAppId"
#define XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID                    @"Squaready"
#define XAPPINSTALLER_LOGIC_TESTS_APP_ICON                                     @"icon.png"
#define XAPPINSTALLER_LOGIC_TESTS_INVALID_PACKAGE_PATH                         @"invalid package path"
#define XAPPINSTALLER_LOGIC_TESTS_INVALID_APP_ID                               @"invalidAppId"

@implementation XUtils(testStub)

+ (id)rootViewController
{
    UIViewController* rootViewControllerc = [[UIViewController alloc] init];
    return rootViewControllerc;
}

@end

@interface XAppInstallerLogicTests : XLogicTests
{
@private
    XAppInstaller           *appInstaller;
    XAppList                *appList;
    XApplicationPersistence *appPersistence;
    XInstallListenerStub    *installListener;
    NSString                *appPackageFilePath;
    NSString                *appUpdatePackageFilePath;
    NSString                *appBackupPackageFilePath;
    NSString                *appBackupUpdatePackageFilePath;
    NSString                *nativeAppPackageFilePath;
    NSString                *nativeAppUpdatePackageFilePath;
    NSString                *nativeAppBackupPackageFilePath;
    NSString                *nativeAppBackupUpdatePackageFilePath;
    NSString                *appInstalledPath;
}

@end

@implementation XAppInstallerLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->appList = [[XAppList alloc] init];
    STAssertNotNil(self->appList, @"Failed to create XAppList instance");

    self->appPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(self->appPersistence, @"Failed to create XApplicationPersistence instance");

    self->appInstaller = [[XAppInstaller alloc] initWithAppList:self->appList appPersistence:self->appPersistence];
    STAssertNotNil(self->appInstaller, @"Failed to create XAppInstaller instance");

    self->installListener = [[XInstallListenerStub alloc] init];
    STAssertNotNil(self->installListener, @"Failed to create XInstallListenerStubs instance");

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self->appPackageFilePath = [bundle pathForResource:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME ofType:nil inDirectory:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FOLDER];
    STAssertTrueNoThrow(([self->appPackageFilePath length] > 0), nil);

    self->appUpdatePackageFilePath = [bundle pathForResource:XAPPINSTALLER_LOGIC_TESTS_APP_UPDATE_PACKAGE_FILE_NAME ofType:nil inDirectory:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FOLDER];
    STAssertTrueNoThrow(([self->appUpdatePackageFilePath length] > 0), nil);

    self->nativeAppPackageFilePath = [bundle pathForResource:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_FILE_NAME ofType:nil inDirectory:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FOLDER];
    STAssertTrueNoThrow(([self->nativeAppPackageFilePath length] > 0), nil);

    self->nativeAppUpdatePackageFilePath = [bundle pathForResource:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_UPDATE_PACKAGE_FILE_NAME ofType:nil inDirectory:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_FOLDER];
    STAssertTrueNoThrow(([self->nativeAppUpdatePackageFilePath length] > 0), nil);

    self->appInstalledPath = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@", XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID, FILE_SEPARATOR];
    STAssertTrueNoThrow(([self->appInstalledPath length] > 0), nil);

    // 成功执行install后，应用安装包会被删除，为避免对其他测试案例的影响，此处对应用安装包做备份
    // 处理web app安装包
    self->appBackupPackageFilePath = [self->appPackageFilePath stringByReplacingOccurrencesOfString:[self->appPackageFilePath lastPathComponent] withString:XAPPINSTALLER_LOGIC_TESTS_APP_BACKUP_PACKAGE_FILE_NAME];

    self->appBackupUpdatePackageFilePath = [self->appUpdatePackageFilePath stringByReplacingOccurrencesOfString:[self->appUpdatePackageFilePath lastPathComponent] withString:XAPPINSTALLER_LOGIC_TESTS_APP_UPDATE_BACKUP_PACKAGE_FILE_NAME];

    [XFileUtils copyItemAtPath:self->appPackageFilePath toPath:self->appBackupPackageFilePath error:nil];
    [XFileUtils copyItemAtPath:self->appUpdatePackageFilePath toPath:self->appBackupUpdatePackageFilePath error:nil];

    // 处理native app安装包
    self->nativeAppBackupPackageFilePath = [self->nativeAppPackageFilePath stringByReplacingOccurrencesOfString:[self->nativeAppPackageFilePath lastPathComponent] withString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_BACKUP_PACKAGE_FILE_NAME];

    self->nativeAppBackupUpdatePackageFilePath = [self->nativeAppUpdatePackageFilePath stringByReplacingOccurrencesOfString:[self->nativeAppUpdatePackageFilePath lastPathComponent] withString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_UPDATE_BACKUP_PACKAGE_FILE_NAME];

    [XFileUtils copyItemAtPath:self->nativeAppPackageFilePath toPath:self->nativeAppBackupPackageFilePath error:nil];
    [XFileUtils copyItemAtPath:self->nativeAppUpdatePackageFilePath toPath:self->nativeAppBackupUpdatePackageFilePath error:nil];
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [XFileUtils moveItemAtPath:self->appBackupPackageFilePath toPath:self->appPackageFilePath error:nil];
    [XFileUtils moveItemAtPath:self->appBackupUpdatePackageFilePath toPath:self->appUpdatePackageFilePath error:nil];
    [XFileUtils moveItemAtPath:self->nativeAppBackupPackageFilePath toPath:self->nativeAppPackageFilePath error:nil];
    [XFileUtils moveItemAtPath:self->nativeAppBackupUpdatePackageFilePath toPath:self->nativeAppUpdatePackageFilePath error:nil];
    [super tearDown];
}

- (void)testInit
{
    XAppList *applicationList = [[XAppList alloc] init];
    STAssertNotNil(applicationList, @"Failed to create XAppList instance");

    XApplicationPersistence *applicationPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(applicationPersistence, @"Failed to create XApplicationPersistence instance");

    XAppInstaller *applicationInstaller = [[XAppInstaller alloc] init];
    STAssertNotNil(applicationInstaller, @"Failed to create XAppInstaller instance");
}

- (void)testInstallWithNilArgs
{
    STAssertNoThrow([self->appInstaller install:nil withListener:nil], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
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
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试:测试安装包路径为无效路径的情况
    STAssertNoThrow([self->appInstaller install:XAPPINSTALLER_LOGIC_TESTS_INVALID_PACKAGE_PATH withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
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
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
}

- (void)testInstallWithAppAlreadyExistedError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 数据准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], APP_ALREADY_EXISTED, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
}

- (void)testInstallIdenticalWebAppSimultaneously
{
    XInstallListenerStub *anotherInstallListener = [[XInstallListenerStub alloc] init];

    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], UNKNOWN, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertFalse([anotherInstallListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:anotherInstallListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], NO_SRC_PACKAGE, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertTrue([anotherInstallListener isOnErrorInvoked], nil);

    //安装成功后，应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
}

- (void)testInstallWebApp
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([[[[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] appInfo] srcPath] isEqualToString:[XUtils buildWorkspaceAppSrcPath:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID]], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);

    //安装成功后，应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
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
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试：测试安装包路径为无效路径的情况
    STAssertNoThrow([self->appInstaller update:XAPPINSTALLER_LOGIC_TESTS_INVALID_PACKAGE_PATH withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
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
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
}

- (void)testUpdateWithNoTargetAppError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], NO_TARGET_APP, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
}

- (void)testUpdateWebAppWithEqualVersion
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 准备应用安装包
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self->appPackageFilePath])
    {
        __autoreleasing NSError *error;
        BOOL ret = [fileManager copyItemAtPath:self->appBackupPackageFilePath toPath:self->appPackageFilePath error:&error];
        if (!ret)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
}

- (void)testUpdateWebApp
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appUpdatePackageFilePath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appUpdatePackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[[[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] appInfo] srcPath] isEqualToString:[XUtils buildWorkspaceAppSrcPath:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID]], nil);
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appUpdatePackageFilePath], nil);
}

- (void)testUsePackagedAppUpdatePreinstalledApp
{
    // 数据准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID];
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *preinstalledAppsPath = [mainBundle pathForResource:PREINSTALLED_APPLICATIONS_FLODER ofType:nil inDirectory:APPLICATION_WWW_FOLDER];
    STAssertNotNil(preinstalledAppsPath, nil);

    NSString *srcRootUnderWWW = [preinstalledAppsPath stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, @"testAppId", FILE_SEPARATOR];
    [appInfo setSrcRoot:APP_ROOT_PREINSTALLED];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [self->appList add:app];
    [self->appPersistence addAppToConfig:app];

    // 测试前检查
    STAssertTrue([[[[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] appInfo] srcPath] isEqualToString:srcRootUnderWWW], nil);
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appUpdatePackageFilePath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appUpdatePackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertFalse([[[[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] appInfo] srcPath] isEqualToString:srcRootUnderWWW], nil);
    STAssertTrue([[[[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] appInfo] srcPath] isEqualToString:[XUtils buildWorkspaceAppSrcPath:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID]], nil);
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appUpdatePackageFilePath], nil);
}

- (void)testUpdateIdenticalWebAppSimultaneously
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->appUpdatePackageFilePath], nil);

    XInstallListenerStub *anotherInstallListener = [[XInstallListenerStub alloc] init];
    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], UNKNOWN, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertFalse([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->appUpdatePackageFilePath withListener:self->installListener], nil);
    STAssertNoThrow([self->appInstaller update:self->appUpdatePackageFilePath withListener:anotherInstallListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appPackageFilePath], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->appUpdatePackageFilePath], nil);

    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], UPDATE, nil);
    STAssertEquals([anotherInstallListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);
}

- (void)testUninstallWithNilArgs
{
    STAssertNoThrow([self->appInstaller uninstall:nil withListener:nil], nil);

    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller uninstall:nil withListener:self->installListener], nil);

    // 测试后检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_TARGET_APP, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
}

- (void)testUninstallWithNoTargetAppError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_INVALID_APP_ID withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_INVALID_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_TARGET_APP, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
}

- (void)testUninstallWhenAppNotInstalled
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], NO_TARGET_APP, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
}

- (void)testUninstallWithIOError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 环境准备：添加app到app list中
    XAppInfo *appInfo =  [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [self->appList add:app];

    // 执行测试
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], IO_ERROR, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
}

- (void)testUninstallWebApp
{
    // 数据准备：安装一个app
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);

    // 执行测试：卸载应用
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);
}

- (void)testUninstallWebAppIdenticalAppSimultaneously
{
    // 数据准备：安装一个app
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->appPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);

    XInstallListenerStub *anotherInstallListener = [[XInstallListenerStub alloc] init];
    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], UNKNOWN, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertFalse([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);

    // 执行测试：同时卸载应用
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID withListener:self->installListener], nil);

    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID withListener:anotherInstallListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    STAssertTrue([[anotherInstallListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([anotherInstallListener operationType], UNINSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], NO_TARGET_APP, nil);
    STAssertTrue([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);
}

// 以下测试安装包为native app的情况
- (void)testInstallNativeAppWithAppAlreadyExistedError
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 数据准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID];
    [appInfo setType:APP_TYPE_NAPP];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], APP_ALREADY_EXISTED, nil);
    STAssertTrue([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
}

- (void)testInstallIdenticalNativeAppSimultaneously
{
    XInstallListenerStub *anotherInstallListener = [[XInstallListenerStub alloc] init];

    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], UNKNOWN, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertFalse([anotherInstallListener isOnErrorInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:anotherInstallListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], NO_SRC_PACKAGE, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertTrue([anotherInstallListener isOnErrorInvoked], nil);

    //安装成功后，应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
}

- (void)testInstallNativeApp
{
    // 测试前检查
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);

    //安装成功后，应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
}

- (void)testUpdateNativeAppWithEqualVersion
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);

    // 准备应用安装包
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self->nativeAppPackageFilePath])
    {
        __autoreleasing NSError *error;
        BOOL ret = [fileManager copyItemAtPath:self->nativeAppBackupPackageFilePath toPath:self->nativeAppPackageFilePath error:&error];
        if (!ret)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
}

- (void)testUpdateNativeApp
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppUpdatePackageFilePath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->nativeAppUpdatePackageFilePath withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 应用安装包被删除
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppUpdatePackageFilePath], nil);
}

- (void)testUpdateIdenticalNativeAppSimultaneously
{
    // 数据准备：安装一个app
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppUpdatePackageFilePath], nil);

    XInstallListenerStub *anotherInstallListener = [[XInstallListenerStub alloc] init];
    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], UNKNOWN, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertFalse([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller update:self->nativeAppUpdatePackageFilePath withListener:self->installListener], nil);
    STAssertNoThrow([self->appInstaller update:self->nativeAppUpdatePackageFilePath withListener:anotherInstallListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UPDATE, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppPackageFilePath], nil);
    STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self->nativeAppUpdatePackageFilePath], nil);

    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], UPDATE, nil);
    STAssertEquals([anotherInstallListener amsError], NO_SRC_PACKAGE, nil);
    STAssertTrue([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);
}

- (void)testUninstallNativeApp
{
    // 数据准备：安装一个app
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);

    // 执行测试：卸载应用
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID withListener:self->installListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);
}

- (void)testUninstallIdenticalNativeAppSimultaneously
{
    // 数据准备：安装一个app
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);

    // 安装应用
    STAssertNoThrow([self->appInstaller install:self->nativeAppPackageFilePath withListener:self->installListener], nil);

    // 检查应用是否安装成功
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], FINISHED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertTrue([[self->appList getAppById:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID] isNative], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertTrue([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);

    // 测试前检查
    [self->installListener reset];
    STAssertNil([self->installListener applicationId], nil);
    STAssertEquals([self->installListener operationType], INSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertEquals([self->installListener status], INITIALIZED, nil);
    STAssertTrue([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([self->installListener isOnSuccessInvoked], nil);
    STAssertTrue((1 == [[self->appPersistence getAppsDict] count]), nil);

    XInstallListenerStub *anotherInstallListener = [[XInstallListenerStub alloc] init];
    STAssertNil([anotherInstallListener applicationId], nil);
    STAssertEquals([anotherInstallListener operationType], INSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], UNKNOWN, nil);
    STAssertEquals([anotherInstallListener status], INITIALIZED, nil);
    STAssertFalse([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);

    // 执行测试：同时卸载应用
    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID withListener:self->installListener], nil);

    STAssertNoThrow([self->appInstaller uninstall:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID withListener:anotherInstallListener], nil);

    // 测试后检查
    STAssertTrue([[self->installListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([self->installListener operationType], UNINSTALL, nil);
    STAssertEquals([self->installListener amsError], UNKNOWN, nil);
    STAssertFalse([self->appList containsApp:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertFalse([self->installListener isOnErrorInvoked], nil);
    STAssertFalse([self->installListener isOnProgressUpdatedInvoked ], nil);
    STAssertTrue([self->installListener isOnSuccessInvoked], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    STAssertTrue([[anotherInstallListener applicationId] isEqualToString:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
    STAssertEquals([anotherInstallListener operationType], UNINSTALL, nil);
    STAssertEquals([anotherInstallListener amsError], NO_TARGET_APP, nil);
    STAssertTrue([anotherInstallListener isOnErrorInvoked], nil);
    STAssertFalse([anotherInstallListener isOnProgressUpdatedInvoked ], nil);
    STAssertFalse([anotherInstallListener isOnSuccessInvoked], nil);
}

// 测试私有方法
- (void)testBuildPathForAppThrows
{
    STAssertThrows([XUtils buildWorkspaceAppSrcPath:nil], nil);
    STAssertThrows([XUtils buildWorkspaceAppSrcPath:@""], nil);
}

- (void)testBuildPathForApp
{
    NSString *path = nil;
    // 执行测试
    STAssertNoThrow((path = [XUtils buildWorkspaceAppSrcPath:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID]), nil);

    // 测试后检查
    STAssertTrue([path hasPrefix:[[XConfiguration getInstance] appInstallationDir]], nil);
    STAssertTrue([path hasSuffix:[XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID stringByAppendingString:FILE_SEPARATOR]], nil);

    // 执行测试
    STAssertNoThrow((path = [XUtils buildWorkspaceAppSrcPath:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID]), nil);

    // 测试后检查
    STAssertTrue([path hasPrefix:[[XConfiguration getInstance] appInstallationDir]], nil);
    STAssertTrue([path hasSuffix:[XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID stringByAppendingString:FILE_SEPARATOR]], nil);
}

- (void)testDeleteAppIconWithAppIdThrows
{
    STAssertThrows([self->appInstaller deleteAppIconWithAppId:nil], nil);
    STAssertThrows([self->appInstaller deleteAppIconWithAppId:@""], nil);
}

- (void)testDeleteAppIconWithAppIdWhenIconNonexistent
{
    STAssertNoThrow([self->appInstaller deleteAppIconWithAppId:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertNoThrow([self->appInstaller deleteAppIconWithAppId:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID], nil);
}

- (void)testDeleteAppIconWithAppId
{
    // 搭建测试环境
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID relativeIconPath:nil];
    STAssertNotNil(iconPath, nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:iconPath withIntermediateDirectories:YES attributes:nil error:nil];

    // 测试前检查
    STAssertTrue([fileManager fileExistsAtPath:iconPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller deleteAppIconWithAppId:XAPPINSTALLER_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);

    // 测试后检查
    STAssertFalse([fileManager fileExistsAtPath:iconPath], nil);
}

- (void)testMoveAppIconWithAppInfoThrows
{
    STAssertThrows([self->appInstaller moveAppIconWithAppInfo:nil], nil);
    STAssertThrows([self->appInstaller moveAppIconWithAppInfo:[[XAppInfo alloc] init]], nil);
}

- (void)testMoveAppIconWithAppInfoWhenIconPathEmpty
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID];

    NSString *iconWorkspace = [XUtils buildWorkspaceAppSrcPath:[appInfo appId]];
    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:iconWorkspace];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];
    STAssertNotNil(iconDstPath, nil);
    STAssertTrue([iconSrcPath isEqualToString:iconWorkspace], nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller moveAppIconWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);
}

- (void)testMoveAppIconWithAppInfoWhenIconNonexistent
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID];
    [appInfo setIcon:XAPPINSTALLER_LOGIC_TESTS_APP_ICON];

    NSString *iconWorkspace = [XUtils buildWorkspaceAppSrcPath:[appInfo appId]];
    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:iconWorkspace];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];
    STAssertNotNil(iconDstPath, nil);
    STAssertFalse([iconSrcPath isEqualToString:iconWorkspace], nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller moveAppIconWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);
}

- (void)testMoveAppIconWithAppInfo
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPINSTALLER_LOGIC_TESTS_NATIVE_APP_PACKAGE_APP_ID];
    [appInfo setIcon:XAPPINSTALLER_LOGIC_TESTS_APP_ICON];

    NSString *iconWorkspace = [XUtils buildWorkspaceAppSrcPath:[appInfo appId]];
    NSString *iconSrcPath = [XUtils resolvePath:[appInfo icon] usingWorkspace:iconWorkspace];
    NSString *iconDstPath = [XUtils generateAppIconPathUsingAppId:[appInfo appId] relativeIconPath:[appInfo icon]];
    STAssertNotNil(iconDstPath, nil);
    STAssertFalse([iconSrcPath isEqualToString:iconWorkspace], nil);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 搭建环境
    [fileManager createDirectoryAtPath:iconSrcPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:iconDstPath contents:[NSData data] attributes:nil];

    // 测试前检查
    STAssertTrue([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:iconDstPath], nil);

    // 执行测试
    STAssertNoThrow([self->appInstaller moveAppIconWithAppInfo:appInfo], nil);

    // 测试后检查
    STAssertFalse([fileManager fileExistsAtPath:iconSrcPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:iconDstPath], nil);

    // 清理测试环境
    [XFileUtils removeItemAtPath:iconDstPath error:nil];
}

@end
