
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
//  XAppXMLParser.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

@class APDocument;
@class XAppInfo;
@class APElement;

/**
    app.xml解析的基类,解析app.xml保存到appInfo
    供解析具体版本的app.xml的类继承
 */
@interface XAppXMLParser : NSObject
{
}

/**
    记录应用相关信息的对象.
    此对象中的数据来源于应用配置文件.
 */
@property (strong, nonatomic) XAppInfo *appInfo;

/**
    保存app.xml文档的APDocument对象
 */
@property (strong, nonatomic) APDocument *doc;

/**
    初始化方法
    @param xmlData xml文本的数据
    @returns 成功返回XAppXMLParser对象，否则返回nil
 */
-(id) initWithXMLData:(NSData *)xmlData;

/**
    app.xml 解析的公共入口由子类实现
    @returns 返回保存了xml中解析出来的appInfo
 */
-(XAppInfo*) parseAppXML;

/**
    解析app元素标签，以及子节点的属性和值
    @param appElement 含app标签的APElement对象
 */
-(void) parseAppElement:(APElement*)appElement;

/**
    解析app标签
 */
-(void) parseAppTag;

/**
    解析Description标签
 */
-(void) parseDescriptionTag;

/**
    解析Extensions标签
 */
-(void) parseExtensionsTag;

/**
 检查关键标签合法性
 */
-(BOOL) checkTagVerify;

@end
