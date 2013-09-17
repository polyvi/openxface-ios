
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
//  XFileDownloaderManager.h
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import <Foundation/Foundation.h>
#import "XFileDownloadInfoRecorder.h"
#import "XMessenger.h"
#import "XJavaScriptEvaluator.h"

@class XJsCallback;

/** 该类用于管理所有应用的下载器，当有下载任务发起时创建一个XFileDownloader，
 *  当当前的url对应的下载任务完成时应该删除该下载任务 */
@interface XFileDownloaderManager : NSObject
{
    /** 该对象的key代表appId,value代表NSMutableDictionary对象，这个对象中的key代表url,value代表XFileDownloader对象*/
    NSMutableDictionary *dictDownloaders;

    /** 为每个app创建一个XFileDownloadInfoRecorder对象，该对象的key代表appId*/
    NSMutableDictionary *dictDownloadInfoRecorders;
}

/**
    初始化XFileDownloaderManager对象.
    @return 初始化后的XFileDownloaderManager对象，如果初始化失败，则返回nil
 */
- (id) init;

/**
    当文件下载完成时移除XFileDownloader.
    @param appId        该FileDownloader所在的App的id
    @param url          下载地址
 */
- (void) removeDownloaderWithAppId:(NSString *)appId url:(NSString *)url;

/**
    当有下载任务发起时，添加一个XFileDownloader.
    @param msger        用于发送消息给handler
    @param msgHandler   消息处理者
    @param callback     callback
    @param application  当前应用
    @param aUrl         下载地址
    @param filePath     保存下载文件的路径
 */
- (void) addDownloaderWithMessenger:(XMessenger *)msger messageHandler:(XJavaScriptEvaluator *)msgHandler callback:(XJsCallback *)callback application:(id<XApplication>)application url:(NSString *)aUrl filePath:(NSString *)filePath;

/**
    暂停当前app下url对应的下载任务.
    @param appId        该FileDownloader所在的App的id
    @param url          下载地址
 */
- (void) pauseWithAppId:(NSString *)appId url:(NSString *)url;

/**
    暂停所有的下载任务.
 */
- (void)pauseAll;

/**
    取消当前app下url对应的下载任务.
    @param appId        当前app的id
    @param url          下载地址
    @param filePath     存放下载文件的本地地址
 */
- (void) cancelWithAppId:(NSString *)appId url:(NSString *)url filePath:(NSString *)filePath;

@end

#endif
