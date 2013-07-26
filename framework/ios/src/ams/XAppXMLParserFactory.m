
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
//  XAppXMLParserFactory.m
//  xFaceLib
//
//

#import "XAppXMLParserFactory.h"
#import "APDocument+XAPDocument.h"
#import "APXML.h"
#import "XAPElement.h"
#import "XAppXMLParser.h"
#import "XAppXMLParser_Legacy.h"
#import "XAppInfo.h"
#import "XAppXMLParserFactory_Privates.h"

#define  ATTR_SCHEMA        @"schema"
#define  SCHEMA_1_0         @"1.0"

@implementation XAppXMLParserFactory

//获取schema标签的值 区分是哪个版本的app.xml
+(NSString*) getSchemaValueFromXMLData:(NSData*) xmlData
{
    NSString* value = nil;
    NSString *xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    APElement *rootElem = [[APDocument documentWithXMLString:xmlStr] rootElement];
    value = [rootElem valueForAttributeNamed:ATTR_SCHEMA];
    return value;
}

//判断，选择解析appxml 的对象
+(id<XAppXMLParser>) createAppXMLParserWithXMLData:(NSData *)xmlData
{
    NSString* schemaValue = [self getSchemaValueFromXMLData:xmlData];
    if ([schemaValue isEqualToString:SCHEMA_1_0])
    {
        //返回解析含schema标签的对象
        return [[XAppXMLParser_Legacy alloc] initWithXMLData:xmlData];
    }
    else if(nil == schemaValue)
    {
        // 返回新版本的parser
        return [[XAppXMLParser alloc] initWithXMLData:xmlData];
    }
    else
    {
        // FIXME:存在其他版本的app.xml相应在此添加
        return nil;
    }
}

@end
