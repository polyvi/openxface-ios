
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
//  XLocalStorageExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XLocalStorageExt_Privates.h"
#import "XLocalStorageExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XApplication.h"
#import "XJavaScriptEvaluator.h"

@interface XLocalStorageExtApplicationTests : XApplicationTests
{
@private
    XLocalStorageExt* localstorageExt;
    NSString* aFolderPath;
    NSString* bFolderPath;
    NSString* aFilePath;
    NSString* bFilePath;
}
@end

@implementation XLocalStorageExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->localstorageExt = [[XLocalStorageExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->localstorageExt, @"Failed to create localstorage extension instance");
    //初始化文件及文件夹路径
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
    aFolderPath = [NSString stringWithFormat:@"%@%@", docsPath,@"/apath"];
    bFolderPath = [NSString stringWithFormat:@"%@%@", docsPath,@"/bpath"];
    aFilePath = [NSString stringWithFormat:@"%@%@", aFolderPath,@"/afilepath"];
    bFilePath = [NSString stringWithFormat:@"%@%@", bFolderPath,@"/bfilepath"];
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    [fileMrg createDirectoryAtPath:aFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileMrg createDirectoryAtPath:bFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileMrg createFileAtPath:aFilePath contents:nil attributes:nil];
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    //清理环境
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    [fileMrg removeItemAtPath:aFolderPath error:nil];
    [fileMrg removeItemAtPath:bFolderPath error:nil];
    [super tearDown];
}

- (void) testVerifyAndFixDatabaseLocations
{
    STAssertNoThrow([self->localstorageExt verifyAndFixDatabaseLocations], nil);
}

- (void) testCopyFrom
{
    NSString* src   = nil;
    NSString* dest  = nil;
    NSError* error  = nil;
    STAssertNoThrow([self->localstorageExt copyFrom:src to:dest error:&error],nil);
    XBackupInfo* info = [[self->localstorageExt backupInfo] objectAtIndex:0];
    STAssertNoThrow([self->localstorageExt copyFrom:info.backup to:info.original error:&error],nil);
}

- (void) testBackup
{
    STAssertNoThrow([self->localstorageExt backup:nil withDict:nil],nil);
}

- (void) testRestore
{
    STAssertNoThrow([self->localstorageExt restore:nil withDict:nil],nil);
}

- (void) testOnResignActive
{
    STAssertNoThrow([self->localstorageExt onResignActive],nil);
}

#pragma mark -
#pragma mark XBackupInfoApplicationTests

- (void) testFileIsNewerThanFile
{
    XBackupInfo* backUpInfo = [[XBackupInfo alloc] init];
    STAssertNotNil(backUpInfo, nil);
    NSString* apath = nil;
    NSString* bPath = nil;
    //异常测试
    STAssertNoThrow([backUpInfo file:apath isNewerThanFile:bPath],nil);
    STAssertNoThrow([backUpInfo file:aFilePath isNewerThanFile:bFilePath],nil);
    //预期结果比对 bfile不存在，结果应为false
    STAssertFalse([backUpInfo file:bFilePath isNewerThanFile:aFilePath], nil);
    //延迟1S创建bfile。bfile应该比较新。预期结果返回true
    NSFileManager * fileMrg = [NSFileManager defaultManager];
    [NSThread sleepForTimeInterval:1];
    [fileMrg createFileAtPath:bFilePath contents:nil attributes:nil];
    STAssertTrue([backUpInfo file:bFilePath isNewerThanFile:aFilePath], nil);
}

- (void) testItemIsNewerThanItem
{
    XBackupInfo* backUpInfo = [[XBackupInfo alloc] init];
    STAssertNotNil(backUpInfo, nil);
    NSString* apath = nil;
    NSString* bPath = nil;
    //异常测试
    STAssertNoThrow([backUpInfo item:apath isNewerThanItem:bPath],nil);
    STAssertNoThrow([backUpInfo item:aFilePath isNewerThanItem:bFilePath],nil);
    STAssertNoThrow([backUpInfo item:aFolderPath isNewerThanItem:bFolderPath],nil);
    //预期结果比对 bfile不存在，结果应为false
    STAssertFalse([backUpInfo item:bFilePath isNewerThanItem:aFilePath], nil);
    STAssertFalse([backUpInfo item:bFolderPath isNewerThanItem:aFolderPath], nil);
    //延迟1S创建bfile。bfile应该比较新。预期结果返回true
    NSFileManager * fileMrg = [NSFileManager defaultManager];
    [NSThread sleepForTimeInterval:1];
    [fileMrg createFileAtPath:bFilePath contents:nil attributes:nil];
    STAssertTrue([backUpInfo item:bFilePath isNewerThanItem:aFilePath], nil);
    STAssertTrue([backUpInfo item:bFolderPath isNewerThanItem:aFolderPath], nil);
}

@end
