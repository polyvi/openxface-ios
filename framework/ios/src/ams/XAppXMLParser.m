
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
    [self parseAllTag];
    return self.appInfo;
}

#pragma mark - private API

-(void) parseAllTag
{
    APElement *root = [self.doc rootElement];

    self.appInfo.appId = [root valueForAttributeNamed:ATTR_ID];
    self.appInfo.version = [root valueForAttributeNamed:ATTR_VERSION];

    // TODO:由于author,license还未使用，相应的配置信息暂时不解析

    APElement *nameElem = [root firstChildElementNamed:TAG_NAME];
    self.appInfo.name = [nameElem value];

    APElement *entryElem = [root firstChildElementNamed:TAG_CONTENT];
    self.appInfo.entry = [entryElem valueForAttributeNamed:ATTR_SRC];

    APElement *iconElem = [root firstChildElementNamed:TAG_ICON];
    self.appInfo.icon = [iconElem valueForAttributeNamed:ATTR_SRC];
    self.appInfo.iconBgColor = [iconElem valueForAttributeNamed:ATTR_BACKGROUND_COLOR];

    self.appInfo.type = [self valueForPreference:PREFERENCE_TYPE];
    self.appInfo.runningMode = [self valueForPreference:PREFERENCE_MODE];
    self.appInfo.prefRemotePkg  = [self valueForPreference:PREFERENCE_REMOTE_PKG];
    self.appInfo.appleId  = [self valueForPreference:PREFERENCE_APPLE_ID];
}

-(NSString*) valueForPreference:(NSString*)name
{
    APElement *prefElem = [[self.doc rootElement] elementNamed:TAG_PREFERENCE attribute:ATTR_NAME withValue:name];
    return [prefElem valueForAttributeNamed:ATTR_VALUE];
}

@end
