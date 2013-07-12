
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
//  XExtensionManagerLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XExtensionManager.h"
#import "XExtension.h"
#import "XJavaScriptEvaluator.h"
#import "XAppList.h"
#import "XRootViewController.h"
#import "XExtensionManager_Privates.h"
#import "XApplication.h"
#import "XApplicationFactory.h"

@interface XExtensionManagerLogicTests : SenTestCase
{
@private
    XAppList *appList;
    XExtensionManager *extMgr;
}

@end

@implementation XExtensionManagerLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->appList = [[XAppList alloc] init];
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];

    self->extMgr = [[XExtensionManager alloc] initWithApp:webApp];
    STAssertNotNil(self->extMgr, @"Failed to create rootViewController instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

- (void)testRegisterExtensionWithTrueResult
{
    XExtension* extStub = [[XExtension alloc] init];

    BOOL ret = [extMgr registerExtension:extStub withName:NSStringFromClass([extStub class])];

    STAssertTrue(ret, nil);
}

@end
