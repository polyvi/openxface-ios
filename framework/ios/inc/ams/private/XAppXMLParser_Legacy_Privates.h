
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
//  XAppXMLParserSchema1_0_Privates.h
//  xFaceLib
//
//

#import "XAppXMLParser_Legacy.h"

@interface XAppXMLParser_Legacy ()

/**
    解析access标签
 */
-(void) parseAccessTag;

/**
    获取appTag的APElement对象
    @returns 返回APElement对象
 */
-(APElement*) getAppTagElement;

/**
    解析copyright元素标签
    @param copyrightElement 含copyright元素标签的APElement对象
 */
-(void) parseCopyRightElement:(APElement *)copyrightElement;

@end
