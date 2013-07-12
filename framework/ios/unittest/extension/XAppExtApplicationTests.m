
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
//  XAppExtApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJavaScriptEvaluator.h"
#import "XAppManagement.h"
#import "XAppManagement_Privates.h"
#import "XApplication.h"
#import "XJsCallback.h"
#import "XApplicationTests.h"
#import "XConstants.h"

#define APP_EXT_APPLICATION_TEST_URL        @"http://www.google.com/"

@interface XAppExtApplicationTests : XApplicationTests
{
@private
    XAppExt *appExt;            //TODO:添加基类，由基类提供获取扩展的方法
}

@end

@implementation XAppExtApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->appExt = [[XAppExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];

    STAssertNotNil(self->appExt, @"Failed to create app extension instance");
}

- (void)testOpenUrl
{
    STAssertNoThrow([self->appExt openUrl:nil withDict:nil], nil);

    NSString *callbackId = @"App0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"openUrl"];
    NSString *url = APP_EXT_APPLICATION_TEST_URL;

    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    [arguments addObject:url];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->appExt openUrl:arguments withDict:options], nil);
}

@end
