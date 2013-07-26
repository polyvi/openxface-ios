
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
//  XFileUtilsLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplication.h"
#import "XAppInfo.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XFileUtils.h"
#import "XConfiguration.h"
#import "XApplicationFactory.h"

#define XFILE_UTILS_LOGIC_TESTS_APP_ID                  @"appId"
#define XFILE_UTILS_LOGIC_TESTS_INVALID_DERECTORY_PATH  @"fileUtils"
#define XFILE_UTILS_LOGIC_TESTS_DIR_NAME                @"dirName"
#define XFILE_UTILS_LOGIC_TESTS_FILE_NAME               @"fileName"
#define XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP          @"tempFile"

@interface XFileUtilsLogicTests : SenTestCase
@end

@implementation XFileUtilsLogicTests

- (void) testGetEntry
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XFILE_UTILS_LOGIC_TESTS_APP_ID];
    NSString *workSpace = [app getWorkspace];

    NSString *filePath = @"test.txt";
    NSString *fullPath = [XUtils resolvePath:filePath usingWorkspace:workSpace];
    BOOL isDir = NO;
    NSDictionary *entry = [XFileUtils getEntry:fullPath usingWorkspace:workSpace isDir:isDir];
    NSString *fileName = [entry valueForKey:@"name"];
    STAssertEqualObjects(filePath, fileName, nil);
    fullPath = [entry valueForKey:@"fullPath"];
    STAssertEqualObjects(@"/test.txt", fullPath, nil);
    int isFile = [[entry valueForKey:@"isFile"] intValue];
    STAssertEquals(1, isFile, nil);
    int isDirectory = [[entry valueForKey:@"isDirectory"] intValue];
    STAssertEquals(0, isDirectory, nil);
}

- (void) testCreateFileTransferError
{
    int code = 2;
    NSString *target = @"target";
    NSString *source = @"source";
    NSDictionary *result = [XFileUtils createFileTransferError:code andSource:source andTarget:target];
    STAssertEqualObjects([NSNumber numberWithInt:code], [result valueForKey:@"code"], nil);
    STAssertEqualObjects(source, [result valueForKey:@"source"], nil);
    STAssertEqualObjects(target, [result valueForKey:@"target"], nil);
}

- (void) testRemoveContentOfDirectoryWithNilPath
{
    BOOL ret = [XFileUtils removeContentOfDirectoryAtPath:nil error:nil];
    STAssertTrue(ret, nil);

    ret = [XFileUtils removeContentOfDirectoryAtPath:XFILE_UTILS_LOGIC_TESTS_INVALID_DERECTORY_PATH error:nil];
    STAssertTrue(ret, nil);
}

- (void) testRemoveContentOfDirectoryWithValidPath
{
    // 数据准备，待移除目录非空
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *dirPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_DIR_NAME];
    NSString *filePath = [dirPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];

    // 确保dirPath不存在
    [fileManager removeItemAtPath:dirPath error:nil];
    STAssertFalse([fileManager fileExistsAtPath:dirPath], nil);

    // 创建dir与file
    [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    [fileManager createFileAtPath:filePath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    STAssertTrue([fileManager fileExistsAtPath:dirPath], nil);
    STAssertTrue([fileManager fileExistsAtPath:filePath], nil);

    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:dirPath];
    STAssertTrue((0 < [[enumerator allObjects] count]), nil);

    BOOL ret = [XFileUtils removeContentOfDirectoryAtPath:dirPath error:nil];
    STAssertTrue(ret, nil);

    enumerator = [fileManager enumeratorAtPath:dirPath];
    STAssertTrue((0 == [[enumerator allObjects] count]), nil);

    // 测试后检查：目录下的内容被移除，目录本身仍然存在
    STAssertTrue([fileManager fileExistsAtPath:dirPath], nil);
    STAssertFalse([fileManager fileExistsAtPath:filePath], nil);
}

- (void) testRemoveItemAtPathWithNilPath
{
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils removeItemAtPath:nil error:&error];
    STAssertTrue(ret, nil);
}

- (void) testRemoveItemAtPathWhenItemNonexistent
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    STAssertFalse([fileMgr fileExistsAtPath:XFILE_UTILS_LOGIC_TESTS_INVALID_DERECTORY_PATH], nil);

    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils removeItemAtPath:XFILE_UTILS_LOGIC_TESTS_INVALID_DERECTORY_PATH error:&error];
    STAssertTrue(ret, nil);
}

- (void) testRemoveItemAtPathWithValidPath
{
    // 数据准备，创建文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *filePath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];

    [fileManager createFileAtPath:filePath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：文件存在
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    STAssertTrue([fileMgr fileExistsAtPath:filePath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils removeItemAtPath:filePath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：文件不存在
    STAssertFalse([fileMgr fileExistsAtPath:filePath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testMoveItemWhenPathIsNil
{
    BOOL ret = [XFileUtils moveItemAtPath:nil toPath:@"" error:nil];
    STAssertFalseNoThrow(ret, nil);

    ret = [XFileUtils moveItemAtPath:@"" toPath:nil error:nil];
    STAssertFalseNoThrow(ret, nil);
}

- (void) testMoveItemWhenSrcItemNonexistent
{
    // 数据准备，创建文件
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr createFileAtPath:dstPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：确保源目录不存在,目标目录存在
    [XFileUtils removeItemAtPath:srcPath error:nil];
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils moveItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertFalse(ret, nil);

    // 测试后检查：src依然不存在，dest目录没有改变
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);
    NSString *destContent = [[NSString alloc] initWithData:[fileMgr contentsAtPath:dstPath] encoding:NSASCIIStringEncoding];
    STAssertTrue([destContent isEqualToString:content], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testMoveItemWhenDestItemNonexistent
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertFalse([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils moveItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src不存在,dst存在
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testMoveItemWhenDestItemExists
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
    [fileMgr createFileAtPath:dstPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils moveItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src不存在,dst存在
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testMoveItemWhenDestParentDirExists
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 保证dst parent dir存在
    [fileMgr createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:nil];
    dstPath = [dstPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertFalse([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils moveItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src不存在,dst存在
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testMoveItemWhenDestParentDirInexistence
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    //保证dst parent dir不存在
    [fileMgr removeItemAtPath:dstPath error:nil];
    dstPath = [dstPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertFalse([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils moveItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src不存在,dst存在
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testCopyItemWhenPathIsNil
{
    BOOL ret = [XFileUtils copyItemAtPath:nil toPath:@"" error:nil];
    STAssertFalseNoThrow(ret, nil);

    ret = [XFileUtils copyItemAtPath:@"" toPath:nil error:nil];
    STAssertFalseNoThrow(ret, nil);
}

- (void) testCopyItemWhenSrcItemNonexistent
{
    // 数据准备，创建文件
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr createFileAtPath:dstPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：确保源目录不存在,目标目录存在
    [XFileUtils removeItemAtPath:srcPath error:nil];
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils copyItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertFalse(ret, nil);

    // 测试后检查：src依然不存在，dest目录没有改变
    STAssertFalse([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);
    NSString *destContent = [[NSString alloc] initWithData:[fileMgr contentsAtPath:dstPath] encoding:NSUTF8StringEncoding];
    STAssertTrue([destContent isEqualToString:content], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testCopyItemWhenDestItemNonexistent
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：src存在,dst不存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertFalse([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils copyItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src依然存在,dst存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);
    NSString *destContent = [[NSString alloc] initWithData:[fileMgr contentsAtPath:dstPath] encoding:NSUTF8StringEncoding];
    STAssertTrue([destContent isEqualToString:content], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testCopyItemWhenDestItemExists
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content1 = @"abcdef";
    NSString *content2 = @"jhigk";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content1 dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
    [fileMgr createFileAtPath:dstPath contents:[content2 dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils copyItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src存在,dst存在,并且内容更新
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);
    NSString *destContent = [[NSString alloc] initWithData:[fileMgr contentsAtPath:dstPath] encoding:NSUTF8StringEncoding];
    STAssertTrue([destContent isEqualToString:content1], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testCopyItemWhenDestParentDirExists
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 保证dst parent dir存在
    [fileMgr createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:nil];
    dstPath = [dstPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertFalse([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils copyItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src存在,dst存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testCopyItemWhenDestParentDirInexistence
{
    // 数据准备，创建文件
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *content = @"abcdef";
    NSString *srcPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME];
    NSString *dstPath = [tempDirectoryPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    [fileMgr createFileAtPath:srcPath contents:[content dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    //保证dst parent dir不存在
    [fileMgr removeItemAtPath:dstPath error:nil];
    dstPath = [dstPath stringByAppendingPathComponent:XFILE_UTILS_LOGIC_TESTS_FILE_NAME_TEMP];

    // 测试前检查：文件存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertFalse([fileMgr fileExistsAtPath:dstPath], nil);

    // 执行测试
    __autoreleasing NSError *error = nil;
    BOOL ret = [XFileUtils copyItemAtPath:srcPath toPath:dstPath error:&error];
    STAssertTrue(ret, nil);

    // 测试后检查：src存在,dst存在
    STAssertTrue([fileMgr fileExistsAtPath:srcPath], nil);
    STAssertTrue([fileMgr fileExistsAtPath:dstPath], nil);

    // 环境清理
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];
}

- (void) testCreateFolder
{
    //创建环境
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:@"app"];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    NSString *workSpace = [app getWorkspace];

    NSString *path = @"/testfolder/testdir/test.txt";
    NSString *fullPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    //测试
    [XFileUtils createFolder:fullPath];
    NSString* expectPath = [XUtils resolvePath:@"/testfolder/testdir" usingWorkspace:workSpace];
    STAssertTrue([fileMrg fileExistsAtPath:expectPath],nil);

    path = @"testDir/testDir1";
    fullPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    [XFileUtils createFolder:fullPath];
    STAssertTrue([fileMrg fileExistsAtPath:fullPath],nil);

    //清理环境
    [XFileUtils removeContentOfDirectoryAtPath:expectPath error:nil];
    [XFileUtils removeContentOfDirectoryAtPath:fullPath error:nil];
}

-(void)doAssertForCopyFileRecursively
{
    XConfiguration* config = [XConfiguration getInstance];
    NSString *str1 = @"abcdef";
    NSString *str2 = @"123456";

    BOOL isDir = NO;
    BOOL existed = NO;
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *destFolder1 = [[config systemWorkspace] stringByAppendingPathComponent:@"test_dest_folder1"];
    NSString *destFolder2 = [destFolder1 stringByAppendingPathComponent:@"folder2"];
    NSString *destFile1 = [destFolder1 stringByAppendingPathComponent:@"file1"];
    NSString *destFile2 = [destFolder2 stringByAppendingPathComponent:@"file2"];

    existed = [manager fileExistsAtPath:destFolder1 isDirectory:&isDir];
    STAssertTrue(existed, @"copyFileRecursively failed 1!");
    STAssertTrue(isDir, @"copyFileRecursively failed 2!");
    existed = [manager fileExistsAtPath:destFolder2 isDirectory:&isDir];
    STAssertTrue(existed, @"copyFileRecursively failed 3!");
    STAssertTrue(isDir, @"copyFileRecursively failed 4!");
    existed = [manager fileExistsAtPath:destFile1 isDirectory:&isDir];
    STAssertTrue(existed, @"copyFileRecursively failed 5!");
    STAssertFalse(isDir, @"copyFileRecursively failed 6!");
    NSString *real = [NSString stringWithContentsOfFile:destFile1 encoding:NSASCIIStringEncoding error:nil];
    STAssertEqualObjects(str1, real, @"copyFileRecursively failed 7!");
    real = [NSString stringWithContentsOfFile:destFile2 encoding:NSASCIIStringEncoding error:nil];
    STAssertEqualObjects(str2, real, @"copyFileRecursively failed 8!");
    existed = [manager fileExistsAtPath:destFile2 isDirectory:&isDir];
    STAssertTrue(existed, @"copyFileRecursively failed 9!");
    STAssertFalse(isDir, @"copyFileRecursively failed 10!");
}

- (void)testCopyFileRecursively
{
    XConfiguration* config = [XConfiguration getInstance];
    NSString *str1 = @"abcdef";
    NSString *str2 = @"123456";
    NSString *srcFolder1 = [[config systemWorkspace] stringByAppendingPathComponent:@"test_src_folder1"];
    NSString *srcFolder2 = [srcFolder1 stringByAppendingPathComponent:@"folder2"];
    NSString *srcFile1 = [srcFolder1 stringByAppendingPathComponent:@"file1"];
    NSString *srcFile2 = [srcFolder2 stringByAppendingPathComponent:@"file2"];

    NSString *destFolder1 = [[config systemWorkspace] stringByAppendingPathComponent:@"test_dest_folder1"];
    NSString *destFolder2 = [destFolder1 stringByAppendingPathComponent:@"folder2"];
    NSString *destFile1 = [destFolder1 stringByAppendingPathComponent:@"file1"];
    NSString *destFile2 = [destFolder2 stringByAppendingPathComponent:@"file2"];

    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:destFolder1 error:nil];
    __autoreleasing NSError *error = nil;
    [manager createDirectoryAtPath:srcFolder2 withIntermediateDirectories:YES attributes:nil error:&error];
    [manager createFileAtPath:srcFile1 contents:[str1 dataUsingEncoding:NSASCIIStringEncoding ] attributes:nil];
    [manager createFileAtPath:srcFile2 contents:[str2 dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];

    // 测试目标目录和文件均不存在的情况
    [XFileUtils copyFileRecursively:srcFolder1 toPath:destFolder1];
    [self doAssertForCopyFileRecursively];
    [manager removeItemAtPath:destFolder1 error:nil];

    // 测试目标目录存在的情况
    [manager createDirectoryAtPath:destFolder2 withIntermediateDirectories:YES attributes:nil error:nil];
    [XFileUtils copyFileRecursively:srcFolder1 toPath:destFolder1];
    [self doAssertForCopyFileRecursively];
    [manager removeItemAtPath:destFolder1 error:nil];

    // 测试目标目录和文件均存在的情况
    [manager createDirectoryAtPath:destFolder2 withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *testStr = @"feiwgieiigri";
    [manager createFileAtPath:destFile1 contents:[testStr dataUsingEncoding:NSASCIIStringEncoding ] attributes:nil];
    [manager createFileAtPath:destFile2 contents:[testStr dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
    [XFileUtils copyFileRecursively:srcFolder1 toPath:destFolder1];
    [self doAssertForCopyFileRecursively];
    [manager removeItemAtPath:destFolder1 error:nil];

    //测试目标目录存在其它文件的情况
    NSString *otherFilePath = [destFolder2 stringByAppendingPathComponent:@"other_file1"];
    NSString *otherFileContent = @"other content....";
    [manager createDirectoryAtPath:destFolder2 withIntermediateDirectories:YES attributes:nil error:nil];
    [manager createFileAtPath:otherFilePath contents:[otherFileContent dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
    [XFileUtils copyFileRecursively:srcFolder1 toPath:destFolder1];
    [self doAssertForCopyFileRecursively];
    STAssertTrue([manager fileExistsAtPath:otherFilePath], @"copyFileRecursively failed 12!");
    NSString *real = [NSString stringWithContentsOfFile:otherFilePath encoding:NSASCIIStringEncoding error:nil];
    STAssertEqualObjects(real, otherFileContent, @"copyFileRecursively failed 13!");
    [manager removeItemAtPath:destFolder1 error:nil];
}

- (void)testCreateTemporaryDirectoryWithNilParent
{
    NSString *tmpDir = [XFileUtils createTemporaryDirectory:nil];
    STAssertNotNil(tmpDir, nil);
    STAssertTrue([tmpDir hasPrefix:NSTemporaryDirectory()], nil);
    STAssertTrue([tmpDir hasSuffix:@"tmp"], nil);

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    STAssertTrue([fileMgr fileExistsAtPath:tmpDir], nil);

    // 清理环境
    STAssertTrue([XFileUtils removeItemAtPath:tmpDir error:nil], nil);
}

- (void)testCreateTemporaryDirectoryWithNotNilParent
{
    NSString *parent = [[XConfiguration getInstance] appInstallationDir];
    NSString *tmpDir = [XFileUtils createTemporaryDirectory:parent];

    STAssertNotNil(tmpDir, nil);
    STAssertTrue([tmpDir hasPrefix:parent], nil);
    STAssertTrue([tmpDir hasSuffix:@"tmp"], nil);

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    STAssertTrue([fileMgr fileExistsAtPath:tmpDir], nil);

    // 清理环境
    STAssertTrue([XFileUtils removeItemAtPath:tmpDir error:nil], nil);
}

@end
