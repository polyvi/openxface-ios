
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
//  XFileDownloader.h
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import <Foundation/Foundation.h>
#import "XFileDownloadListener.h"
#import "XFileDownloadInfo.h"
#import "XFileDownloadInfoRecorder.h"
#import "XMessenger.h"
#import "XFileDownloaderManager.h"

#define TEMP_FILE_SUFFIX @".temp"

@protocol XApplication;

@class XJsCallback;

enum XDownloadState
{
    INIT = 1,           /**< 初始状态 */
    DOWNLOADING = 2,    /**< 正在下载 */
    PAUSE = 3           /**< 暂停下载 */
};
typedef int XDownloadState;

/** 该类表示下载器，该类实现了XFileDownloadListener接口,
 *  每当用户发起下载请求时会为每一个url创建一个下载器，具体的下载任务交给XFileDownloaderDelegete */
@interface XFileDownloader : NSObject<XFileDownloadListener>
{
    XMessenger                *messenger;           /**< 用于发送消息给 message handler */
    XJavaScriptEvaluator      *jsEvaluator;         /**< js语句执行者，即消息处理者 */
    id<XApplication>           app;                 /**< 关联的应用 */
    XFileDownloadInfoRecorder *downloadInfoRecorder;/**< 操作配置文件的对象 */
    XFileDownloaderManager    *downloaderManager;   /**< 下载器管理者 */
    XFileDownloadInfo         *downloadInfo;        /**< 下载的具体信息 */
    XJsCallback               *jsCallback;          /**< js回调,js端通过此id找到相应的回调函数 */
    NSURLConnection           *connection;          /**< 网络连接对象 */
    NSString                  *url;                 /**< 下载地址 */
    NSString                  *localFilePath;       /**< 存储下载文件的地址 */
    NSInteger                  completeSize;        /**< 已下载的大小 */
    NSInteger                  totalSize;           /**< 文件的总大小 */
    NSInteger                  state;               /**< 下载状态 */

}

/**
    初始化XFileDownloader对象.
    @param msger        用于发送消息给handler
    @param msgHandler   消息处理者
    @param application  当前应用
    @param aUrl         下载地址
    @param filePath     保存下载文件的路径
    @param recorder     XFileDownloadInfoRecorder对象，用于操作配置文件
    @param manager      XFileDownloaderManager对象，用于管理XFileDownloader对象
    @return 初始化后的XFileDownloader对象，如果初始化失败，则返回nil
 */
- (id)initWithMessenger:(XMessenger *)msger messageHandler:(XJavaScriptEvaluator *)msgHandler application:(id<XApplication>)application url:(NSString *)aUrl filePath:(NSString *)filePath downloadInfoRecorder:(XFileDownloadInfoRecorder *)recorder downloaderManager:(XFileDownloaderManager *)manager;

/**
    开始下载.
    @param callback   callback
 */
- (void) download:(XJsCallback *)callback;

/**
    设置暂停.
 */
- (void) pause;

/**
    判断是否处于暂停状态.
 */
- (BOOL) isPaused;

@end

#endif
