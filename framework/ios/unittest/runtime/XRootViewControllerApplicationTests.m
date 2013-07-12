
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
//  XRootViewControllerLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XRootViewController.h"

#define XAPP_EVENT_VIEW_ID                1234
#define XAPP_EVENT_MESSAGE_ID             @"5678"

@interface XRootViewControllerApplicationTests : SenTestCase
{
@private
    XRootViewController *rootViewController;
}

@end

@implementation XRootViewControllerApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    rootViewController = [[XRootViewController alloc] init];
    STAssertNotNil(rootViewController, @"Failed to create rootViewController instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);

    [super tearDown];
}

/* testInit performs a simple test: just comfirm the validity of the created app controller
 */
- (void)testInit
{
    NSLog(@"%@ start", self.name);

    XRootViewController *controller = [[XRootViewController alloc] init];
    STAssertNotNil(controller, @"Failed to create rootViewController instance");

    NSLog(@"%@ end", self.name);
}

- (void)testShouldAutorotateToInterfaceOrientation
{
    STAssertTrue([rootViewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait], nil);
    STAssertFalse([rootViewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown], nil);
    STAssertFalse([rootViewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft], nil);
    STAssertFalse([rootViewController shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight], nil);
}

@end
