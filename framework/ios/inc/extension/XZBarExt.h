
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
//  XZBarExt.h
//  xFaceLib
//
//
#ifdef __XZBarExt__

#import <Foundation/Foundation.h>
#import "XExtension.h"
#import "ZBarSDK.h"

@interface XZBarExt : XExtension <ZBarReaderDelegate>

/**
    初始化方法
    @param msgHandler 消息处理者
    @returns 初始化后的BarcodeScanner扩展对象，如果初始化失败，则返回nil
 */
- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler;

/**
    启动条形码扫描器
    @param arguments 参数列表
    - 0 XJsCallback* callback
    @param options 可选参数(本接口未使用)
 */
- (void) start:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
