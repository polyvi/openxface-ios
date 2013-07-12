
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
//  XConfigurationLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XConfiguration.h"
#import "XConstants.h"
#import "XConstantsLogicTests.h"
#import "XConfiguration_Privates.h"
#import "XFileOperator.h"
#import "XFileOperatorFactory.h"
#import "XSystemWorkspaceFactory.h"
#import "XPlainFileOperator.h"

#define XCONFIGURATION_LOGIC_TESTS_SYSTEM_CONFIG_FILE_NAME  @"config.xml"

@interface XConfigurationLogicTests : SenTestCase
{
    id<XFileOperator> fileOperator;
}
@end

@implementation XConfigurationLogicTests
- (void)setUp
{
    fileOperator = [[XPlainFileOperator alloc] init];

    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    [[NSFileManager defaultManager] createDirectoryAtPath:systemWorkspace withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)tearDown
{
    [super tearDown];
    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    [[NSFileManager defaultManager] removeItemAtPath:systemWorkspace error:nil];
}

- (void)testGetSystemWorkspace
{
    NSString *systemWorkspace = [[XConfiguration getInstance] getSystemWorkspace];
    STAssertNotNil(systemWorkspace, nil);

    NSString *expect = [XSystemWorkspaceFactory create];
    STAssertEqualObjects(systemWorkspace, expect, @"workspace path is incorrect");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:systemWorkspace];

    STAssertTrue(ret, @"workspace:%@ is non-existent", systemWorkspace);
}

- (void)testGetAppInstallationDir
{
    NSString *installationPath = [[XConfiguration getInstance] getAppInstallationDir];
    STAssertNotNil(installationPath, nil);

    NSString *expect = [[XSystemWorkspaceFactory create] stringByAppendingFormat:@"%@%@", APPLICATION_INSTALLATION_FOLDER, FILE_SEPARATOR];

    STAssertEqualObjects(installationPath, expect, @"application installation path is incorrect");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:installationPath];

    STAssertTrue(ret, @"application installation path:%@ is non-existent", installationPath);
}

- (void)testGetAppIconsDir
{
    NSString *iconsPath = [[XConfiguration getInstance] getAppIconsDir];
    STAssertNotNil(iconsPath, nil);

    NSString *expect = [[XSystemWorkspaceFactory create] stringByAppendingFormat:@"%@%@", APPLICATION_ICONS_FOLDER, FILE_SEPARATOR];
    STAssertEqualObjects(iconsPath, expect, @"application icons path is incorrect");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:iconsPath];

    STAssertTrue(ret, @"application icons path:%@ is non-existent", iconsPath);
}

- (void)testGetSystemConfigFilePath
{
    NSString *configFilePath = [[XConfiguration getInstance] getSystemConfigFilePath];
    STAssertNotNil(configFilePath, nil);

    BOOL ret = [configFilePath isAbsolutePath];
    STAssertTrue(ret, nil);

    ret = [configFilePath hasSuffix:XCONFIGURATION_LOGIC_TESTS_SYSTEM_CONFIG_FILE_NAME];
    STAssertTrue(ret, nil);
    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:configFilePath], nil);
}

- (void)testLoadConfigurationWithTrueResult
{
    STAssertTrueNoThrow([[XConfiguration getInstance] loadConfiguration], nil);
}

- (void)testGetPreinstallApps
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    XConfiguration *config = [XConfiguration getInstance];
    NSString *sysConfigFilePath = [config getSystemConfigFilePath];

    BOOL ret = [fileMgr fileExistsAtPath:sysConfigFilePath];
    STAssertTrue(ret, nil);

    // 执行测试
    ret = [config loadConfiguration];
    STAssertTrue(ret, nil);

    // 测试后检查
    NSMutableArray *preinstallApps = [config preinstallApps];
    STAssertTrue((1 == [preinstallApps count]), nil);
    STAssertTrue([[preinstallApps objectAtIndex:0] isEqualToString:@"app"], nil);
}

@end
