
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
//  XAmsLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAms.h"
#import "XAmsImpl.h"
#import "XLogicTests.h"
#import "XAppManagement.h"
#import "XAppInfo.h"
#import "XAppList.h"
#import "XConfiguration.h"
#import "XFileUtils.h"
#import "XConstants.h"
#import "XApplicationFactory.h"
#import "XApplication.h"

@interface XAmsLogicTests : XLogicTests
{
    XAmsImpl *ams;
    XAppManagement *appManagement;
    NSString *defaultAppWorkspace;
    NSString *presetAppDirPath;
}

@end

@implementation XAmsLogicTests

- (void)setUp
{
    [super setUp];

    self->appManagement = [[XAppManagement alloc] initWithAmsDelegate:nil];
    self->ams = [[XAmsImpl alloc] init:self->appManagement];

    XAppList *appList = [self->appManagement appList];
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:@"app"];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];
    [appList markAsDefaultApp:@"app"];

    id<XApplication> defaultApp = [[self->appManagement appList] getDefaultApp];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    self->defaultAppWorkspace = [defaultApp getWorkspace];
    [fileManager removeItemAtPath:self->defaultAppWorkspace error:nil];

    self->presetAppDirPath = [self->defaultAppWorkspace stringByAppendingPathComponent:PRE_SET_DIR_NAME];
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self->defaultAppWorkspace error:nil];
    [super tearDown];
}

- (void)testGetPresetAppPackagesWithNilResult
{
    // pre_set目录不存在的情况
    NSMutableArray *packages = [self->ams getPresetAppPackages];
    STAssertNil(packages, nil);

    // pre_set目录为空的情况
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:self->presetAppDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:self->presetAppDirPath], nil);

    packages = [self->ams getPresetAppPackages];
    STAssertNil(packages, nil);
}

- (void)testGetPresetAppPackages
{
    // 数据准备：添加预置应用包
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:self->presetAppDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:self->presetAppDirPath], nil);
    STAssertTrue((0 == [[fileManager contentsOfDirectoryAtPath:self->presetAppDirPath error:nil] count]), nil);

    // 添加xpa应用包
    NSString *packageXpa = @"app.xpa";
    NSData *xpaData = [@"app package content xpa" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->presetAppDirPath stringByAppendingPathComponent:packageXpa] contents:xpaData attributes:nil];

    // 获取到xpa包
    NSMutableArray *appPackages = [self->ams getPresetAppPackages];
    STAssertTrue((1 == [appPackages count]), nil);
    STAssertTrue([packageXpa isEqualToString:appPackages[0]], nil);

    // 添加zip数据包
    NSString *packageZip = @"app.zip";
    NSData *zipData = [@"app package content zip" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->presetAppDirPath stringByAppendingPathComponent:packageZip] contents:zipData attributes:nil];

    // 获取到zip包
    appPackages = [self->ams getPresetAppPackages];
    STAssertTrue((2 == [appPackages count]), nil);
    STAssertTrue([appPackages containsObject:packageXpa], nil);
    STAssertTrue([appPackages containsObject:packageZip], nil);

    // 添加unknown数据包
    NSString *packageUnknown = @"app.unknown";
    NSData *unknownData = [@"app package content unknown" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->presetAppDirPath stringByAppendingPathComponent:packageUnknown] contents:unknownData attributes:nil];

    // 没有获取到unknown数据包
    appPackages = [self->ams getPresetAppPackages];
    STAssertTrue((2 == [appPackages count]), nil);
    STAssertTrue([appPackages containsObject:packageXpa], nil);
    STAssertTrue([appPackages containsObject:packageZip], nil);

    // 添加npa应用包
    NSString *packageNpa = @"app.npa";
    NSData *npaData = [@"app package content npa" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->presetAppDirPath stringByAppendingPathComponent:packageNpa] contents:npaData attributes:nil];

    // 获取到npa包
    appPackages = [self->ams getPresetAppPackages];
    STAssertTrue((3 == [appPackages count]), nil);
    STAssertTrue([appPackages containsObject:packageXpa], nil);
    STAssertTrue([appPackages containsObject:packageNpa], nil);
    STAssertTrue([appPackages containsObject:packageZip], nil);
}

@end
