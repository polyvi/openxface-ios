
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
//  XDefaultSecurityResourceFilterLogicTests.m
//  xFacePAASLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XSecurityResourceFilter.h"
#import "XSecurityResourceFilterFactory.h"

@interface XDefaultSecurityResourceFilterLogicTests : SenTestCase
{
    id<XSecurityResourceFilter> filter;
}

@end

@implementation XDefaultSecurityResourceFilterLogicTests

- (void)setUp
{
    [super setUp];
    filter = [XSecurityResourceFilterFactory createFilter];

    NSLog(@"%@ setUp", self.name);
}

-(void)testAccept
{
    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/js/xface.js"], nil);
    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/xfaceError.html"], nil);
    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/js/debug.js"], nil);

    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/js/ui.js"], nil);
    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/index.html"], nil);
    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/index.htm"], nil);
    STAssertTrue([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/css/css.css"], nil);

    STAssertFalse([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/xface.png"], nil);
    STAssertFalse([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/xface.jpg"], nil);
    STAssertFalse([filter accept:@"http://apollo.polyvi.com/paas/apps/offlineApp/offile/img.img"], nil);
}

@end
