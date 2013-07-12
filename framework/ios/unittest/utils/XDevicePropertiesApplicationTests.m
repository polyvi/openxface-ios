
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
//  XDevicePropertiesApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XDeviceProperties.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJavaScriptEvaluator.h"

@interface XDevicePropertiesApplicationTests : SenTestCase
{
@private
    XDeviceProperties *deviceProperties; 
}

@end

@implementation XDevicePropertiesApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);
    self->deviceProperties = [[XDeviceProperties alloc] init];

    STAssertNotNil(self->deviceProperties, @"Failed to create deviceeProperties instance");
}

- (void) testDeviceProperties
{
    NSDictionary *deviceInfo = nil;

    STAssertNoThrow((deviceInfo = [self->deviceProperties deviceProperties]), nil);

    NSString *name = [deviceInfo objectForKey:@"name"];
    STAssertNotNil(name, nil);

    NSString *platform = [deviceInfo objectForKey:@"platform"];
    STAssertNotNil(platform, nil);

    NSString *model = [deviceInfo objectForKey:@"model"];
    STAssertNotNil(model, nil);

    NSString *uuid = [deviceInfo objectForKey:@"uuid"];
    STAssertEquals((NSInteger)[uuid length], 36, nil);

    NSString *systemVersion = [deviceInfo objectForKey:@"version"];
    STAssertNotNil(systemVersion, nil);

    NSString *xFaceVersion = [deviceInfo objectForKey:@"xFaceVersion"];
    STAssertNotNil(xFaceVersion, nil);

    NSString *productVersion = [deviceInfo objectForKey:@"productVersion"];
    STAssertNotNil(productVersion, nil);

    NSArray* deviceCapabilities = [NSArray arrayWithObjects:@"isCompassAvailable", @"isCompassAvailable", @"isAccelerometerAvailable", @"isTelephonyAvailable", @"isSmsAvailable", nil];

    for(NSString* key in deviceCapabilities)
    {
        NSNumber *booleanNumber= [deviceInfo objectForKey:key];
        STAssertTrue(NSOrderedSame == [booleanNumber compare:@(YES)] ||
                     NSOrderedSame == [booleanNumber compare:@(NO)], nil);
    }
}

@end
