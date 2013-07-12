
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
//  XFileDownloadInfoRecorder.h
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import <Foundation/Foundation.h>
#import "XAPElement.h"

@protocol XApplication;

@class XFileDownloadInfo;

/**
    提供操作配置文件的方法
 */
@interface XFileDownloadInfoRecorder : NSObject
{
    APDocument *document;             /**< 系统配置文件解析后对应的document */
    NSString   *configFilePath;       /**< 系统配置文件所在得路径 */
}

/**
    初始化XFileDownloadInfoRecorder对象.
    @param app 当前应用
    @return 初始化后的XFileDownloadInfoRecorder对象，如果初始化失败，则返回nil
 */
- (id) initWithApp:(id<XApplication>)app;

/**
    查看配置文件中是否有等于url的纪录.
    @param url 要查找的路径
    @return 有该纪录返回YES，没有返回NO
 */
- (BOOL) hasInfo:(NSString *)url;

/**
    保存下载的具体信息.
    @param downloadInfo 要存储的下载信息，包括文件所在服务器的路径，文件的大小和已下载的大小
    @return
 */
- (void) saveDownloadInfo:(XFileDownloadInfo *) downloadInfo;

/**
    得到下载的具体信息.
    @param url 要获取纪录的关键字
    @return 获取到的下载信息
 */
- (XFileDownloadInfo *) getDownloadInfo:(NSString *)url;

/**
    更新下载的具体信息.
    @param completeSize 已下载的大小
    @param url          要更新的记录项
    @return
 */
- (void) updateDownloadInfo:(NSInteger)completeSize withUrl:(NSString *)url;

/**
    设置下载文件的总大小.
    @param totalSize 文件的总大小
    @param url       要设置的记录项
    @return
 */
- (void) setTotalSize:(NSInteger)totalSize withUrl:(NSString *)url;

/**
    删除下载的具体信息.
    @param url          要删除的记录项
    @return
 */
- (void) deleteDownloadInfo:(NSString *)url;

@end

#endif
