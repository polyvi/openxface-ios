
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
//  XAppXMLParser.m
//  xFaceLib
//
//

#import "XAppXMLParser.h"
#import "APDocument+XAPDocument.h"
#import "APXML.h"
#import "XAPElement.h"
#import "XAppInfo.h"
#import "XAppXMLTagDefine.h"

@implementation XAppXMLParser

@synthesize appInfo;
@synthesize doc;

-(id) initWithXMLData:(NSData *)xmlData
{
    self = [super init];
    if (self)
    {
        self.appInfo = [[XAppInfo alloc] init];
        NSString *xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        self.doc = [APDocument documentWithXMLString:xmlStr];
    }
    return self;
}

//app.xml 解析的公共入口空实现,子类实现
-(XAppInfo*) parseAppXML
{
    [self parseAppTag];
    [self parseDescriptionTag];
    [self parseExtensionsTag];

    if (NO == [self checkTagVerify]) {
        return nil;
    }
    return self.appInfo;
}

//空实现,子类实现
-(void) parseAppTag
{
}

//空实现,子类实现
-(void) parseDescriptionTag
{
}

//空实现,子类实现
-(void) parseExtensionsTag
{
}

//解析app元素标签，以及子节点的属性和值
-(void) parseAppElement:(APElement*)appElement
{
    self.appInfo.appId = [appElement valueForAttributeNamed:ATTR_ID];
}

-(BOOL) checkTagVerify
{
    // check appID
    if (nil == self.appInfo.appId) {
        return NO;
    }
    return YES;
}

@end
