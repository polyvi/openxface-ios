
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
//  XApplicationPersistenceApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplicationTests.h"
#import "XApplicationPersistence.h"
#import "XApplicationPersistence_Privates.h"
#import "XApplist.h"
#import "XApplication.h"

@interface XApplicationPersistenceApplicationTests : XApplicationTests
{
@private
    XApplicationPersistence *appPersistence;
}
@end

@implementation XApplicationPersistenceApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->appPersistence = [[XApplicationPersistence alloc] init];
    STAssertNotNil(self->appPersistence, @"Failed to create XApplicationPersistence instance");
}

- (void)testReadAppsFromConfig
{
    // 执行测试
    XAppList *appList = [[XAppList alloc] init];
    STAssertTrueNoThrow([self->appPersistence readAppsFromConfig:appList], nil);

    // 测试后检查
    STAssertTrueNoThrow((0 != [[[appList getEnumerator] allObjects] count]), nil);
    STAssertTrueNoThrow([appList containsApp:[self->appPersistence getDefaultAppId]], nil);
}

- (void)testGetDefaultAppId
{
    // 执行测试
    NSString *defaultAppId = [self->appPersistence getDefaultAppId];
    STAssertNotNil(defaultAppId, nil);
    STAssertTrueNoThrow([[[self app] getAppId] isEqualToString:defaultAppId], nil);
}

- (void)testGetAppsDict
{
    // 执行测试
    NSMutableDictionary *dict = [self->appPersistence getAppsDict];
    STAssertNotNil(dict, nil);

    NSString *appId = [[self app] getAppId];
    STAssertTrue([[dict allKeys] containsObject:appId], nil);
}

@end
