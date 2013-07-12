
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
//  XZipArchiveExt.h
//  xFaceLib
//
//

#ifdef __XZipArchiveExt__

#import "XExtension.h"

@interface XZipArchiveExt : XExtension

/**
    实现对指定路径下的文件和文件夹进行压缩,通过回调返回压缩后的结果.
    @param arguments
    - 0 XJsCallback* callback
    - 1 filePath 待压缩的文件的路径
    - 2 dstfilePatn 压缩到指定路径（如果为空则压缩到当前目录）
    @param options 可选参数
    - 0 password 压缩文件使用密码
 */
- (void) zip:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    实现对指定路径下的多个文件和文件夹进行压缩,通过回调返回压缩后的结果.
    @param arguments
    - 0 XJsCallback* callback
    - 1 srcEntries 待压缩的源文件的路径数组（多个文件或者文件夹）
    - 2 dstZipFile 压缩到指定路径（如果为空则压缩到workspace）
    @param options 可选参数
    - 0 password 压缩文件使用密码
 */
- (void) zipFiles:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    实现对指定路径下的zip文件进行解压解压到指定路径,通过回调返回解压后的结果.
    @param arguments
    - 0 XJsCallback* callback
    - 1 zipFilePath 待解压的zip文件路径
    - 2 dstfilePatn 解压到指定路径（如果为空则解压到当前目录）
    @param options 可选参数
    - 0 password 解压文件使用密码
 */
- (void) unzip:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
