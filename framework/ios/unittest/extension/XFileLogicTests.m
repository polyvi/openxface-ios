
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
//  XFileLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XFile.h"
#import "XConfiguration.h"
#import "XAppInfo.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XAppView.h"
#import "XContact.h"
#import "XBase64Data.h"
#import "XApplicationFactory.h"

#define XAPPLICATION_LOGIC_TESTS_APP_ID                @"appId"

@interface XFileLogicTests : SenTestCase

@end

@implementation XFileLogicTests

- (void)testInit
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);
}

- (void)testRequestFileSystem
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];

    XFileError error = NO_ERROR;
    NSMutableDictionary *ret = [file requestFileSystem:100 type:TEMPORARY usingWorkspace:workSpace error:&error];
    STAssertNotNil(ret, nil);
    STAssertEquals(error, NO_ERROR, nil);

    STAssertEqualObjects([ret valueForKey:@"name"], @"temporary", nil);
    NSDictionary* root = [ret valueForKey:@"root"];
    BOOL isFile = [(NSNumber*)[root valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[root valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [root valueForKey:@"name"];
    NSString* fullPath = [root valueForKey:@"fullPath"];
    STAssertEquals(isFile, NO, nil);
    STAssertEquals(isDir, YES, nil);
    STAssertEqualObjects(fileName, @"/", nil);
    STAssertEqualObjects(fullPath, @"/", nil);

    NSFileManager* fMgr = [NSFileManager defaultManager];
    NSError*  __autoreleasing pError = nil;
    NSDictionary* pDict = [ fMgr attributesOfFileSystemForPath:workSpace error:&pError ];
    NSNumber* availSpace = (NSNumber*)[ pDict objectForKey:NSFileSystemFreeSize ];

    NSMutableDictionary *fs = [file requestFileSystem:([availSpace unsignedLongLongValue] + 100) type:TEMPORARY
                                       usingWorkspace:workSpace error:&error];
    STAssertEquals(QUOTA_EXCEEDED_ERR, error, nil);
    STAssertNil(fs, nil);
}

- (void)testGetFile
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    XFileError error = NO_ERROR;

    NSString* dirPath = @"test";

    NSDictionary* ret =[file getFile:workSpace dirPath:@"/" filePath:dirPath create:YES exclusive:NO isDir:YES error:&error];
    BOOL isFile = [(NSNumber*)[ret valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[ret valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [ret valueForKey:@"name"];
    NSString* fullPath = [ret valueForKey:@"fullPath"];
    STAssertEquals(NO, isFile, nil);
    STAssertEquals(YES, isDir, nil);
    STAssertEqualObjects(dirPath, fileName, nil);
    STAssertEqualObjects(@"/test", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    ret = [file getFile:workSpace dirPath:@"/" filePath:dirPath create:YES exclusive:YES isDir:YES error:&error];
    STAssertNil(ret, nil);
    STAssertEquals(PATH_EXISTS_ERR, error, nil);

    NSString* filePath = @"testFile.txt";

    ret =[file getFile:workSpace dirPath:dirPath filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    isFile = [(NSNumber*)[ret valueForKey: @"isFile"] boolValue];
    isDir = [(NSNumber*)[ret valueForKey: @"isDirectory"] boolValue];
    fileName = [ret valueForKey:@"name"];
    fullPath = [ret valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(filePath, fileName, nil);
    STAssertEqualObjects(@"/test/testFile.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    BOOL success = [file removeRecursively:workSpace filePath:dirPath error:&error];
    STAssertTrue(success, nil);
}

- (void)testWriteToFile
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* filePath = @"test.txt";
    XFileError error = NO_ERROR;

    NSDictionary* ret =[file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    BOOL isFile = [(NSNumber*)[ret valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[ret valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [ret valueForKey:@"name"];
    NSString* fullPath = [ret valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(filePath, fileName, nil);
    STAssertEqualObjects(@"/test.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    NSString* data = @"this is test data";
    int writeBytes = [file writeToFile:workSpace filePath:filePath withData:data append:YES error:&error];
    int expected = [data length];
    STAssertEquals(expected, writeBytes, nil);

    writeBytes = [file writeToFile:workSpace filePath:@"../test.txt" withData:data append:YES error:&error];
    STAssertEquals(-1, writeBytes, nil);
    STAssertEquals(INVALID_MODIFICATION_ERR, error, nil);

    BOOL success = [file removeRecursively:workSpace filePath:filePath error:&error];
    STAssertTrue(success, nil);
}

- (void)testTruncateFile
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* filePath = @"test.txt";
    XFileError error = NO_ERROR;

    NSDictionary* ret =[file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    BOOL isFile = [(NSNumber*)[ret valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[ret valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [ret valueForKey:@"name"];
    NSString* fullPath = [ret valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(filePath, fileName, nil);
    STAssertEqualObjects(@"/test.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    NSString* date = @"this is test data";
    int writeBytes = [file writeToFile:workSpace filePath:filePath withData:date append:YES error:&error];
    int expected = [date length];
    STAssertEquals(expected, writeBytes, nil);

    unsigned long long pos = 4UL;
    unsigned long long newPos = [file truncateFile:workSpace filePath:fileName atPosition:pos error:&error];
    STAssertEquals(pos, newPos, nil);
    STAssertEquals(NO_ERROR, error, nil);

    newPos = [file truncateFile:workSpace filePath:@"../test.txt" atPosition:pos error:&error];
    STAssertEquals(INVALID_MODIFICATION_ERR, error, nil);

    BOOL success = [file removeRecursively:workSpace filePath:filePath error:&error];
    STAssertTrue(success, nil);
}

- (void)testTruncateFileBeyondLength
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* filePath = @"test.txt";
    XFileError error = NO_ERROR;

    NSDictionary* ret =[file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    BOOL isFile = [(NSNumber*)[ret valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[ret valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [ret valueForKey:@"name"];
    NSString* fullPath = [ret valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(filePath, fileName, nil);
    STAssertEqualObjects(@"/test.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    NSString* data = @"this is test data";
    int writeBytes = [file writeToFile:workSpace filePath:filePath withData:data append:YES error:&error];
    int expected = [data length];
    STAssertEquals(expected, writeBytes, nil);

    unsigned long long pos = 40UL;
    unsigned long long newPos = [file truncateFile:workSpace filePath:fileName atPosition:pos error:&error];
    unsigned long long len = [data length];
    STAssertEquals(len, newPos, nil);
    STAssertEquals(NO_ERROR, error, nil);

    BOOL success = [file removeRecursively:workSpace filePath:filePath error:&error];
    STAssertTrue(success, nil);
}

- (void)testRemove
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    XFileError error = NO_ERROR;

    //删除根目录会失败
    BOOL removeSuccess = [file remove:workSpace filePath:@"/" error:&error];
    STAssertFalse(removeSuccess, nil);
    STAssertEquals(NO_MODIFICATION_ALLOWED_ERR, error, nil);

    //删除不存在的文件会失败
    removeSuccess = [file remove:workSpace filePath:@"notExists.txt" error:&error];
    STAssertFalse(removeSuccess, nil);
    STAssertEquals(NOT_FOUND_ERR, error, nil);

    NSString* filePath = @"test.txt";
    [file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    removeSuccess = [file remove:workSpace filePath:filePath error:&error];
    STAssertTrue(removeSuccess, nil);
    STAssertEquals(NO_ERROR, error, nil);
}

- (void)testTransferTo
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    XFileError error = NO_ERROR;

    NSString* oldPath = @"test.txt";
    NSString* newPath = @"newDir";
    NSString* newName = @"newName.txt";
    [file remove:workSpace filePath:newName error:&error];

    [file getFile:workSpace dirPath:@"/" filePath:oldPath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    [file getFile:workSpace dirPath:@"/" filePath:newPath create:YES exclusive:NO isDir:YES error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSDictionary* entry = [file transferTo:workSpace oldPath:oldPath newParentPath:newPath newName:newName
                                    isCopy:NO error:&error];
    BOOL isFile = [(NSNumber*)[entry valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[entry valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [entry valueForKey:@"name"];
    NSString* fullPath = [entry valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(newName, fileName, nil);
    STAssertEqualObjects(@"/newDir/newName.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    entry = [file transferTo:workSpace oldPath:fullPath newParentPath:@"/" newName:newName isCopy:YES error:&error];
    isFile = [(NSNumber*)[entry valueForKey: @"isFile"] boolValue];
    isDir = [(NSNumber*)[entry valueForKey: @"isDirectory"] boolValue];
    fileName = [entry valueForKey:@"name"];
    fullPath = [entry valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(newName, fileName, nil);
    STAssertEqualObjects(@"/newName.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    BOOL removeSuccess = [file remove:workSpace filePath:fullPath error:&error];
    STAssertTrue(removeSuccess, nil);
    STAssertEquals(NO_ERROR, error, nil);
    removeSuccess = [file remove:workSpace filePath:@"newDir/newName.txt" error:&error];
    STAssertTrue(removeSuccess, nil);
    STAssertEquals(NO_ERROR, error, nil);

    newPath = @"newDirectory";
    [file getFile:workSpace dirPath:@"/" filePath:newPath create:YES exclusive:NO isDir:YES error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    entry = [file transferTo:workSpace oldPath:@"newDir" newParentPath:newPath newName:@"moveDir" isCopy:NO error:&error];
    isFile = [(NSNumber*)[entry valueForKey: @"isFile"] boolValue];
    isDir = [(NSNumber*)[entry valueForKey: @"isDirectory"] boolValue];
    fileName = [entry valueForKey:@"name"];
    fullPath = [entry valueForKey:@"fullPath"];
    STAssertEquals(NO, isFile, nil);
    STAssertEquals(YES, isDir, nil);
    STAssertEqualObjects(@"moveDir", fileName, nil);
    STAssertEqualObjects(@"/newDirectory/moveDir", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    removeSuccess = [file removeRecursively:workSpace filePath:@"newDirectory" error:&error];
    STAssertTrue(removeSuccess, nil);
}

- (void)testGetParent
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    XFileError error = NO_ERROR;

    NSString* filePath = @"child.txt";
    [file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    NSDictionary* parentEntry = [file getParent:workSpace filePath:filePath error:&error];
    BOOL isFile = [(NSNumber*)[parentEntry valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[parentEntry valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [parentEntry valueForKey:@"name"];
    NSString* fullPath = [parentEntry valueForKey:@"fullPath"];
    STAssertEquals(NO, isFile, nil);
    STAssertEquals(YES, isDir, nil);
    STAssertEqualObjects(@"/", fileName, nil);
    STAssertEqualObjects(@"/", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);
    BOOL removeSuccess = [file remove:workSpace filePath:filePath error:&error];
    STAssertTrue(removeSuccess, nil);

    parentEntry = [file getParent:workSpace filePath:@"/" error:&error];
    isFile = [(NSNumber*)[parentEntry valueForKey: @"isFile"] boolValue];
    isDir = [(NSNumber*)[parentEntry valueForKey: @"isDirectory"] boolValue];
    fileName = [parentEntry valueForKey:@"name"];
    fullPath = [parentEntry valueForKey:@"fullPath"];
    STAssertEquals(NO, isFile, nil);
    STAssertEquals(YES, isDir, nil);
    STAssertEqualObjects(@"/", fileName, nil);
    STAssertEqualObjects(@"/", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    parentEntry = [file getParent:workSpace filePath:@"notExists.txt" error:&error];
    STAssertEquals(NOT_FOUND_ERR, error, nil);
    STAssertNil(parentEntry, nil);
}

- (void)testGetMetadata
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    XFileError error = NO_ERROR;

    NSString* filePath = @"metadata.txt";
    [file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    NSDate* date = [file getMetadata:workSpace filePath:filePath error:&error];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSError* __autoreleasing nsError = nil;
    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workSpace];
    NSDictionary* fileAttribs = [fileMgr attributesOfItemAtPath:fullPath error:&nsError];
    NSDate* expectedDate = [fileAttribs fileModificationDate];
    STAssertEqualObjects(date, expectedDate, nil);

    BOOL removeSuccess = [file remove:workSpace filePath:filePath error:&error];
    STAssertTrue(removeSuccess, nil);
}

- (void)testSetMetadata
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];

    BOOL testResult = [file setMetadata:[NSNumber numberWithInt:1] filePath:workSpace];
    STAssertTrue(testResult, nil);

    testResult = [file setMetadata:[NSNumber numberWithInt:0] filePath:workSpace];
    STAssertTrue(testResult, nil);

    NSString* filePath = @"";
    testResult = [file setMetadata:[NSNumber numberWithInt:1] filePath:filePath];
    STAssertFalse(testResult, nil);
}

- (void)testRemoveRecursively
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    XFileError error = NO_ERROR;

    BOOL removeSuccess = [file removeRecursively:workSpace filePath:@"/" error:&error];
    STAssertFalse(removeSuccess, nil);
    STAssertEquals(NO_MODIFICATION_ALLOWED_ERR, error, nil);

    NSString* removePath = @"removeDir";
    [file getFile:workSpace dirPath:@"/" filePath:removePath create:YES exclusive:NO isDir:YES error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    NSString* fileName = @"removeDir/remove.txt";
    [file getFile:workSpace dirPath:@"/" filePath:fileName create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    NSString* fileDirPath = @"removeDir/remove";
    [file getFile:workSpace dirPath:@"/" filePath:fileDirPath create:YES exclusive:NO isDir:YES error:&error];
    STAssertEquals(NO_ERROR, error, nil);
    removeSuccess = [file removeRecursively:workSpace filePath:removePath error:&error];
    STAssertTrue(removeSuccess, nil);
}

- (void)testReadAsText
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* filePath = @"test.txt";
    XFileError error = NO_ERROR;

    NSDictionary* ret =[file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    BOOL isFile = [(NSNumber*)[ret valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[ret valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [ret valueForKey:@"name"];
    NSString* fullPath = [ret valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(filePath, fileName, nil);
    STAssertEqualObjects(@"/test.txt", fullPath, nil);
    STAssertEquals(NO_ERROR, error, nil);

    NSString* data = @"this is test data";
    int writeBytes = [file writeToFile:workSpace filePath:filePath withData:data append:YES error:&error];
    int expected = [data length];
    STAssertEquals(expected, writeBytes, nil);

    NSString* readData = [file readAsText:workSpace filePath:filePath error:&error];
    STAssertEqualObjects(data, readData, nil);
    STAssertEquals(NO_ERROR, error, nil);

    readData = [file readAsText:workSpace filePath:@"noSuchFile.txt" error:&error];
    STAssertNil(readData, nil);
    STAssertEquals(NOT_FOUND_ERR, error, nil);

    BOOL removeSuccess = [file remove:workSpace filePath:filePath error:&error];
    STAssertTrue(removeSuccess, nil);
}

- (void)testReadEntries
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* filePath = @"testEntryDir";
    XFileError error = NO_ERROR;

    [file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:YES error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSString* childDirPath = @"childDir";
    [file getFile:workSpace dirPath:filePath filePath:childDirPath create:YES exclusive:NO isDir:YES error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSString* childFilePath = @"childFile.txt";
    [file getFile:workSpace dirPath:filePath filePath:childFilePath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSString* childFileOfchildDirPath = @"childFileOfchildDir.txt";
    [file getFile:workSpace dirPath:@"testEntryDir/childDir" filePath:childFileOfchildDirPath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSMutableArray* entries = [file readEntries:workSpace filePath:filePath error:&error];
    STAssertTrue(([entries count] == 2), nil);

    BOOL removeSuccess = [file removeRecursively:workSpace filePath:filePath error:&error];
    STAssertTrue(removeSuccess, nil);
}

- (void)testResolveLocalFileSystemURI
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* fileURI = @"file:///testFile.txt";
    XFileError error = NO_ERROR;

    [file getFile:workSpace dirPath:@"/" filePath:@"testFile.txt" create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSDictionary* entry = [file resolveLocalFileSystemURI:workSpace fileURI:fileURI error:&error];
    BOOL isFile = [(NSNumber*)[entry valueForKey: @"isFile"] boolValue];
    BOOL isDir = [(NSNumber*)[entry valueForKey: @"isDirectory"] boolValue];
    NSString* fileName = [entry valueForKey:@"name"];
    NSString* fullPath = [entry valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(@"testFile.txt", fileName, nil);
    STAssertEqualObjects(@"/testFile.txt", fullPath, nil);

    fileURI = @"file:///testFile.txt?name";
    entry = [file resolveLocalFileSystemURI:workSpace fileURI:fileURI error:&error];
    isFile = [(NSNumber*)[entry valueForKey: @"isFile"] boolValue];
    isDir = [(NSNumber*)[entry valueForKey: @"isDirectory"] boolValue];
    fileName = [entry valueForKey:@"name"];
    fullPath = [entry valueForKey:@"fullPath"];
    STAssertEquals(YES, isFile, nil);
    STAssertEquals(NO, isDir, nil);
    STAssertEqualObjects(@"testFile.txt", fileName, nil);
    STAssertEqualObjects(@"/testFile.txt", fullPath, nil);
}

- (void)testReadAsDataURLTest
{
    XFile *file = [[XFile alloc] init];
    STAssertNotNil(file, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    NSString* workSpace = [app getWorkspace];
    NSString* filePath = @"test.txt";
    XFileError error = NO_ERROR;

    [file getFile:workSpace dirPath:@"/" filePath:filePath create:YES exclusive:NO isDir:NO error:&error];
    STAssertEquals(NO_ERROR, error, nil);

    NSString* data = @"this is test data";
    int writeBytes = [file writeToFile:workSpace filePath:filePath withData:data append:YES error:&error];
    int expected = [data length];
    STAssertEquals(expected, writeBytes, nil);

    NSString* readData = [file readAsDataURL:workSpace filePath:filePath error:&error];
    STAssertTrue([readData hasPrefix:@"data:text/plain;base64,"], nil);
    STAssertEquals(NO_ERROR, error, nil);

    BOOL removeSuccess = [file remove:workSpace filePath:filePath error:&error];
    STAssertTrue(removeSuccess, nil);
}

@end
