
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
//  XAdvancedFileTransferExt.h
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import "XExtension.h"
#import "XFileDownloaderManager.h"

@interface XAdvancedFileTransferExt : XExtension
{
    XFileDownloaderManager *downloaderManager;
    XMessenger             *messenger;          /**< 用于发送消息给 message handler */
}

/**
    文件下载.
    @param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* serverURL  服务器路径
        - 2 NSString* filePath   本地存储下载文件的路径
        - 3 id<XApplication> app 当前应用
    @param options 可选参数
 */
- (void) download:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    暂停下载.
    @param arguments 参数列表
        - 0 XJsCallback* callback
        - 1 NSString* serverURL  要暂停的服务器路径
        - 2 id<XApplication> app 当前应用
    @param options 可选参数
 */
- (void) pause:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

/**
    取消下载.
    @param arguments 参数列表
    - 0 XJsCallback* callback
    - 1 NSString* serverURL    要取消的服务器路径
    - 2 NSString* filePath     本地存储下载文件的路径
    - 3 id<XApplication> app   当前应用
    @param options 可选参数
 */
- (void) cancel:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

#endif
