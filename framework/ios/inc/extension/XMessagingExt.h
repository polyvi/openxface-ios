
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
//  XMessagingExt.h
//  xFaceLib
//
//

#ifdef __XMessagingExt__

#import "XExtension.h"
#import <MessageUI/MessageUI.h>

@interface XMessagingExt : XExtension<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

/**
    发送信息（目前支持发送短信和邮件）
    @param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* 信息的类型（目前支持SMS和Email两种）
        - 2 NSString* 要发送的目的地址
        - 3 NSString* 要发送的信息内容
        - 4 NSString* 要发送的信息标题(发送邮件时会使用)
    @param options 可选参数
 */
- (void) sendMessage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
