
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
//  XApplicationPersistenceLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplicationPersistence.h"
#import "XApplicationPersistence_Privates.h"
#import "XApplist.h"
#import "XLogicTests.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XAppInfo.h"
#import "XApplicationFactory.h"
#import "XApplication.h"
#import "XUtils.h"

#define XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID            @"storage"
#define XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID    @"defaultAppId"

@interface XApplicationPersistenceLogicTests : XLogicTests
{
@private
    XApplicationPersistence *appPersistence;
}
@end

@implementation XApplicationPersistenceLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->appPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(self->appPersistence, @"Failed to create XApplicationPersistence instance");

    // 创建<Applilcation_Home>/Documents/xface3_test/apps/appId/目录
    NSString *appInstallationPath = [[XConfiguration getInstance] appInstallationDir];
    appInstallationPath = [appInstallationPath stringByAppendingFormat:@"%@%@", XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID, FILE_SEPARATOR];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError * __autoreleasing error = nil;
    if(![fileMgr fileExistsAtPath:appInstallationPath])
    {
        BOOL ret = [fileMgr createDirectoryAtPath:appInstallationPath withIntermediateDirectories:YES attributes:nil error:&error];
        STAssertTrue(ret, [error localizedDescription]);
    }
}

- (void)testInit
{
    XApplicationPersistence *applicationPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(applicationPersistence, @"Failed to create XApplicationPersistence instance");
}

- (void)testReadAppsFromConfigWithNilArgs
{
    STAssertFalseNoThrow([self->appPersistence readAppsFromConfig:nil], nil);
}

- (void)testReadAppsFromConfigWithFalseResult
{
    XAppList *appList = [[XAppList alloc] init];
    STAssertFalseNoThrow([self->appPersistence readAppsFromConfig:appList], nil);
}

- (void)testReadAppsFromConfigWhenAppConfigFileNonexistent
{
    // 数据准备：添加app id到系统配置文件中
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    NSString *srcRoot = APP_ROOT_PREINSTALLED;
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [self->appPersistence addAppToConfig:app];

    // 配置文件不存在
    XAppList *appList = [[XAppList alloc] init];
    STAssertFalseNoThrow([self->appPersistence readAppsFromConfig:appList], nil);

    // 清理环境：移除系统配置文件中的app id
    [self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
}

- (void)testReadAppsFromConfig
{
    // 数据准备：添加app id到配置文件中
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    NSString *srcRoot = APP_ROOT_WORKSPACE;
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [self->appPersistence addAppToConfig:app];

    // 创建app config file
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* srcPath = [bundle pathForResource:@"app.xml" ofType:nil];
    NSString *destPath = [XUtils buildConfigFilePathWithAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];

    __autoreleasing NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertTrueNoThrow([fileManager copyItemAtPath:srcPath toPath:destPath error:&error], nil);

    // 执行测试
    XAppList *appList = [[XAppList alloc] init];
    STAssertTrueNoThrow([self->appPersistence readAppsFromConfig:appList], nil);

    // 测试后检查
    STAssertEquals((NSUInteger)1, [[[appList getEnumerator] allObjects] count], nil);
    STAssertTrueNoThrow([appList containsApp:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);

    // 清理环境：移除系统配置文件中的app id
    [self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];

    // 移除app config file
    STAssertTrueNoThrow([fileManager removeItemAtPath:destPath error:nil], nil);
}

- (void)testAddAppToConfigWithThrows
{
    // 测试参数为nil的情况
    STAssertThrows([self->appPersistence addAppToConfig:nil], nil);

    // 测试appId为nil的情况
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    STAssertThrows([self->appPersistence addAppToConfig:app], nil);

    // 测试appSrcRoot为nil的情况
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    STAssertThrows([self->appPersistence addAppToConfig:app], nil);
}

- (void)testAddAppToConfig
{
    // 测试前检查
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 数据准备
    XAppInfo *appInfo1 = [[XAppInfo alloc] init];
    [appInfo1 setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    NSString *srcRoot1 = APP_ROOT_WORKSPACE;
    [appInfo1 setSrcRoot:srcRoot1];
    id<XApplication> app1 = [XApplicationFactory create:appInfo1];

    // 执行测试
    STAssertNoThrow([self->appPersistence addAppToConfig:app1], nil);

    // 测试后检查
    NSMutableDictionary *appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((1 == [appsDict count]), nil);
    STAssertTrueNoThrow([[[appsDict allKeys] objectAtIndex:0] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
    STAssertTrue([srcRoot1 isEqualToString:[appsDict objectForKey:[[appsDict allKeys] objectAtIndex:0]]], nil);

    // 数据准备
    XAppInfo *appInfo2 = [[XAppInfo alloc] init];
    [appInfo2 setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID];
    NSString *srcRoot2 = APP_ROOT_PREINSTALLED;
    [appInfo2 setSrcRoot:srcRoot2];
    id<XApplication> app2 = [XApplicationFactory create:appInfo2];

    // 执行测试
    STAssertNoThrow([self->appPersistence addAppToConfig:app2], nil);

    // 测试后检查
    appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((2 == [appsDict count]), nil);
    STAssertTrueNoThrow([[[appsDict allKeys] objectAtIndex:0] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
    STAssertTrue([srcRoot1 isEqualToString:[appsDict objectForKey:[[appsDict allKeys] objectAtIndex:0]]], nil);
    STAssertTrueNoThrow([[[appsDict allKeys] objectAtIndex:1] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
    STAssertTrue([srcRoot2 isEqualToString:[appsDict objectForKey:[[appsDict allKeys] objectAtIndex:1]]], nil);

    //清理环境
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
}

- (void)testUpdateAppToConfigWithThrows
{
    // 测试参数为nil的情况
    STAssertThrows([self->appPersistence updateAppToConfig:nil], nil);

    // 测试appId为nil的情况
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    STAssertThrows([self->appPersistence updateAppToConfig:app], nil);

    // 测试appSrcRoot为nil的情况
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    STAssertThrows([self->appPersistence updateAppToConfig:app], nil);

    // 测试没有applications elem的情况
    NSString *srcRoot = APP_ROOT_PREINSTALLED;
    [appInfo setSrcRoot:srcRoot];
    STAssertThrows([self->appPersistence updateAppToConfig:app], nil);

    // 测试没有找到待更新app的情况
    // 数据准备
    STAssertNoThrow([self->appPersistence addAppToConfig:app], nil);

    // 执行测试
    XAppInfo *appInfo2 = [[XAppInfo alloc] init];
    [appInfo2 setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID];
    NSString *srcRoot2 = APP_ROOT_WORKSPACE;
    [appInfo2 setSrcRoot:srcRoot2];
    id<XApplication> app2 = [XApplicationFactory create:appInfo2];
    STAssertThrows([self->appPersistence updateAppToConfig:app2], nil);
}

- (void)testUpdateAppToConfig
{
    // 测试前检查
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 数据准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    NSString *srcRoot = APP_ROOT_PREINSTALLED;
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];

    // 执行测试
    STAssertNoThrow([self->appPersistence addAppToConfig:app], nil);

    // 测试后检查
    NSMutableDictionary *appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((1 == [appsDict count]), nil);
    STAssertTrueNoThrow([[[appsDict allKeys] objectAtIndex:0] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
    STAssertTrue([srcRoot isEqualToString:[appsDict objectForKey:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID]], nil);

    // 数据准备
    NSString *srcRoot2 = APP_ROOT_WORKSPACE;
    [appInfo setSrcRoot:srcRoot2];
    [app setAppInfo:appInfo];

    // 执行测试
    STAssertNoThrow([self->appPersistence updateAppToConfig:app], nil);

    // 测试后检查
    appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((1 == [appsDict count]), nil);
    STAssertTrueNoThrow([[[appsDict allKeys] objectAtIndex:0] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
    STAssertTrue([srcRoot2 isEqualToString:[appsDict objectForKey:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID]], nil);

    //清理环境
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
}

- (void)testRemoveAppFromConfig
{
    // 测试elem不存在的情况
    STAssertNil([self->appPersistence getAppsDict], nil);
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 测试elem存在的情况
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID];
    NSString *srcRoot = APP_ROOT_PREINSTALLED;
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];

    // 执行测试
    STAssertNoThrow([self->appPersistence addAppToConfig:app], nil);

    // 测试前检查
    NSMutableDictionary *appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((1 == [appsDict count]), nil);
    STAssertTrueNoThrow([[appsDict allKeys] containsObject:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
    STAssertTrue([srcRoot isEqualToString:[appsDict objectForKey:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID]], nil);

    // 执行测试
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);

    // 测试后检查
    STAssertNil([self->appPersistence getAppsDict], nil);
}

- (void)testMarkAsDefaultApp
{
    // 测试前检查
    STAssertNil([self->appPersistence getDefaultAppId], nil);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID];
    NSString *srcRoot = APP_ROOT_PREINSTALLED;
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    STAssertNoThrow([self->appPersistence addAppToConfig:app], nil);

    // 执行测试
    STAssertNoThrow([self->appPersistence markAsDefaultApp:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);

    // 测试后检查
    STAssertTrueNoThrow([[self->appPersistence getDefaultAppId] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);

    // 清理环境
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
}

- (void)testGetDefaultAppIdWithNilResult
{
    STAssertNil([self->appPersistence getDefaultAppId], nil);
}

- (void)testGetDefaultAppId
{
    // 测试前检查
    STAssertNil([self->appPersistence getDefaultAppId], nil);

    // 数据准备
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    NSString *srcRoot = APP_ROOT_WORKSPACE;
    [appInfo setSrcRoot:srcRoot];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    STAssertNoThrow([self->appPersistence addAppToConfig:app], nil);
    STAssertNoThrow([self->appPersistence markAsDefaultApp:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);

    // 执行测试
    STAssertTrueNoThrow([[self->appPersistence getDefaultAppId] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);

    // 清理环境
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
}

- (void)testGetAppIdsWithNilResult
{
    STAssertNil([self->appPersistence getAppsDict], nil);
}

- (void)testGetAppsDict
{
    // 测试前检查
    STAssertNil([self->appPersistence getAppsDict], nil);

    // 数据准备
    XAppInfo *appInfo1 = [[XAppInfo alloc] init];
    [appInfo1 setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID];
    NSString *srcRoot1 = APP_ROOT_PREINSTALLED;
    [appInfo1 setSrcRoot:srcRoot1];
    id<XApplication> app1 = [XApplicationFactory create:appInfo1];
    STAssertNoThrow([self->appPersistence addAppToConfig:app1], nil);

    // 执行测试
    NSMutableDictionary *appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((1 == [appsDict count]), nil);
    STAssertTrueNoThrow([[[appsDict allKeys] objectAtIndex:0] isEqualToString:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
    STAssertTrue([srcRoot1 isEqualToString:[appsDict objectForKey:[[appsDict allKeys] objectAtIndex:0]]], nil);

    // 添加第二项
    XAppInfo *appInfo2 = [[XAppInfo alloc] init];
    [appInfo2 setAppId:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID];
    NSString *srcRoot2 = APP_ROOT_WORKSPACE;
    [appInfo2 setSrcRoot:srcRoot2];
    id<XApplication> app2 = [XApplicationFactory create:appInfo2];
    STAssertNoThrow([self->appPersistence addAppToConfig:app2], nil);

    // 执行测试
    appsDict = [self->appPersistence getAppsDict];
    STAssertTrueNoThrow((2 == [appsDict count]), nil);
    STAssertTrueNoThrow([[appsDict allKeys] containsObject:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
    STAssertTrue([srcRoot1 isEqualToString:[appsDict objectForKey:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID]], nil);
    STAssertTrueNoThrow([[appsDict allKeys] containsObject:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
    STAssertTrue([srcRoot2 isEqualToString:[appsDict objectForKey:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID]], nil);

    // 清理环境
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_DEFAULT_APP_ID], nil);
    STAssertNoThrow([self->appPersistence removeAppFromConfig:XAPPLICATION_PERSISTENCE_LOGIC_TESTS_APP_ID], nil);
}



@end
