
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
//  XAppXMLParser_Legacy.m
//  xFaceLib
//
//

#import "XAppXMLParser_Legacy.h"
#import "APDocument+XAPDocument.h"
#import "APXML.h"
#import "XAPElement.h"
#import "XAppInfo.h"
#import "XAppXMLTagDefine.h"
#import "XAPElement.h"
#import "XAppXMLParser_Legacy_Privates.h"

@implementation XAppXMLParser_Legacy

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

//app.xml 解析的工作
-(XAppInfo*) parseAppXML
{
    [self parseAppTag];
    [self parseDescriptionTag];
    [self parseAccessTag];
    return self.appInfo;
}

-(void) parseAppTag
{
    APElement *rootElem = [self.doc rootElement];
    APElement *appElem = [rootElem firstChildElementNamed:TAG_APP];
    self.appInfo.appId = [appElem valueForAttributeNamed:ATTR_ID];
}

//解析description元素标签，以及子节点的属性和值
-(void) parseDescriptionTag
{
    APElement *descriptionElement = [[self getAppTagElement] firstChildElementNamed:TAG_DESCRIPTION];
    APElement *typeElem = [descriptionElement firstChildElementNamed:TAG_TYPE];
    self.appInfo.type = [typeElem value];

    APElement *entryElem = [descriptionElement firstChildElementNamed:TAG_ENTRY];
    self.appInfo.entry = [entryElem valueForAttributeNamed:ATTR_SRC];

    APElement *iconElem = [descriptionElement firstChildElementNamed:TAG_ICON];
    self.appInfo.icon = [iconElem valueForAttributeNamed:ATTR_SRC];
    self.appInfo.iconBgColor = [iconElem valueForAttributeNamed:ATTR_BACKGROUND_COLOR];

    APElement *versionElem = [descriptionElement firstChildElementNamed:TAG_VERSION];
    self.appInfo.version = [versionElem value];

    APElement *nameElem = [descriptionElement firstChildElementNamed:TAG_NAME];
    self.appInfo.name = [nameElem value];

    APElement *runningModeElem = [descriptionElement firstChildElementNamed:TAG_RUNNING_MODE];
    self.appInfo.runningMode = [runningModeElem valueForAttributeNamed:ATTR_VALUE];

    self.appInfo.prefRemotePkg  = [self valueForPreference:PREFERENCE_REMOTE_PKG];
    self.appInfo.appleId  = [self valueForPreference:PREFERENCE_APPLE_ID];
}

-(void) parseAccessTag
{
    NSMutableArray *accessElems = [[self getAppTagElement] childElements:TAG_ACCESS];
    NSMutableArray *whitelistHosts = [[NSMutableArray alloc] initWithCapacity:[accessElems count]];
    for (APElement *elem in accessElems)
    {
        //FIXME:目前仅支持origin属性
        [whitelistHosts addObject:[elem valueForAttributeNamed:ATTR_ORIGIN]];
    }
    [self.appInfo setWhitelistHosts:whitelistHosts];
}

-(APElement*) getAppTagElement
{
    APElement *rootElem = [self.doc rootElement];
    APElement *appElem = [rootElem firstChildElementNamed:TAG_APP];
    return appElem;
}

-(void) parseCopyRightElement:(APElement *)copyrightElement
{
    // TODO:由于author,license还未使用，相应的配置信息暂时不解析
}

-(NSString*) valueForPreference:(NSString*)name
{
    APElement *descriptionElement = [[self getAppTagElement] firstChildElementNamed:TAG_DESCRIPTION];
    APElement *prefElem = [descriptionElement elementNamed:TAG_PREFERENCE attribute:ATTR_NAME withValue:name];
    return [prefElem valueForAttributeNamed:ATTR_VALUE];
}

@end
