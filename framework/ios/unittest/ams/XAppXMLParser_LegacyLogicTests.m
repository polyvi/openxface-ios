
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
//  XAppXMLParser_LegacyLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppXMLParser_Legacy.h"
#import "APDocument+XAPDocument.h"
#import "XAPElement.h"
#import "XAppInfo.h"
#import "XAppXMLTagDefine.h"
#import "XAppXMLParser_Legacy_Privates.h"

#define XAPPXMLPARSER_CHEMA1_0_WEB_APP_CONFIG_FILE_NAME       @"appschema.xml"
#define XAPPXMLPARSER_CHEMA1_0_NATIVE_APP_CONFIG_FILE_NAME    @"nativeapp.xml"

@interface XAppXMLParser_LegacyLogicTests : SenTestCase
{
@private
    XAppXMLParser_Legacy* xmlParserForWebApp;
    XAppXMLParser_Legacy* xmlParserForNativeApp;
}
@end
@implementation XAppXMLParser_LegacyLogicTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* webAppXMLPath = [bundle pathForResource:XAPPXMLPARSER_CHEMA1_0_WEB_APP_CONFIG_FILE_NAME ofType:nil];
    NSString* nativeAppXMLPath = [bundle pathForResource:XAPPXMLPARSER_CHEMA1_0_NATIVE_APP_CONFIG_FILE_NAME ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlDataForWebApp = [fileMgr contentsAtPath:webAppXMLPath];
    self->xmlParserForWebApp = [[XAppXMLParser_Legacy alloc] initWithXMLData:xmlDataForWebApp];
    STAssertNotNil(self->xmlParserForWebApp, @"Failed to create app xml parser instance");

    NSData *xmlDataForNativeApp = [fileMgr contentsAtPath:nativeAppXMLPath];
    self->xmlParserForNativeApp = [[XAppXMLParser_Legacy alloc] initWithXMLData:xmlDataForNativeApp];
    STAssertNotNil(self->xmlParserForNativeApp, @"Failed to create app xml parser instance");
}

-(void) testParseDescriptionTagForWebApp
{
    [self->xmlParserForWebApp parseDescriptionTag];
    STAssertEqualObjects(@"xapp", self->xmlParserForWebApp.appInfo.type, nil);
    STAssertEqualObjects(@"index.html", self->xmlParserForWebApp.appInfo.entry, nil);
    STAssertEqualObjects(@"icon.png", self->xmlParserForWebApp.appInfo.icon, nil);
    STAssertEqualObjects(@"0xFFFFFFF", self->xmlParserForWebApp.appInfo.iconBgColor, nil);
    STAssertEqualObjects(@"3.0", self->xmlParserForWebApp.appInfo.version, nil);
    STAssertEqualObjects(@"startapp", self->xmlParserForWebApp.appInfo.name, nil);
    STAssertEqualObjects(@"online", self->xmlParserForWebApp.appInfo.runningMode, nil);
    STAssertNil(self->xmlParserForWebApp.appInfo.prefRemotePkg, nil);
    STAssertEqualObjects(@"3.1.0", self->xmlParserForWebApp.appInfo.engineVersion, nil);
}

-(void) testParseAccessTagForWebApp
{
    [self->xmlParserForWebApp parseAccessTag];
    STAssertEquals((NSUInteger)3, [self->xmlParserForWebApp.appInfo.whitelistHosts count], nil);
    STAssertEqualObjects(@"*.baidu.*", self->xmlParserForWebApp.appInfo.whitelistHosts[0], nil);
    STAssertEqualObjects(@"*.google.*", self->xmlParserForWebApp.appInfo.whitelistHosts[1], nil);
    STAssertEqualObjects(@"*", self->xmlParserForWebApp.appInfo.whitelistHosts[2], nil);
}


-(void) testParseDescriptionTagForNativeApp
{
    [self->xmlParserForNativeApp parseDescriptionTag];
    STAssertEqualObjects(@"napp", self->xmlParserForNativeApp.appInfo.type, nil);
    STAssertEqualObjects(@"com.polyvi.xface", self->xmlParserForNativeApp.appInfo.entry, nil);
    STAssertEqualObjects(@"icon.png", self->xmlParserForNativeApp.appInfo.icon, nil);
    STAssertEqualObjects(@"3.0", self->xmlParserForNativeApp.appInfo.version, nil);
    STAssertEqualObjects(@"startapp", self->xmlParserForNativeApp.appInfo.name, nil);
    STAssertNil(self->xmlParserForNativeApp.appInfo.engineType, nil);
    STAssertEqualObjects(@"http://itunes.apple.com/cn/app/xin-tong-jiao-yu-wu-xian/id501656736?mt=8", self->xmlParserForNativeApp.appInfo.prefRemotePkg, nil);
    STAssertEqualObjects(@"409547517", self->xmlParserForNativeApp.appInfo.appleId, nil);
}

-(void) testParseAccessTagForNativeApp
{
    [self->xmlParserForNativeApp parseAccessTag];
    STAssertNotNil(self->xmlParserForNativeApp.appInfo.whitelistHosts, nil);
    STAssertEquals((NSUInteger)1, [self->xmlParserForWebApp.appInfo.whitelistHosts count], nil);
}

@end
