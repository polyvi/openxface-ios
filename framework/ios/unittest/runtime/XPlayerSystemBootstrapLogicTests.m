
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
//  XPlayerSystemBootstrapLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#include "XPlayerSystemBootstrap.h"
#include "XPlayerSystemBootstrap_Privates.h"
#include "XConfiguration.h"
#include "XConstants.h"
#include "XFileUtils.h"

#define XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME                 @"app.zip"
#define XPLAYER_LOGIC_TESTS_APP_UPDATE_PACKAGE_FILE_NAME          @"updateApp.zip"
#define XPLAYER_LOGIC_TESTS_APP_PACKAGE_FOLDER                    @"www"

@interface XPlayerSystemBootstrapLogicTests : SenTestCase
{
@private
    XPlayerSystemBootstrap *playerSystemBootstrap;
}
@end

@implementation XPlayerSystemBootstrapLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->playerSystemBootstrap = [[XPlayerSystemBootstrap alloc] init];
    [self->playerSystemBootstrap setBootDelegate:nil];
    STAssertNotNil(self->playerSystemBootstrap, @"Failed to create XPlayerSystemBootstrap instance");
}

- (void)tearDown
{
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:[[XConfiguration getInstance] systemWorkspace] error:nil];
}

- (void)testPrepareForMergingUserDataWhenNeedingMergingIsFalse
{
    BOOL ret = NO;
    BOOL needMerging = NO;
    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:destPath error:nil];

    STAssertNoThrow((ret = [self->playerSystemBootstrap prepareForMergingUserData:&needMerging]), nil);
    STAssertTrue(ret, nil);
    STAssertFalse(needMerging, nil);
}

- (void)testPrepareForMergingUserDataWhenNeedingMergingIsTrue
{
    BOOL ret = NO;
    BOOL needMerging = NO;

    //数据准备
    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    NSString *workspacePath = [destPath stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:workspacePath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:workspacePath], nil);

    STAssertNoThrow((ret = [self->playerSystemBootstrap prepareForMergingUserData:&needMerging]), nil);
    STAssertTrue(ret, nil);
    STAssertTrue(needMerging, nil);

    //环境清理
    NSString *tempDir = [[config appInstallationDir] stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    [fileManager removeItemAtPath:tempDir error:nil];
    [fileManager removeItemAtPath:destPath error:nil];
}

- (void)testPrepareForMergingUserDataWhenTestUserDataDirExists
{
    BOOL ret = NO;
    BOOL needMerging = NO;

    //数据准备
    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    NSString *workspacePath = [destPath stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:workspacePath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:workspacePath], nil);

    NSString *tempUserDataDir = [[config appInstallationDir] stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    [fileManager createDirectoryAtPath:tempUserDataDir withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:tempUserDataDir], nil);

    STAssertNoThrow((ret = [self->playerSystemBootstrap prepareForMergingUserData:&needMerging]), nil);
    STAssertTrue(ret, nil);
    STAssertTrue(needMerging, nil);

    //环境清理
    NSString *tempDir = [[config appInstallationDir] stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    [fileManager removeItemAtPath:tempDir error:nil];
    [fileManager removeItemAtPath:destPath error:nil];
}

- (void)testMergeUserDataWhenSrcUserDataInexistence
{
    BOOL ret = NO;
    BOOL needMerging = NO;

    //数据准备
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [NSString stringWithFormat:@"%@%@%@%@%@", APPLICATION_PREPACKED_PACKAGE_FOLDER, FILE_SEPARATOR, XFACE_WORKSPACE_NAME_UNDER_APP, FILE_SEPARATOR, APPLICATION_INSTALLATION_FOLDER];
    NSString *srcPath = [bundle pathForResource:DEFAULT_APP_ID_FOR_PLAYER ofType:nil inDirectory:bundlePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertTrue([fileManager fileExistsAtPath:srcPath], nil);

    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    [fileManager removeItemAtPath:destPath error:nil];

    NSString *dataPath = [destPath stringByAppendingPathComponent:APP_DATA_DIR_FOLDER];
    [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:dataPath], nil);

    NSString *srcWorkspace = [srcPath stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    STAssertTrue([fileManager fileExistsAtPath:srcWorkspace], nil);

    NSString *appZipPath = [srcWorkspace stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME];
    NSString *destAppZipPath = [dataPath stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME];
    STAssertTrue(([appZipPath length] > 0), nil);
    STAssertTrue([fileManager copyItemAtPath:appZipPath toPath:destAppZipPath error:nil], nil);
    STAssertTrue([fileManager fileExistsAtPath:destAppZipPath], nil);

    NSString *tempDir = [[config appInstallationDir] stringByAppendingPathComponent:APP_DATA_DIR_FOLDER];
    [fileManager removeItemAtPath:tempDir error:nil];
    STAssertFalse([fileManager fileExistsAtPath:tempDir], nil);

    //执行测试
    STAssertNoThrow((ret = [self->playerSystemBootstrap prepareForMergingUserData:&needMerging]), nil);
    STAssertTrue(ret, nil);
    STAssertTrue(needMerging, nil);
    STAssertFalse([fileManager fileExistsAtPath:destPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:tempDir], nil);
    STAssertTrue([fileManager fileExistsAtPath:[tempDir stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME]], nil);

    //src data dir不存在
    STAssertNoThrow((ret = [self->playerSystemBootstrap mergeUserDataAtPath:srcPath toPath:destPath]), nil);

    //测试后检查
    STAssertTrue(ret, nil);
    STAssertFalse([fileManager fileExistsAtPath:tempDir], nil);
    STAssertTrue([fileManager fileExistsAtPath:destPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:destAppZipPath], nil);

    //环境清理
    [fileManager removeItemAtPath:destPath error:nil];
}

- (void)testMergeUserDataWhenDstUserDataInexistence
{
    BOOL ret = NO;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSString *bundlePath = [NSString stringWithFormat:@"%@%@%@%@%@", APPLICATION_PREPACKED_PACKAGE_FOLDER, FILE_SEPARATOR, XFACE_WORKSPACE_NAME_UNDER_APP, FILE_SEPARATOR, APPLICATION_INSTALLATION_FOLDER];
    NSString *srcPath = [bundle pathForResource:DEFAULT_APP_ID_FOR_PLAYER ofType:nil inDirectory:bundlePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:srcPath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:srcPath], nil);

    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    [fileManager removeItemAtPath:destPath error:nil];

    NSString *userDataDir = [[config appInstallationDir] stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    STAssertFalse([fileManager fileExistsAtPath:userDataDir], nil);

    STAssertNoThrow((ret = [self->playerSystemBootstrap mergeUserDataAtPath:srcPath toPath:destPath]), nil);
    STAssertTrue(ret, nil);

    NSString *workspacePath = [destPath stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    STAssertFalse([fileManager fileExistsAtPath:workspacePath], nil);
}

- (void)testMergeUserData
{
    BOOL ret = NO;
    BOOL needMerging = NO;

    //数据准备
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [NSString stringWithFormat:@"%@%@%@%@%@", APPLICATION_PREPACKED_PACKAGE_FOLDER, FILE_SEPARATOR, XFACE_WORKSPACE_NAME_UNDER_APP, FILE_SEPARATOR, APPLICATION_INSTALLATION_FOLDER];
    NSString *srcPath = [bundle pathForResource:DEFAULT_APP_ID_FOR_PLAYER ofType:nil inDirectory:bundlePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertTrue([fileManager fileExistsAtPath:srcPath], nil);

    XConfiguration *config = [XConfiguration getInstance];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    [fileManager removeItemAtPath:destPath error:nil];

    NSString *workspacePath = [destPath stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    [fileManager createDirectoryAtPath:workspacePath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:workspacePath], nil);

    NSString *srcWorkspace = [srcPath stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    STAssertTrue([fileManager fileExistsAtPath:srcWorkspace], nil);

    NSString *appZipPath = [srcWorkspace stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME];
    NSString *destAppZipPath = [workspacePath stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME];
    STAssertTrue(([appZipPath length] > 0), nil);
    STAssertTrue([fileManager copyItemAtPath:appZipPath toPath:destAppZipPath error:nil], nil);

    NSString *destUpdateAppZipPath = [workspacePath stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_UPDATE_PACKAGE_FILE_NAME];

    STAssertTrue([fileManager fileExistsAtPath:destAppZipPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:destUpdateAppZipPath], nil);

    NSString *tempDir = [[config appInstallationDir] stringByAppendingPathComponent:APP_WORKSPACE_FOLDER];
    [fileManager removeItemAtPath:tempDir error:nil];
    STAssertFalse([fileManager fileExistsAtPath:tempDir], nil);

    //执行测试
    STAssertNoThrow((ret = [self->playerSystemBootstrap prepareForMergingUserData:&needMerging]), nil);
    STAssertTrue(ret, nil);
    STAssertTrue(needMerging, nil);
    STAssertFalse([fileManager fileExistsAtPath:destPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:tempDir], nil);
    STAssertTrue([fileManager fileExistsAtPath:[tempDir stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME]], nil);
    STAssertFalse([fileManager fileExistsAtPath:[tempDir stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_UPDATE_PACKAGE_FILE_NAME]], nil);

    STAssertNoThrow((ret = [XFileUtils copyFileRecursively:srcPath toPath:destPath]), nil);
    STAssertTrue(ret, nil);
    STAssertTrue([fileManager fileExistsAtPath:destAppZipPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:destUpdateAppZipPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:tempDir], nil);
    STAssertTrue([fileManager fileExistsAtPath:[tempDir stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_PACKAGE_FILE_NAME]], nil);
    STAssertFalse([fileManager fileExistsAtPath:[tempDir stringByAppendingPathComponent:XPLAYER_LOGIC_TESTS_APP_UPDATE_PACKAGE_FILE_NAME]], nil);

    STAssertNoThrow((ret = [self->playerSystemBootstrap mergeUserDataAtPath:srcPath toPath:destPath]), nil);

    //测试后检查
    STAssertTrue(ret, nil);
    STAssertFalse([fileManager fileExistsAtPath:tempDir], nil);
    STAssertTrue([fileManager fileExistsAtPath:destPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:destAppZipPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:destUpdateAppZipPath], nil);

    //环境清理
    [fileManager removeItemAtPath:destPath error:nil];
}

@end
