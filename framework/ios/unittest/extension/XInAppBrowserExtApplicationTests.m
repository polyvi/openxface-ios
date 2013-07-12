
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
//  inAppBrowserExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XInAppBrowserExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"
#import "XApplication.h"

@interface XInAppBrowserExtApplicationTests : XApplicationTests
{
    @private
    XInAppBrowserExt* inAppBrowser;
}
@end

@implementation XInAppBrowserExt (test)

-(int) getBrowserViewControllerCount
{
    return self->browserViewControllers.count;
}

@end
@implementation XInAppBrowserExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->inAppBrowser = [[XInAppBrowserExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->inAppBrowser, @"Failed to create inAppBrowser extension instance");
}

- (void)testOpen
{
    //创建测试环境
    NSString *callbackId = @"inAppBrowser0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"open"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithArray:@[@"www.baidu.com", @"_blank", @"location=yes"]];

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    int countBeforeOpen = [self->inAppBrowser getBrowserViewControllerCount];
    STAssertNoThrow([self->inAppBrowser open:arguments withDict:options], nil);
    int countAfterOpen = [self->inAppBrowser getBrowserViewControllerCount];
    STAssertTrue(countAfterOpen > 0 && countAfterOpen >= countBeforeOpen, nil);
}

- (void)testOpenAndClose
{
    //创建测试环境
    NSString *callbackId = @"inAppBrowser0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"close"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    [self testOpen];
    int countBeforeClose = [self->inAppBrowser getBrowserViewControllerCount];
    STAssertNoThrow([self->inAppBrowser close:arguments withDict:options], nil);
    int countAfterClose = [self->inAppBrowser getBrowserViewControllerCount];
    STAssertTrue(countAfterClose - countBeforeClose == -1, nil);
}

@end
