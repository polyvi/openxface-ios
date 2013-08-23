
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
//  XLocalResourceIterator.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import "XResourceIterator.h"
#import "XSecurityResourceFilter.h"

@interface XLocalResourceIterator : NSObject <XResourceIterator>
{
    NSDirectoryEnumerator *dirEnumerator;  /**< 文件目录遍历器*/
    id<XSecurityResourceFilter> filter;    /**< 资源过滤器*/
    NSString* rootPath;                    /**< 应用根目录*/
}

/**
    初始化函数
    @param root 应用的根目录
    @returns 返回应用资源的迭代器的实例
 */
- (id)initWithAppRoot:(NSString*)root;

@end
