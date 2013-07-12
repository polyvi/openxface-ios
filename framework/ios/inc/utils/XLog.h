
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
//  XLog.h
//  xFace
//
//

#ifdef DEBUG
#define XLOG_LEVEL 1
#else
#define XLOG_LEVEL 5
#endif

#define XLOG_LEVEL_V 1
#define XLOG_LEVEL_D 2
#define XLOG_LEVEL_I 3
#define XLOG_LEVEL_W 4
#define XLOG_LEVEL_E 5

#if XLOG_LEVEL_V >= XLOG_LEVEL
#define XLogV(...) \
do{\
NSString* s = [NSString stringWithFormat:__VA_ARGS__];\
[XLog logV:NSStringFromClass([self class]) msg:s];\
}while(0)
#else
#define XLogV(...)
#endif

#if XLOG_LEVEL_D >= XLOG_LEVEL
#define XLogD(...) \
do{\
NSString* s = [NSString stringWithFormat:__VA_ARGS__];\
[XLog logD:NSStringFromClass([self class]) msg:s];\
}while(0)
#else
#define XLogD(...)
#endif

#if XLOG_LEVEL_I >= XLOG_LEVEL
#define XLogI(...) \
do{\
NSString* s = [NSString stringWithFormat:__VA_ARGS__];\
[XLog logI:NSStringFromClass([self class]) msg:s];\
}while(0)
#else
#define XLogI(...)
#endif

#if XLOG_LEVEL_W >= XLOG_LEVEL
#define XLogW(...) \
do{\
NSString* s = [NSString stringWithFormat:__VA_ARGS__];\
[XLog logW:NSStringFromClass([self class]) msg:s];\
}while(0)
#else
#define XLogW(...)
#endif

#if XLOG_LEVEL_E >= XLOG_LEVEL
#define XLogE(...) \
do{\
NSString* s = [NSString stringWithFormat:__VA_ARGS__];\
[XLog logE:NSStringFromClass([self class]) msg:s];\
}while(0)
#else
#define XLogE(...)
#endif

//该类用于XLog重定向
@interface XLog : NSObject

/**
    以VERBOSE类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
+(void) logV:(NSString*)tag msg:(NSString*)msg;

/**
    以DEBUG类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
+(void) logD:(NSString*)tag msg:(NSString*)msg;

/**
    以INFO类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
+(void) logI:(NSString*)tag msg:(NSString*)msg;

/**
    以WARN类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
+(void) logW:(NSString*)tag msg:(NSString*)msg;

/**
    以ERROR类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
+(void) logE:(NSString*)tag msg:(NSString*)msg;

/**
    关闭log
 */
+(void) close;

@end
