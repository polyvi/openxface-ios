
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
//  XZipArchiveExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XApplication.h"
#import "XRootViewController.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XZipArchiveExt.h"
#import "XZipArchiveExt_Privates.h"
#import "ZipArchive.h"
#import "XJsCallback+ExtensionResult.h"
#import "XExtensionResult.h"
#import "XConstants.h"

@interface XZipArchiveExtApplicationTests : XApplicationTests
{
@private
    XZipArchiveExt* zipExt;
    NSString* file;//单个文件的路径
    NSString* filePath;//被压缩的文件路径
    NSString* zipFilePath;//zip文件的路径
    NSString* dstFilePath;//zip 解压的文件路
    NSString* dstZipFilePath;//目标目录的zip文件路径
    NSString* dstFilesPath;//zip解压到目标路径的文件路径
}
@end

@implementation XZipArchiveExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->zipExt = [[XZipArchiveExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->zipExt, @"Failed to create battery extension instance");

    //初始化文件及文件夹路径
    NSString* workSpacePath = [[self app] getWorkspace];
    // test.file
    file = [workSpacePath stringByAppendingPathComponent:@"test.file"];
    // MyZip
    filePath = [workSpacePath stringByAppendingPathComponent:@"MyZip"];
    // MyZip.zip
    zipFilePath = [filePath stringByAppendingPathExtension:@"zip"];
    // MyZipTest
    dstFilePath = [workSpacePath stringByAppendingPathComponent:@"MyZipTest"];
    // MyZipTest/MyZip.zip
    dstZipFilePath = [[dstFilePath stringByAppendingPathComponent:@"MyZip"] stringByAppendingPathExtension:@"zip"];
    // MyZipTest/MyZip
    dstFilesPath = [dstFilePath stringByAppendingPathComponent:@"MyZip"];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    [fileMgr createFileAtPath:file contents:nil attributes:nil];
    [fileMgr createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileMgr createDirectoryAtPath:dstFilePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}

- (void) testCompress
{
    NSString *callbackId = @"Zip0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"compress"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    NSString* password = @"test";
    [arguments addObject:@"MyZip"];
    [arguments addObject:@""];
    NSMutableDictionary* options = [NSDictionary dictionaryWithObject:password forKey:@"password"];
    [arguments addObject:options];
    NSMutableDictionary *jsOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    //删掉过去的zip，防止干扰测试
    [fileMgr removeItemAtPath:zipFilePath error:nil];
    //压缩到当前目录
    STAssertNoThrow([self->zipExt zip:arguments withDict:jsOptions], nil);
    //压缩成功，检测相应的路径下zip文件存不存在
    NSNumber* status_ok = [[NSNumber alloc] initWithInt:STATUS_OK];
    if(status_ok == [[callback getXExtensionResult] status])
    {
        STAssertTrue([fileMgr fileExistsAtPath:zipFilePath], nil);
    }

    //压缩到目标目录
    [arguments replaceObjectAtIndex:1 withObject:@"MyZipTest"];
    [fileMgr removeItemAtPath:dstZipFilePath error:nil];
    STAssertNoThrow([self->zipExt zip:arguments withDict:jsOptions], nil);
    //压缩成功，检测相应的路径下zip文件存不存在
    if(status_ok == [[callback getXExtensionResult] status])
    {
        STAssertTrue([fileMgr fileExistsAtPath:dstZipFilePath], nil);
    }
}

- (void) testUnZip
{
    NSString *callbackId = @"Zip0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"compress"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    NSString* password = @"test";
    [arguments addObject:@"MyZip.zip"];
    [arguments addObject:@""];
    NSMutableDictionary* options = [NSDictionary dictionaryWithObject:password forKey:@"password"];
    [arguments addObject:options];
    NSMutableDictionary *jsOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                      [self app], APPLICATION_KEY, nil];

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    //删掉原文件
    [fileMgr removeItemAtPath:filePath error:nil];
    //解压到当前目录
    STAssertNoThrow([self->zipExt unzip:arguments withDict:jsOptions], nil);
    NSNumber* status_ok = [[NSNumber alloc] initWithInt:STATUS_OK];
    if(status_ok == [[callback getXExtensionResult] status])
    {
        STAssertTrue([fileMgr fileExistsAtPath:filePath], nil);
    }

    //解压到目标目录
    [arguments replaceObjectAtIndex:1 withObject:@"MyZipTest"];
    [fileMgr removeItemAtPath:dstFilesPath error:nil];
    STAssertNoThrow([self->zipExt unzip:arguments withDict:jsOptions], nil);
    //解压成功，检测相应的路径下解压出来的文件夹存不存住
    if(status_ok == [[callback getXExtensionResult] status])
    {
        STAssertTrue([fileMgr fileExistsAtPath:dstFilesPath], nil);
    }
}

- (void) tesCompressFile
{
    NSString* password = @"test";
    STAssertNoThrow([self->zipExt compressFile:file To:dstFilePath withPassword:password], nil);
    STAssertNoThrow([self->zipExt compressFile:file To:@"" withPassword:password], nil);
    password = @"";
    STAssertNoThrow([self->zipExt compressFile:file To:dstFilePath withPassword:password], nil);
    STAssertNoThrow([self->zipExt compressFile:file To:@"" withPassword:password], nil);
}

- (void) testCompressFolder
{
    NSString* password = @"test";
    STAssertNoThrow([self->zipExt compressFolder:filePath To:dstFilePath withPassword:password], nil);
    STAssertNoThrow([self->zipExt compressFolder:filePath To:@"" withPassword:password], nil);
    password = @"";
    STAssertNoThrow([self->zipExt compressFolder:filePath To:dstFilePath withPassword:password], nil);
    STAssertNoThrow([self->zipExt compressFolder:filePath To:@"" withPassword:password], nil);
}

- (void) testUnZipFile
{
    NSString* password = @"test";
    STAssertNoThrow([self->zipExt unZipFile:zipFilePath To:dstFilePath withPassword:password], nil);
    STAssertNoThrow([self->zipExt unZipFile:zipFilePath To:@"" withPassword:password], nil);
    password = @"";
    STAssertNoThrow([self->zipExt unZipFile:zipFilePath To:dstFilePath withPassword:password], nil);
    STAssertNoThrow([self->zipExt unZipFile:zipFilePath To:@"" withPassword:password], nil);
}

- (void)addFileToZip
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    STAssertNoThrow([self->zipExt addFileToZip:dstFilePath useZipArchive:zip atPath:filePath rootPath:filePath], nil);
}

- (void) testGetRelativeFileName
{
    NSString* filename = [self->zipExt getRelativeFileName:filePath withRootFilePath:filePath];
    STAssertEqualObjects(filename, @"/MyZip", nil);
}

@end
