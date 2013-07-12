
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
//  XLogicTests.m
//  xFaceLib
//
//

#import "XLogicTests.h"
#import "XConfiguration.h"
#import "XConstantsLogicTests.h"
#import "XFileOperatorFactory.h"
#import "XFileOperator.h"
#import "XConfiguration_Privates.h"

@interface XLogicTests()

/**
    初始化测试环境：如创建系统配置文件
    @returns 成功返回YES, 失败返回NO
 */
- (BOOL)initialize;

/**
    清理测试环境：如删除系统配置文件
    @returns 成功返回YES, 失败返回NO
 */
- (BOOL)finalize;

@end

@implementation XLogicTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);

    STAssertTrueNoThrow([self initialize], @"Failed to initialize test environment in %@!", self.name);
}

- (void)tearDown
{
    STAssertTrueNoThrow([self finalize], @"Failed to clean up test environment in %@!", self.name);
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

#pragma mark Privates

- (BOOL)initialize
{
    XConfiguration *config = [XConfiguration getInstance];
    BOOL ret = [config loadConfiguration];
    if (!ret)
    {
        NSLog(@"Failed to load configuration!");
        return ret;
    }

    // 清空系统工作空间
    __autoreleasing NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:[config systemWorkspace]])
    {
        [fileManager removeItemAtPath:[config systemWorkspace] error:&error];
    }

    ret = [config prepareSystemWorkspace];
    return ret;
}

- (BOOL)finalize
{
    // NOTE:目前为空实现
    return YES;
}

@end
