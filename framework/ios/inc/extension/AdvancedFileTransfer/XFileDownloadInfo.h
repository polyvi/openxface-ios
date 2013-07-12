
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
//  XFileDownloadInfo.h
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import <Foundation/Foundation.h>

/**
    纪录下载的具体信息
 */
@interface XFileDownloadInfo : NSObject

/**
    下载地址
 */
@property (strong, nonatomic) NSString *url;

/**
    要下载文件的总大小
 */
@property (nonatomic) NSInteger totalSize;

/**
    已下载的大小
 */
@property (nonatomic) NSInteger completeSize;

/**
    初始化XFileDownloadInfo对象.
    @param aUrl          下载地址
    @param aTotalSize    要下载文件的总大小
    @param aCompleteSize 已下载的大小
    @return 初始化后的XFileDownloadInfo对象，如果初始化失败，则返回nil
 */
- (id) initWithURL:(NSString *)aUrl andTotalSize:(NSInteger)aTotalSize andCompleteSize:(NSInteger)aCompleteSize;

@end

#endif
