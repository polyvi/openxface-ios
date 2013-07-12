
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
//  XRuntimeLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XApplication.h"
#import "XAppViewStub.h"
#import "XAppInfo.h"
#import "XApplicationFactory.h"
#import "XLogicTests.h"

@interface XRuntimeLogicTests : XLogicTests
{
    XRuntime         *runtime;
    id<XApplication>  app;
}

@end

@implementation XRuntimeLogicTests

- (void)setUp
{
    [super setUp];

    self->runtime = [[XRuntime alloc] init];
    STAssertNotNil(self->runtime, @"Failed to create XRuntime instance");

    self->app = [XApplicationFactory create:[[XAppInfo alloc] init]];

    STAssertNoThrow([self->runtime didFinishPreparingWorkEnvironment], nil);
}

- (void)testStartAppWhenHasExceptions
{
    STAssertThrows([self->runtime startApp:nil], nil);

    [self->app setAppView:[[XAppViewStub alloc] init]];
    //STAssertThrows([self->runtime startApp:self->app], nil);
}

- (void)testStartApp
{
    // appcontroller为空
    self->runtime.rootViewController = nil;
    STAssertNoThrow([self->runtime startApp:self->app], nil);
}

- (void)testCloseApp
{
    STAssertThrows([self->runtime closeApp:self->app], nil);

    [self->app setAppView:[[XAppViewStub alloc] init]];
    STAssertNoThrow([self->runtime closeApp:self->app], nil);
}

@end
