
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
//  XILog.h
//  xFace
//
//
#import <Foundation/Foundation.h>

//定义Log的接口
@protocol XILog

/**
    以VERBOSE类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
-(void) logV:(NSString*)tag msg:(NSString*)msg;

/**
    以DEBUG类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
-(void) logD:(NSString*)tag msg:(NSString*)msg;

/**
    以INFO类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
-(void) logI:(NSString*)tag msg:(NSString*)msg;

/**
    以WARN类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
-(void) logW:(NSString*)tag msg:(NSString*)msg;

/**
    以ERROR类型输出log
    @param tag log信息的tag名称
    @param msg 需要输出的log信息
 */
-(void) logE:(NSString*)tag msg:(NSString*)msg;

/**
    关闭log
 */
-(void) close;

@end
