
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
//  XOnlineModeApplicationTests
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplication.h"
#import "XApplicationTests.h"
#import "XApplication.h"
#import "XApplication.h"
#import "XResourceIterator.h"
#import "XOnlineMode.h"
#import "XOnlineMode_Privates.h"
#import "XWebApplication_Privates.h"

@interface XOnlineModeApplicationTests : XApplicationTests
{
}

@end

@implementation XOnlineModeApplicationTests

- (void)testGetResourceIterator
{
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:40]];
    STAssertTrue(nil != [[[self app] getResourceIterator] next], nil);
    [(XOnlineMode*)((XWebApplication*)[self app]).mode clearCache:[self app]];
    STAssertFalse(nil != [[[self app] getResourceIterator] next], nil);
}

@end
