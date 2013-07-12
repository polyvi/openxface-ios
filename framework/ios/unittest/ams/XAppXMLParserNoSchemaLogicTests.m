
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
//  XAppXMLParserNoSchemaLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppXMLParserNoSchema.h"
#import "APDocument+XAPDocument.h"
#import "XAppInfo.h"

@interface XAppXMLParserNoSchemaLogicTests : SenTestCase
{
    @private
    XAppXMLParserNoSchema* appXMLParser;
}

@end
@implementation XAppXMLParserNoSchemaLogicTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* appXMLPath = [bundle pathForResource:@"app.xml" ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlData = [fileMgr contentsAtPath:appXMLPath];
    self->appXMLParser = [[XAppXMLParserNoSchema alloc] initWithXMLData:xmlData];

    STAssertNotNil(self->appXMLParser, @"Failed to create device extension instance");
}

-(void) testParseAppTag
{
    [appXMLParser parseAppTag];

    STAssertEqualObjects(@"1.2", appXMLParser.appInfo.version, nil);
    STAssertEquals(480, appXMLParser.appInfo.width, nil);
    STAssertEquals(640, appXMLParser.appInfo.height, nil);
    STAssertFalse(appXMLParser.appInfo.isEncrypted, nil);
}

-(void) testParseDescriptionTag
{
    [appXMLParser parseDescriptionTag];

    STAssertEqualObjects(@"xapp", appXMLParser.appInfo.type, nil);
    STAssertEqualObjects(@"index.html", appXMLParser.appInfo.entry, nil);
    STAssertEqualObjects(@"", appXMLParser.appInfo.icon, nil);
    STAssertEqualObjects(@"中国银联", appXMLParser.appInfo.name, nil);
}

@end
