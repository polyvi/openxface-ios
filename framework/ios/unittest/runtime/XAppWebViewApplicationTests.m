
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
//  XAppWebViewApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppWebView.h"
#import "XRuntime_Privates.h"
#import "XRuntime.h"
#import "XAppManagement.h"
#import "XAppManagement_Privates.h"
#import "NSMutableArray+XStackAdditions.h"
#import "XApplication.h"
#import "XApplicationTests.h"
#import "XAppView.h"

@interface XAppWebViewApplicationTests : XApplicationTests

@end

@implementation XAppWebViewApplicationTests

- (void)testLoaded
{
    BOOL loaded = ![[self appView] isLoading];
    STAssertTrue(loaded, nil);
}

- (void)testEvalJavaScript
{
    NSString *userAgent = [[self appView] stringByEvaluatingJavaScriptFromString:@"window.navigator.userAgent"];
    STAssertTrueNoThrow(NSNotFound != [userAgent rangeOfString:@"iPhone"].location, nil);
}

- (void)testSetValid
{
    id<XAppView> view = [[XAppWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    STAssertFalse([view isValid], nil);
    [view setValid:YES];
    STAssertTrue([view isValid], nil);
}

@end
