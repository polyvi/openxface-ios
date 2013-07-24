
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
//  XAppXMLParser_Legacy.h
//  xFaceLib
//
//

#import "XAppXMLParser.h"

/**
    解析含schema标签的1.0版本的app.xml的类,
    有新版本可直接继承该类。
 */
@interface XAppXMLParser_Legacy : XAppXMLParser
{
}

/**
    app.xml 解析的工作
    @returns 返回保存了xml中解析出来的appInfo
 */
-(XAppInfo*) parseAppXML;

/**
    解析app标签
 */
-(void) parseAppTag;

/**
    解析Description标签
 */
-(void) parseDescriptionTag;

@end
