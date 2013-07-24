
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

//app.xml 解析的工作
-(XAppInfo*) parseAppXML
{
    [super parseAppXML];
    [self parseDistributionTag];
    [self parseAccessTag];

    if (NO == [self checkTagVerify]) {
        return nil;
    }
    return self.appInfo;
}

//解析app元素标签，以及子节点的属性和值
-(void) parseAppTag
{
    [super parseAppElement:[self getAppTagElement]];
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

    APElement *displayElem = [descriptionElement firstChildElementNamed:TAG_DISPLAY];
    [self parseDisplayElement:displayElem];

    APElement *runtimeElem = [descriptionElement firstChildElementNamed:TAG_RUN_TIME];
    self.appInfo.engineType = [runtimeElem value];

    APElement *copyrightElem = [descriptionElement firstChildElementNamed:TAG_COPY_RIGHT];
    [self parseCopyRightElement:copyrightElem];

    APElement *runningModeElem = [descriptionElement firstChildElementNamed:TAG_RUNNING_MODE];
    self.appInfo.runningMode = [runningModeElem valueForAttributeNamed:ATTR_VALUE];

    APElement *prefRemotePkgElem = [descriptionElement elementNamed:TAG_PREFERENCE attribute:ATTR_NAME withValue:ATTR_VALUE_REMOTE_PKG];
    self.appInfo.prefRemotePkg = [prefRemotePkgElem valueForAttributeNamed:ATTR_VALUE];

    APElement *prefAppleIdElem = [descriptionElement elementNamed:TAG_PREFERENCE attribute:ATTR_NAME withValue:ATTR_VALUE_APPLE_ID];
    self.appInfo.appleId = [prefAppleIdElem valueForAttributeNamed:ATTR_VALUE];
}

//解析distribution元素标签，以及子节点的属性和值
-(void) parseDistributionTag
{
    APElement *distributionElement = [[self getAppTagElement] firstChildElementNamed:TAG_DISTRIBUTION];

    APElement *packageElem = [distributionElement firstChildElementNamed:TAG_PACKAGE];
    [self parsePackageElement:packageElem];

    APElement *channelElem = [distributionElement firstChildElementNamed:TAG_CHANNEL];
    [self parseChannelElement:channelElem];
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

//解析display元素标签
-(void) parseDisplayElement:(APElement*)displayElement
{
    self.appInfo.displayMode = [displayElement valueForAttributeNamed:ATTR_TYPE];

    APElement *widthElem = [displayElement firstChildElementNamed:TAG_WIDTH];
    self.appInfo.width = [[widthElem value] intValue];

    APElement *heightElem = [displayElement firstChildElementNamed:TAG_HEIGHT];
    self.appInfo.height = [[heightElem value] intValue];
}

-(void) parseCopyRightElement:(APElement *)copyrightElement
{
    // FIXME:由于author,license还未使用，相应的配置信息暂时不解析
}

//解析package元素标签
-(void) parsePackageElement:(APElement*)packageElement
{
    APElement *encryptElem = [packageElement firstChildElementNamed:TAG_ENCRYPT];
    self.appInfo.isEncrypted = [[encryptElem value] boolValue];
}

//解析channel元素标签
-(void) parseChannelElement:(APElement*)channelElement
{
    self.appInfo.channelId = [channelElement valueForAttributeNamed:ATTR_ID];

    APElement *nameElem = [channelElement firstChildElementNamed:TAG_NAME];
    self.appInfo.channelName = [nameElem value];
}

-(BOOL) checkTagVerify
{
    if (NO == [super checkTagVerify]) {
        return NO;
    }
    // TODO:check scheme 1.0 tag
    return YES;
}

@end
