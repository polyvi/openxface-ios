
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
//  XAppXMLParserFactory_Privates.h
//  xFaceLib
//
//

#import "XAppXMLParserFactory.h"

@interface XAppXMLParserFactory ()

/**
    获取schema标签的值 区分是哪个版本的app.xml
    @param xmlData xml文本的数据
    @returns 返回schema标签的属性值
 */
+(NSString*) getSchemaValueFromXMLData:(NSData*) xmlData;

@end
