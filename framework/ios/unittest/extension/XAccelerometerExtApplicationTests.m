
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
//  XAccelerometerExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XAccelerometerExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"
#import "XApplication.h"

@interface XAccelerometerExtApplicationTests : XApplicationTests
{
    @private
    XAccelerometerExt* accelerometerExt;
}
@end

@implementation XAccelerometerExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->accelerometerExt = [[XAccelerometerExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->accelerometerExt, @"Failed to create accelerometer extension instance");
}

- (void)testStart
{
    //创建测试环境
    NSString *callbackId = @"Accelerometer0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"start"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->accelerometerExt start:arguments withDict:options],nil);
}

- (void)testStop
{
    //创建测试环境
    NSString *callbackId = @"Accelerometer0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"stop"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->accelerometerExt stop:arguments withDict:options],nil);
}

@end
