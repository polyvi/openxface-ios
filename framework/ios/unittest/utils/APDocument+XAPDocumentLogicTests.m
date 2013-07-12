
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
//  APDocument+XAPDocumentLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "APDocument+XAPDocument.h"
#import "XConfiguration.h"
#import "XConstantsLogicTests.h"
#import "XLogicTests.h"

@interface APDocument_XAPDocumentLogicTests : XLogicTests

@end

@implementation APDocument_XAPDocumentLogicTests

- (void)testDocumentWithFilePathWithNilResult
{
    APDocument *doc = [APDocument documentWithFilePath:nil];
    STAssertNil(doc, nil);

    NSString *filePath = [[[XConfiguration getInstance] systemWorkspace] stringByAppendingFormat:@"%@", XCONSTANTS_LOGIC_TESTS_TEMP_CONFIG_FILE_NAME];
    STAssertNotNil(filePath, nil);

    doc = [APDocument documentWithFilePath:filePath];
    STAssertNil(doc, nil);
}

- (void)testDocumentWithFilePath
{
    NSString *filePath = [[[XConfiguration getInstance] systemWorkspace] stringByAppendingFormat:@"%@", XCONSTANTS_LOGIC_TESTS_TEMP_CONFIG_FILE_NAME];
    STAssertNotNil(filePath, nil);

    NSData *xmlData=[XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_STR dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [xmlData writeToFile:filePath atomically:YES];
    STAssertTrue(ret, nil);

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    ret = [fileMgr fileExistsAtPath:filePath];
    STAssertTrue(ret, nil);

    // 执行测试
    APDocument *doc = [APDocument documentWithFilePath:filePath];
    STAssertNotNil(doc, nil);

    // 清理测试环境
    NSError * __autoreleasing error = nil;
    ret = [fileMgr removeItemAtPath:filePath error:&error];
    STAssertTrue(ret, nil);
}

@end
