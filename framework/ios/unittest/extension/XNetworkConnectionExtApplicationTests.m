
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
//  XNetworkConnectionExtApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XApplicationTests.h"
#import "XNetworkConnectionExt.h"
#import "XNetworkConnectionExt_Privates.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XExtensionManager_Privates.h"
#import "XExtensionManager.h"
#import "XJsCallback.h"
#import "XApplication.h"
#import "XNetworkReachability.h"
#import "XConstants.h"

#define NETWORK_CONNECTION_EXTENSION_NAME   @"NetworkConnection"

@interface XNetworkConnectionExtApplicationTests : XApplicationTests
{
@private
    XNetworkConnectionExt *networkConnectionExt;
}

@end

@implementation XNetworkConnectionExtApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->networkConnectionExt = [[XNetworkConnectionExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];

    STAssertNotNil(self->networkConnectionExt, @"Failed to create network connection extension instance");
}

- (void)testGetConnectionInfo
{
    NSString *callbackId = @"NetworkConnection0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"getConnectionInfo"];

    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->networkConnectionExt getConnectionInfo:arguments withDict:options], nil);
    STAssertNotNil([self->networkConnectionExt connectionType], nil);
    NSString *type = [self->networkConnectionExt getConnectionType:[self->networkConnectionExt internetReach]];
    STAssertTrue([type isEqualToString:[self->networkConnectionExt connectionType]], nil);
}

@end
