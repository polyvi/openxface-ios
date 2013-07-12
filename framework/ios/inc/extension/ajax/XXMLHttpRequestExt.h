
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
//  XXMLHttpRequestExt.h
//  xFaceLib
//
//
#ifdef __XXMLHttpRequestExt__

#import "XExtension.h"
@class XMutableURLRequest;

@interface XXMLHttpRequestExt : XExtension 
{
    NSMutableDictionary* _requests;
}

/*
    打开ajax请求
    @param arguments
    - 0 id     ajax的标识符
    - 1 method 操作类型，post或者get
    - 2 url    链接地址
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)open:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    发送ajax请求
    @param arguments
    - 0 id     ajax的标识符
    - 1 data   待发送的数据
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)send:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    设置http头部
    @param arguments
    - 0 id       ajax的标识符
    - 1 field    数据域
    - 2 value    数据域的新值
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)setRequestHeader:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/*
    停止请求
    @param arguments
    - 0 id       ajax的标识符
    @param options
    - 0 XJsCallback  *callback  js回调对象
    - 1 id<XApplication> app     关联的app
 */
- (void)abort:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
#endif
