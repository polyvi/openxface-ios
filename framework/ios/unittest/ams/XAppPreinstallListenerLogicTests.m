
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
//  XAppPreinstallListenerLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppPreinstallListener.h"
#import "XAppManagement.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XAppPreinstallListener_Private.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XLogicTests.h"
#import "XApplicationFactory.h"
#import "XFileUtils.h"

@interface XAppPreinstallListenerLogicTests : XLogicTests
{
    XAppPreinstallListener *listener;
    XAppManagement *appManagement;
    NSString *defaultAppWorkspace;
    NSString *srcPresetDirPath;
    NSString *destPresetAppDirPath;
    NSString *srcEncryptCodeDirPath;
    NSString *destEncryptCodePkgPath;
}

@end

@implementation XAppPreinstallListenerLogicTests

- (void)setUp
{
    [super setUp];

    appManagement = [[XAppManagement alloc] initWithAmsDelegate:nil];
    XAppList *appList = [appManagement appList];
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:@"app"];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [appList add:app];
    [appList markAsDefaultApp:@"app"];
    listener = [[XAppPreinstallListener alloc] init:appManagement];
    XConfiguration *config = [XConfiguration getInstance];
    id<XApplication> defaultApp = [[self->appManagement appList] getDefaultApp];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    self->defaultAppWorkspace = [defaultApp getWorkspace];
    [fileManager removeItemAtPath:self->defaultAppWorkspace error:nil];

    self->srcPresetDirPath =  [[config systemWorkspace] stringByAppendingPathComponent:PRE_SET_DIR_NAME];
    if(![fileManager fileExistsAtPath:self->srcPresetDirPath])
    {
        [fileManager createDirectoryAtPath:self->srcPresetDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    self->destPresetAppDirPath = [self->defaultAppWorkspace stringByAppendingPathComponent:PRE_SET_DIR_NAME];

    self->srcEncryptCodeDirPath = [[config systemWorkspace] stringByAppendingPathComponent:ENCRYPT_CODE_DIR_NAME];
    self->destEncryptCodePkgPath = [[defaultApp installedDirectory] stringByAppendingPathComponent:ENCRYPE_CODE_PACKAGE_NAME];
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self->srcPresetDirPath error:nil];
    [fileManager removeItemAtPath:self->defaultAppWorkspace error:nil];
    [fileManager removeItemAtPath:self->srcEncryptCodeDirPath error:nil];
    [fileManager removeItemAtPath:self->destEncryptCodePkgPath error:nil];
    [super tearDown];
}

- (void)testInit
{
    XAppPreinstallListener *appPreinstallListener = [[XAppPreinstallListener alloc] init:self->appManagement];
    STAssertNotNil(appPreinstallListener, nil);
}

- (void)testOnProgressUpdated
{
    STAssertNoThrow([self->listener onProgressUpdated:INSTALL withStatus:FINISHED], nil);
}

- (void)testOnSuccess
{
    STAssertNoThrow([self->listener onSuccess:INSTALL withAppId:nil], nil);
    STAssertNoThrow([self->listener onSuccess:INSTALL withAppId:@"app"], nil);
}

- (void)testOnError
{
    STAssertNoThrow([self->listener onError:INSTALL withAppId:nil withError:IO_ERROR], nil);
}

- (void)testHandlePresetPackages
{
    // 源pre_set目录不存在
    STAssertNoThrow([listener handlePresetPackages], nil);

    // 源pre_set目录存在，源应用包不存在
    STAssertNoThrow([listener handlePresetPackages], nil);

    // 源应用包存在，目标应用包不存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *packageName = @"app1.xpa";
    NSData *data = [@"package content" dataUsingEncoding:kCFStringEncodingUTF8];
    if(![fileManager fileExistsAtPath:srcPresetDirPath])
    {
        [fileManager createDirectoryAtPath:srcPresetDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[srcPresetDirPath stringByAppendingPathComponent:packageName] contents:data attributes:nil];
    }
    [listener handlePresetPackages];

    NSString *path = [[self->defaultAppWorkspace stringByAppendingPathComponent:PRE_SET_DIR_NAME] stringByAppendingPathComponent:packageName];
    STAssertTrue([fileManager fileExistsAtPath:path], nil);
    STAssertEqualObjects(data, [NSData dataWithContentsOfFile:path], nil);

    // 源应用包存在，目标应用包存在
    NSData *data2 = [@"some other content" dataUsingEncoding:kCFStringEncodingUTF8];
    if([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:nil];
    }
    [fileManager createFileAtPath:path contents:data2 attributes:nil];
    if(![fileManager fileExistsAtPath:srcPresetDirPath])
    {
        [fileManager createDirectoryAtPath:srcPresetDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[srcPresetDirPath stringByAppendingPathComponent:packageName] contents:data attributes:nil];
    }
    [listener handlePresetPackages];
    STAssertTrue([fileManager fileExistsAtPath:path], nil);
    STAssertEqualObjects(data, [NSData dataWithContentsOfFile:path], nil);

    //清理环境
    [XFileUtils removeContentOfDirectoryAtPath:self->destPresetAppDirPath error:nil];
}

- (void)testGetPresetPackagesWithNilResult
{
    // 传入nil
    STAssertNil([self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:nil], nil);

    // 传入不存在的目录
    NSString *path = [self->srcPresetDirPath stringByAppendingPathComponent:@"emptyDir"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    STAssertNil([self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:path], nil);
}

- (void)testGetPresetPackagesWithEmptyArray
{
    // 传入没有内容的目录
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    STAssertTrue((0 == [[fileMgr contentsOfDirectoryAtPath:self->srcPresetDirPath error:nil] count]), nil);
    NSArray *packages = [self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((0 == [packages count]), nil);

    packages = [self->listener getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((0 == [packages count]), nil);
}

- (void)testGetPresetPackages
{
    // 数据准备：添加预置应用包
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertTrue((0 == [[fileManager contentsOfDirectoryAtPath:self->srcPresetDirPath error:nil] count]), nil);


    // 添加xpa应用包
    NSString *packageXpa = @"app.xpa";
    NSData *xpaData = [@"app package content xpa" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcPresetDirPath stringByAppendingPathComponent:packageXpa] contents:xpaData attributes:nil];

    NSArray *appPackages = [self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((1 == [appPackages count]), nil);
    STAssertTrue([packageXpa isEqualToString:appPackages[0]], nil);

    NSArray *dataPackages = [self->listener getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((0 == [dataPackages count]), nil);

    dataPackages = [self->listener getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((0 == [dataPackages count]), nil);

    // 添加zip数据包
    NSString *packageZip = @"app.zip";
    NSData *zipData = [@"app package content zip" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcPresetDirPath stringByAppendingPathComponent:packageZip] contents:zipData attributes:nil];

    appPackages = [self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((1 == [appPackages count]), nil);
    STAssertTrue([appPackages containsObject:packageXpa], nil);

    dataPackages = [self->listener getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((1 == [dataPackages count]), nil);
    STAssertTrue([dataPackages containsObject:packageZip], nil);

    // 添加unknown数据包
    NSString *packageUnknown = @"app.unknown";
    NSData *unknownData = [@"app package content unknown" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcPresetDirPath stringByAppendingPathComponent:packageUnknown] contents:unknownData attributes:nil];

    appPackages = [self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((1 == [appPackages count]), nil);
    STAssertTrue([appPackages containsObject:packageXpa], nil);

    dataPackages = [self->listener getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((2 == [dataPackages count]), nil);
    STAssertTrue([dataPackages containsObject:packageZip], nil);
    STAssertTrue([dataPackages containsObject:packageUnknown], nil);

    // 添加npa应用包
    NSString *packageNpa = @"app.npa";
    NSData *npaData = [@"app package content npa" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcPresetDirPath stringByAppendingPathComponent:packageNpa] contents:npaData attributes:nil];

    appPackages = [self->listener getPresetPackagesOfType:PRESET_APP_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((2 == [appPackages count]), nil);
    STAssertTrue([appPackages containsObject:packageXpa], nil);
    STAssertTrue([appPackages containsObject:packageNpa], nil);

    dataPackages = [self->listener getPresetPackagesOfType:PRESET_DATA_PACKAGE atPath:self->srcPresetDirPath];
    STAssertTrue((2 == [dataPackages count]), nil);
    STAssertTrue([dataPackages containsObject:packageZip], nil);
    STAssertTrue([dataPackages containsObject:packageUnknown], nil);
}

- (void)testMovePresetAppPackagesWhenNoPackages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:self->destPresetAppDirPath], nil);

    STAssertNoThrow([self->listener movePresetAppPackages], nil);

    STAssertFalse([fileManager fileExistsAtPath:self->destPresetAppDirPath], nil);
}

- (void)testMovePresetAppPackages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:self->destPresetAppDirPath], nil);

    //数据准备：添加预置应用包
    NSString *packageXpa = @"app.xpa";
    NSData *xspaData = [@"app package content xpa" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcPresetDirPath stringByAppendingPathComponent:packageXpa] contents:xspaData attributes:nil];

    //执行测试
    STAssertNoThrow([self->listener movePresetAppPackages], nil);

    //测试后检查
    STAssertTrue([fileManager fileExistsAtPath:self->destPresetAppDirPath], nil);
    STAssertTrue((1 == [[fileManager contentsOfDirectoryAtPath:self->destPresetAppDirPath error:nil] count]), nil);
    STAssertTrue(([[fileManager contentsOfDirectoryAtPath:self->destPresetAppDirPath error:nil] containsObject:packageXpa]), nil);
}

- (void)testMovePresetDataPackagesWhenNoPackages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:self->defaultAppWorkspace], nil);

    STAssertNoThrow([self->listener movePresetDataPackages], nil);

    STAssertTrue([fileManager fileExistsAtPath:self->defaultAppWorkspace], nil);
    STAssertTrue((0 == [[fileManager contentsOfDirectoryAtPath:self->defaultAppWorkspace error:nil] count]), nil);
}

- (void)testMovePresetDataPackages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:self->defaultAppWorkspace], nil);

    //数据准备：添加预置数据包
    NSString *packageZip = @"app.zip";
    NSData *zipData = [@"app package content zip" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcPresetDirPath stringByAppendingPathComponent:packageZip] contents:zipData attributes:nil];

    //执行测试
    STAssertNoThrow([self->listener movePresetDataPackages], nil);

    //测试后检查
    STAssertTrue([fileManager fileExistsAtPath:self->defaultAppWorkspace], nil);
    STAssertTrue((1 == [[fileManager contentsOfDirectoryAtPath:self->defaultAppWorkspace error:nil] count]), nil);
    STAssertTrue(([[fileManager contentsOfDirectoryAtPath:self->defaultAppWorkspace error:nil] containsObject:packageZip]), nil);
}

- (void)testMovePackages
{
    STAssertNoThrow([self->listener movePackages:nil atPath:nil toPath:nil], nil);
}

- (void)testHandleEncryptCodePackagesWithNonExistentDirectory
{
    // 源encrypt_code目录不存在
    STAssertNoThrow([listener handleEncryptCodePackages], nil);
}

- (void)testHandleEncryptCodePackagesWithNonExistentPackage
{
    // 源encrypt_code目录为空目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalse([fileManager fileExistsAtPath:self->srcEncryptCodeDirPath], nil);
    [fileManager createDirectoryAtPath:self->srcEncryptCodeDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    STAssertTrue([fileManager fileExistsAtPath:self->srcEncryptCodeDirPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:self->destEncryptCodePkgPath], nil);

    STAssertNoThrow([listener handleEncryptCodePackages], nil);

    STAssertFalse([fileManager fileExistsAtPath:self->destEncryptCodePkgPath], nil);
}

- (void)testHandleEncryptCodePackages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:self->srcEncryptCodeDirPath withIntermediateDirectories:YES attributes:nil error:nil];

    //数据准备：添加jscore.zip
    NSData *zipData = [@"encrypt code jscore zip" dataUsingEncoding:kCFStringEncodingUTF8];
    [fileManager createFileAtPath:[self->srcEncryptCodeDirPath stringByAppendingPathComponent:ENCRYPE_CODE_PACKAGE_NAME] contents:zipData attributes:nil];

    STAssertFalse([fileManager fileExistsAtPath:self->destEncryptCodePkgPath], nil);

    //执行测试
    STAssertNoThrow([self->listener handleEncryptCodePackages], nil);

    //测试后检查
    STAssertTrue([fileManager fileExistsAtPath:self->destEncryptCodePkgPath], nil);
    NSData *destData = [fileManager contentsAtPath:self->destEncryptCodePkgPath];
    STAssertEqualObjects(destData, zipData, nil);
}

@end
