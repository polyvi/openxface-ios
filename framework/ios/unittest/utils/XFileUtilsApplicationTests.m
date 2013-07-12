
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
//  XFileUtilsApplicationTests.m
//  xFace
//
//

#import "XFileUtils.h"
#import "SenTestingKit/SenTestingKit.h"
#import "XConfiguration.h"
#import "XConstants.h"

@interface XFileUtilsApplicationTests : SenTestCase

@end

@implementation XFileUtilsApplicationTests

- (void) testCopyEmbeddedJsFileWhenDstNonexistent
{
    NSString *testAppId = @"test_app_id_111";
    XConfiguration *config = [XConfiguration getInstance];
    NSString *appDirPath = [[config appInstallationDir] stringByAppendingPathComponent:testAppId];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:appDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *dstJsPath = [appDirPath stringByAppendingPathComponent:XFACE_JS_FILE_NAME];
    STAssertFalse([manager fileExistsAtPath:dstJsPath], nil);

    [XFileUtils copyEmbeddedJsFile:XFACE_JS_FILE_NAME withAppId:testAppId];
    STAssertTrue([manager fileExistsAtPath:dstJsPath], nil);

    [manager removeItemAtPath:appDirPath error:nil];
}

- (void) testCopyEmbeddedJsFileWhenDstExistent
{
    NSString *testAppId = @"test_app_id_111";
    XConfiguration *config = [XConfiguration getInstance];
    NSString *appDirPath = [[config appInstallationDir] stringByAppendingPathComponent:testAppId];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:appDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *dstJsPath = [appDirPath stringByAppendingPathComponent:XFACE_JS_FILE_NAME];
    STAssertFalse([manager fileExistsAtPath:dstJsPath], nil);

    [XFileUtils copyEmbeddedJsFile:XFACE_JS_FILE_NAME withAppId:testAppId];
    STAssertTrue([manager fileExistsAtPath:dstJsPath], nil);

    //测试dstJs已经存在的情况
    [XFileUtils copyEmbeddedJsFile:XFACE_JS_FILE_NAME withAppId:testAppId];
    STAssertTrue([manager fileExistsAtPath:dstJsPath], nil);

    [manager removeItemAtPath:appDirPath error:nil];
}

@end
