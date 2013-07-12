
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
//  XAppXMLParserNoSchema.m
//  xFaceLib
//
//

#import "XAppXMLParserNoSchema.h"
#import "APDocument+XAPDocument.h"
#import "APXML.h"
#import "XAPElement.h"
#import "XAppInfo.h"
#import "XAppXMLTagDefine.h"

@implementation XAppXMLParserNoSchema

//解析app元素标签，以及子节点的属性和值
-(void) parseAppTag
{
    APElement *appElement = [self.doc rootElement];
    //调用父类的解析方法，得到appId
    [super parseAppElement:appElement];

    self.appInfo.version = [appElement valueForAttributeNamed:ATTR_VERSION];
    self.appInfo.width = [[appElement valueForAttributeNamed:ATTR_WIDTH] intValue];
    self.appInfo.height = [[appElement valueForAttributeNamed:ATTR_HEIGHT] intValue];
    self.appInfo.isEncrypted = [[appElement valueForAttributeNamed:ATTR_IS_ENCRYPTED] boolValue];
}

//解析Description元素标签，以及子节点的属性和值
-(void) parseDescriptionTag
{
    // FIXME:由于author,license还未使用，相应的配置信息暂时不解析

    APElement *appElement = [self.doc rootElement];
    APElement *descriptionElement = [appElement firstChildElementNamed:TAG_DESCRIPTION];

    APElement *nameElem = [descriptionElement firstChildElementNamed:TAG_NAME];
    self.appInfo.name = [nameElem value];

    APElement *entryElem = [descriptionElement firstChildElementNamed:TAG_ENTRY];
    self.appInfo.entry = [entryElem valueForAttributeNamed:ATTR_SRC];

    APElement *iconElem = [descriptionElement firstChildElementNamed:TAG_ICON];
    self.appInfo.icon = [iconElem valueForAttributeNamed:ATTR_SRC];
    self.appInfo.iconBgColor = [iconElem valueForAttributeNamed:ATTR_BACKGROUND_COLOR];

    APElement *typeElem = [descriptionElement firstChildElementNamed:TAG_TYPE];
    self.appInfo.type = [typeElem valueForAttributeNamed:ATTR_VALUE];

    APElement *runningModeElem = [descriptionElement firstChildElementNamed:TAG_RUNNING_MODE];
    self.appInfo.runningMode = [runningModeElem valueForAttributeNamed:ATTR_VALUE];
}

@end
