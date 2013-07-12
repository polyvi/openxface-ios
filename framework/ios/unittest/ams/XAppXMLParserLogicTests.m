
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
    XAppXMLParser *appXMLParser;
}

@end
@implementation XAppXMLParserLogicTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* appXMLPath = [bundle pathForResource:@"app.xml" ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlData = [fileMgr contentsAtPath:appXMLPath];
    self->appXMLParser = [[XAppXMLParser alloc] initWithXMLData:xmlData];

    STAssertNotNil(self->appXMLParser, @"Failed to create device extension instance");
}

-(void) testParseAppElement
{
    APElement* appElement = [appXMLParser.doc rootElement];
    [self->appXMLParser parseAppElement:appElement];
    //测试取出来的appId 等于预期结果
    NSString* appId = @"storage";

    STAssertEqualObjects(appId,appXMLParser.appInfo.appId, @"parseAppElement error");
}

@end
