
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
//  XCalendarExtLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XCalendarExt.h"
#import "XCalendarExt_Privates.h"

@interface XCalendarExtLogicTests : SenTestCase
{
@private
    XCalendarExt *calendarExt;
}
@end

@implementation XCalendarExtLogicTests

- (void)setUp
{
    [super setUp];

    self->calendarExt = [[XCalendarExt alloc] init];
    STAssertNotNil(self->calendarExt, @"Failed to create calendar extension instance");
}

-(void) testGetDateComponentsFromDate
{
    NSDate* now = [NSDate date];
    STAssertNotNil([self->calendarExt getDateComponentsFrom:now], nil);
}

@end
