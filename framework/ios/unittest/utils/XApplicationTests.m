
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
//  XApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XAppWebView.h"
#import "XRuntime_Privates.h"
#import "XRuntime.h"
#import "XAppManagement.h"
#import "XAppManagement_Privates.h"
#import "NSMutableArray+XStackAdditions.h"
#import "XApplication.h"

@interface XApplicationTests()

/**
    运行run loop直到block返回true
 */
- (void)waitForConditionName:(NSString *)conditionName block:(BOOL (^)())block;

/**
    运行run loop直到app启动
 */
- (void)waitForAppStart;

@end

@implementation XApplicationTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    [self waitForAppStart];
}

- (XRuntime *)runtime
{
    if (!self->runtime)
    {
        id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
        self->runtime = [delegate performSelector:@selector(runtime)];
        STAssertTrueNoThrow([self->runtime isKindOfClass:[XRuntime class]], nil);
    }

    return self->runtime;
}

- (XAppWebView *)appView
{
    if (!self->appView)
    {
        self->appView = (XAppWebView *)[[self app] appView];
    }

    return self->appView;
}

- (id<XApplication>)app
{
    if (!self->app)
    {
        self->app = [[[[self runtime] appManagement] activeApps] objectAtIndex:0];
    }

    return self->app;
}

#pragma mark Privates

- (void)waitForConditionName:(NSString *)conditionName block:(BOOL (^)())block {
    const NSTimeInterval conditionTimeout = 10.0;
    const int minIterations = 5;

    NSDate *startTime = [NSDate date];
    int i = 0;
    while (!block()) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        NSTimeInterval elapsed = -[startTime timeIntervalSinceNow];
        STAssertTrue(i < minIterations || elapsed < conditionTimeout,
                     @"Timed out waiting for condition %@", conditionName);
        ++i;
    }
}

- (void)waitForAppStart
{
    [self waitForConditionName:@"AppStart" block:^{
        NSMutableArray *activeApps = [[[self runtime] appManagement] activeApps];
        BOOL ret = ((0 != [activeApps count]) && (![[[activeApps objectAtIndex:0] appView] isLoading]));
        return ret;
    }];
}

@end
