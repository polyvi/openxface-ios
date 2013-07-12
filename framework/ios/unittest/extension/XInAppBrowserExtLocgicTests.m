
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
//  XInAppBrowserExtLocgicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XInAppBrowserExt.h"
#import "XInAppBrowserExt_Privates.h"
#import "XJsCallback.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"


@interface XInAppBrowserExtLocgicTests : SenTestCase
{
    XInAppBrowserExt* browser;
}
@end

@implementation XInAppBrowserExtLocgicTests

- (void)setUp
{
    [super setUp];

    self->browser = [[XInAppBrowserExt alloc] init];
    STAssertNotNil(self->browser, @"Failed to create browser extension instance");
}

-(void)testUpdateURL
{
    NSString* baseURLStr1 = @"http://www.test.com";
    NSString* baseURLStr2 = @"file://localhost/test/index.html";
    NSString* targetURLStr1 = @"http://www.baidu.html";
    NSString* targetURLStr2= @"file:///a/b/c/index.html";

    NSURL* url1 = [browser updateURL:@"test.html" baseURL:[NSURL URLWithString:baseURLStr1]];
    NSURL* url2 = [browser updateURL:@"dir/test.html" baseURL:[NSURL URLWithString:baseURLStr2]];
    STAssertEqualObjects([url1 absoluteString], @"http://www.test.com/test.html", nil);
    STAssertEqualObjects([url2 absoluteString], @"file://localhost/test/dir/test.html", nil);
    
    NSURL* url3 = [browser updateURL:targetURLStr1 baseURL:[NSURL URLWithString:baseURLStr1]];
    NSURL* url4 = [browser updateURL:targetURLStr2 baseURL:[NSURL URLWithString:baseURLStr2]];
    STAssertEqualObjects([url3 absoluteString], targetURLStr1, nil);
    STAssertEqualObjects([url4 absoluteString], targetURLStr2, nil);
}

@end
