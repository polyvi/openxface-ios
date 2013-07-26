
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
//  XAppXMLParserLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppXMLParser.h"
#import "APDocument+XAPDocument.h"
#import "XAPElement.h"
#import "XAppInfo.h"
#import "XAppXMLTagDefine.h"

@interface XAppXMLParserLogicTests : SenTestCase
{
    @private
    XAppXMLParser* xmlParserForWebApp;
    XAppXMLParser* xmlParserForNativeApp;
}

@end
@implementation XAppXMLParserLogicTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* webAppXMLPath = [bundle pathForResource:@"w3cWebapp.xml" ofType:nil];
    NSString* nativeAppXMLPath = [bundle pathForResource:@"w3cNativeApp.xml" ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlDataForWebApp = [fileMgr contentsAtPath:webAppXMLPath];
    self->xmlParserForWebApp = [[XAppXMLParser alloc] initWithXMLData:xmlDataForWebApp];
    STAssertNotNil(self->xmlParserForWebApp, @"Failed to create app xml parser instance");

    NSData *xmlDataForNativeApp = [fileMgr contentsAtPath:nativeAppXMLPath];
    self->xmlParserForNativeApp = [[XAppXMLParser alloc] initWithXMLData:xmlDataForNativeApp];
    STAssertNotNil(self->xmlParserForNativeApp, @"Failed to create app xml parser instance");
}

-(void) testParseWebAppXML
{
    XAppInfo* appInfo = [self->xmlParserForWebApp parseAppXML];

    STAssertEqualObjects(@"myappid", appInfo.appId, nil);
    STAssertEqualObjects(@"xapp", appInfo.type, nil);

    STAssertEqualObjects(@"index.html", appInfo.entry, nil);
    STAssertEqualObjects(@"icon.png", appInfo.icon, nil);
    STAssertEqualObjects(@"2.0", appInfo.version, nil);
    STAssertEqualObjects(@"myphone",appInfo.name, nil);
    STAssertEqualObjects(@"online",appInfo.runningMode, nil);
}

-(void) testParseNativeAppXML
{
    XAppInfo* appInfo = [self->xmlParserForNativeApp parseAppXML];

    STAssertEqualObjects(@"napp", appInfo.type, nil);
    STAssertEqualObjects(@"com.polyvi.xface", appInfo.entry, nil);
    STAssertEqualObjects(@"icon.png", appInfo.icon, nil);
    STAssertEqualObjects(@"2.0", appInfo.version, nil);
    STAssertEqualObjects(@"myphone", appInfo.name, nil);
    STAssertEqualObjects(@"http://itunes.apple.com/cn/app/xin-tong-jiao-yu-wu-xian/id501656736?mt=8", appInfo.prefRemotePkg, nil);
    STAssertEqualObjects(@"409547517", appInfo.appleId, nil);
}

-(void) testParseXMLWithNilData
{
    XAppXMLParser* xmlParser;
    STAssertNoThrow((xmlParser = [[XAppXMLParser alloc] initWithXMLData:nil]), nil);

    XAppInfo* appInfo;
    STAssertNoThrow((appInfo = [xmlParser parseAppXML]), nil);

    STAssertNil(appInfo.type, nil);
    STAssertEqualObjects(@"index.html", appInfo.entry, nil);
    STAssertNil(appInfo.icon, nil);
    STAssertNil(appInfo.version, nil);
    STAssertNil(appInfo.name, nil);
    STAssertNil(appInfo.prefRemotePkg, nil);
    STAssertNil(appInfo.appleId, nil);
}


-(void) testParseXMLWithWrongData
{
    XAppXMLParser* xmlParser;
    NSString* xmlString =
    @"<widget id='myappid' version='2.0'>\
    <name short='myphone'>myphone</name>\
    <icon src='icon.png'/\
    <content src='index.html' encoding='UTF-8'/>\
    </widget>";
    NSData* xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    STAssertNoThrow((xmlParser = [[XAppXMLParser alloc] initWithXMLData:xmlData]), nil);

    XAppInfo* appInfo;
    STAssertNoThrow((appInfo = [xmlParser parseAppXML]), nil);

    STAssertNotNil(appInfo.appId, nil);
    STAssertEqualObjects(@"index.html", appInfo.entry, nil);
    STAssertNotNil(appInfo.version, nil);
    STAssertNotNil(appInfo.name, nil);
    STAssertNil(appInfo.icon, nil);
    STAssertNil(appInfo.prefRemotePkg, nil);
    STAssertNil(appInfo.appleId, nil);
}

@end
