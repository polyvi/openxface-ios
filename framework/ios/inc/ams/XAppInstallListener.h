
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
//  XAppInstallListener.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XInstallListener.h"

@class XMessenger;
@class XJavaScriptEvaluator;
@class XJsCallback;

/**
	app安装监听器，负责监听app的安装、卸载进度
 */
@interface XAppInstallListener : NSObject <XInstallListener>
{
    XMessenger           *messenger;       /**< 用于发送消息给 message handler */
    XJavaScriptEvaluator *jsEvaluator;     /**< js语句执行者，即消息处理者 */
    XJsCallback          *jsCallback;      /**< js回调对象,js端通过此对象找到相应的回调函数 */
}

/**
	初始化方法
	@param msger 用于发送消息给message handler
	@param msgHandler 消息处理者
	@param callback js回调对象,js端通过此对象找到相应的回调函数
	@returns 初始化后的XAppInstallListener对象，如果初始化失败，则返回nil
 */
- (id)initWithMessenger:(XMessenger *)msger messageHandler:(XJavaScriptEvaluator *)msgHandler callback:(XJsCallback *)callback;

@end
