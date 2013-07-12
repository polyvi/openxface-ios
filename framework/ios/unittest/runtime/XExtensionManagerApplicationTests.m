
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
//  XExtensionManagerApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplicationTests.h"
#import "XRuntime_Privates.h"
#import "XExtensionManager.h"
#import "XCommand.h"
#import "XAmsExt.h"
#import "XExtensionManager_Privates.h"
#import "XAppWebView.h"
#import "XWhitelist_Privates.h"
#import "XApplication.h"
#import "XAppManagement.h"
#import "XConstants.h"

#define COMMAND_INSTANCE_CALLBACK_ID        @"cmdClassName12345"
#define COMMAND_INSTANCE_CLASS_NAME         @"cmdClassName"
#define COMMAND_INSTANCE_METHOD_NAME        @"cmdMethodName"
#define COMMAND_INSTANCE_ARG1               @"arg1"
#define COMMAND_INSTANCE_ARG2               @"arg2"

@interface XExtensionManagerApplicationTests : XApplicationTests
{
@private
    XExtensionManager *extMgr;
}
@end

@implementation XExtensionManagerApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->extMgr = [[self app] extMgr];
    STAssertNotNil(self->extMgr, @"Failed to get XExtensionManager instance");
}

- (void)testExecApplicationWithFalseResult
{
    //TODO: 测试command为null的情况

    // 测试command为nil的情况
    BOOL ret = [self->extMgr exec:nil];
    STAssertFalse(ret, nil);

    // 测试获取扩展实例失败导致执行扩展失败的情况
    NSArray *jsonEntry = [NSArray arrayWithObjects:
                          COMMAND_INSTANCE_CALLBACK_ID,
                          COMMAND_INSTANCE_CLASS_NAME,
                          COMMAND_INSTANCE_METHOD_NAME,
                          [[NSMutableArray alloc] initWithObjects:COMMAND_INSTANCE_ARG1, COMMAND_INSTANCE_ARG2, nil],
                          nil];
    XCommand *cmd = [XCommand commandFromJson:jsonEntry];
    ret = [self->extMgr exec:cmd];
    STAssertFalse(ret, nil);
}

- (void)testGetCommandInstanceWithNilResult
{
    id obj = [self->extMgr getCommandInstance:nil];
    STAssertNil(obj, nil);

    obj = [self->extMgr getCommandInstance:COMMAND_INSTANCE_CLASS_NAME];
    STAssertNil(obj, nil);

    BOOL ret = [obj isKindOfClass:[XExtension class]];
    STAssertFalse(ret, nil);
}

- (void)testGetCommandInstance
{
    // 测试获取ams扩展对象的情况
    [[[self runtime] appManagement] markAsDefaultApp:[app getAppId]];
    id obj = [self->extMgr getCommandInstance:EXTENSION_AMS_NAME];
    STAssertNotNil(obj, nil);

    BOOL ret = [obj isKindOfClass:[XExtension class]];
    STAssertTrue(ret, nil);
}

@end
