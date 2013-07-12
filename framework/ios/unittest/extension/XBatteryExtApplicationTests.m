
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
//  XBatteryExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XApplication.h"
#import "XRootViewController.h"
#import "XBatteryExt.h"
#import "XBatteryExt_Privates.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XConstants.h"
#import "XApplication.h"

@interface XBatteryExtApplicationTests : XApplicationTests
{
    @private
    XBatteryExt* batteryExt;
}
@end

@implementation XBatteryExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->batteryExt = [[XBatteryExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->batteryExt, @"Failed to create battery extension instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}

- (void) testUpdateBatteryStatus
{
    NSString *callbackId = @"Battery0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"start"];
    [[self app] registerJsCallback:@"XBatteryExt_start:withDict:" withCallback:callback];
    [[self->batteryExt registeredApps] addObject:[self app]];
    STAssertNoThrow([self->batteryExt updateBatteryStatus:nil], nil);
}

- (void) testGetBatteryStatus
{
    NSDictionary* battery;
    STAssertNoThrow(battery = [self->batteryExt getBatteryStatus], nil);
    STAssertNotNil([battery objectForKey:@"isPlugged"], nil);
    STAssertNotNil([battery objectForKey:@"level"], nil);
}

- (void) testStart
{
    NSString *callbackId = @"Battery0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"start"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    [[self app] registerJsCallback:@"XBatteryExt_start:withDict:" withCallback:callback];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    STAssertNoThrow([self->batteryExt start:arguments withDict:options], nil);
}

- (void) testStop
{
    NSString *callbackId = @"Battery0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"stop"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    [[self app] registerJsCallback:@"XBatteryExt_stop:withDict:" withCallback:callback];
    STAssertNoThrow([self->batteryExt stop:arguments withDict:options], nil);
}

@end
