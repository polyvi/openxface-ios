
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
//  SplashScreenExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XSplashScreenExt.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"
#import "XSplashScreenExt_Privates.h"
#import "XRuntime_Privates.h"
#import "XApplication.h"


@interface XSplashScreenExtApplicationTests : XApplicationTests
{
@private
    XSplashScreenExt* splashScreenExt;
}
@end

@implementation XSplashScreenExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->splashScreenExt = [[XSplashScreenExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->splashScreenExt, @"Failed to create splashScreen extension instance");
}

- (void)testShow
{
    //创建测试环境
    NSString *callbackId = @"SplashScreen0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"show"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->splashScreenExt show:arguments withDict:options], nil);
}

- (void)testHide
{
    //创建测试环境
    NSString *callbackId = @"SplashScreen0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"hide"];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->splashScreenExt hide:arguments withDict:options], nil);
}

- (void)testShowSplashWithImageWhenViewControllerIsNil
{
    STAssertNoThrow([self->splashScreenExt showSplashWithImage:nil inApp:nil], nil);
}

- (void)testShowSplashWithImageWhenViewControllerIsNotNil
{
    UIViewController *viewController = (UIViewController *)[[self runtime] rootViewController];
    self->splashScreenExt.viewController = viewController;

    STAssertNoThrow([self->splashScreenExt showSplashWithImage:nil inApp:nil], nil);
}

@end
