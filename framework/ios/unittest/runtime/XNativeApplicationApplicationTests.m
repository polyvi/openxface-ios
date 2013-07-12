
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
//  XNativeApplicationApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XNativeApplication.h"
#import "XAppInfo.h"
#import "XApplicationFactory.h"
#import "XConstants.h"

#define XNATIVE_APP_APPLICAITON_TESTS_CUSTOME_URL @"https://itunes.apple.com/us/album/toy-story-original-walt-disney/id156093462?i=156093464"
#define XNATIVE_APP_APPLICAITON_TESTS_START_PARAM @"user:foo&password:1111"

@interface XNativeApplicationApplicationTests : SenTestCase
{
@private
    id<XApplication>  app;
}
@end

@implementation XNativeApplicationApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setType:APP_TYPE_NAPP];
    self->app = [XApplicationFactory create:appInfo];
    STAssertNotNil(self->app, @"Failed to create native application instance");
}

- (void)testIsInstalledWithTrueResult
{
    [[self->app appInfo] setEntry:XNATIVE_APP_APPLICAITON_TESTS_CUSTOME_URL];
    STAssertTrue([self->app isInstalled], nil);
}

- (void)testLoad
{
    STAssertThrows([self->app load], nil);
}

- (void)testLoadWithParameters
{
    [[self->app appInfo] setEntry:XNATIVE_APP_APPLICAITON_TESTS_CUSTOME_URL];
    STAssertNoThrow([self->app loadWithParameters:nil], nil);

    NSString *params = XNATIVE_APP_APPLICAITON_TESTS_START_PARAM;
    STAssertNoThrow([self->app loadWithParameters:params], nil);
}

@end
