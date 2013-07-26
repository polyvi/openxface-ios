
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
//  XAppXMLParserFactoryLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppXMLParserFactory.h"
#import "XAppXMLParserFactory_Privates.h"
#import "XAppXMLParser.h"
#import "XAppXMLParser_Legacy.h"

@interface XAppXMLParserFactoryLogicTests : SenTestCase
{
}

@end
@implementation XAppXMLParserFactoryLogicTests

-(void) testGetSchemaValue
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* appXMLPath = [bundle pathForResource:@"appschema.xml" ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlData = [fileMgr contentsAtPath:appXMLPath];
    NSString* value = [XAppXMLParserFactory getSchemaValueFromXMLData:xmlData];
    STAssertEqualObjects(@"1.0", value, nil);
}

-(void) testCreateAppXMLParser
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* appXMLPath = [bundle pathForResource:@"appschema.xml" ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlData = [fileMgr contentsAtPath:appXMLPath];
    id<XAppXMLParser> parser = [XAppXMLParserFactory createAppXMLParserWithXMLData:xmlData];
    STAssertNotNil(parser, nil);
    STAssertTrue([parser isKindOfClass:[XAppXMLParser_Legacy class]], nil);

    appXMLPath = [bundle pathForResource:@"w3cWebapp.xml" ofType:nil];
    xmlData = [fileMgr contentsAtPath:appXMLPath];
    parser = [XAppXMLParserFactory createAppXMLParserWithXMLData:xmlData];
    STAssertNotNil(parser, nil);
    STAssertTrue([parser isKindOfClass:[XAppXMLParser class]], nil);

}

@end
