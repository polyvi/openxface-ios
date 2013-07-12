
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
//  XFileDownloadListener.h
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import <Foundation/Foundation.h>

/**
    负责文件下载的状态通知
 */
@protocol XFileDownloadListener <NSObject>

/**
    更新下载进度
    @param aTotalSize 文件的总大小
    @param data       本次下载到的数据
 */
- (void) onProgressUpdated:(NSInteger) aTotalSize withData:(NSData *) data;

/**
    下载成功
 */
- (void) onSuccess;

/**
    下载失败
 */
- (void) onError;

@end

#endif
