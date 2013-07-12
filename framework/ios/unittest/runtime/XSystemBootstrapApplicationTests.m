
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
//  XGeneralSystemBootstrapApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XGeneralSystemBootstrap_Privates.h"
#import "XGeneralSystemBootstrap.h"
#import "XRuntime_Privates.h"
#import "XRuntime.h"
#import "XConfiguration.h"

@interface XGeneralSystemBootstrapApplicationTests : SenTestCase <XSystemBootstrapDelegate>
{
@private
    XGeneralSystemBootstrap *systemBootstrap;
}

@end

@implementation XGeneralSystemBootstrapApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->systemBootstrap = [[XGeneralSystemBootstrap alloc] initWithDelegate:self];
    STAssertNotNil(self->systemBootstrap, @"Failed to get system initializer instance");
}

- (void)testDeployResources
{
    // 执行xFaceInstalledPackage.zip的解压操作
    BOOL ret = [systemBootstrap deployResources];
    STAssertTrue(ret, nil);

    XConfiguration *config = [XConfiguration getInstance];
    [config encryptSystemConfigFile];
    NSString *unpackedPath = [config systemWorkspace];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    ret = [fileManager fileExistsAtPath:unpackedPath];
    STAssertTrue(ret, nil);

    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:unpackedPath];
    STAssertTrue((0 < [[enumerator allObjects] count]), nil);
}

- (void)testPrepareWorkEnvironmentBug1130
{
    // 执行xFaceInstalledPackage.zip的解压操作
    [systemBootstrap prepareWorkEnvironment];
}

#pragma mark delegate

-(void) didFinishPreparingWorkEnvironment
{
    STAssertFalse([systemBootstrap isPreinstallRequired], nil);
    STAssertNotNil([[XConfiguration getInstance] systemAllowedExtensions], nil);
}

-(void) didFailToPrepareEnvironmentWithError:(NSError *)error
{
    STAssertFalse(YES, @"Failed to test prepareWorkEnvironment method");
}
@end

