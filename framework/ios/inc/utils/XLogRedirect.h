
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
//  XLogRedirect.h
//  xFace
//
//
#import "XILog.h"

//该类用于XLog重定向，发送log到指定的服务器
@interface XLogRedirect : NSObject <XILog, NSStreamDelegate>
{
    NSInputStream *inputStream;        /** 用于绑定到Socket */
    NSOutputStream *outputStream;      /** 用于绑定到Socket */
    NSMutableData* dataBuf;            /** 用于缓存log数据*/
}

/**
    获取XLogRedirect唯一实例
    @returns 获取到的XLogRedirect实例
 */
+ (XLogRedirect *) getInstance;
@end
