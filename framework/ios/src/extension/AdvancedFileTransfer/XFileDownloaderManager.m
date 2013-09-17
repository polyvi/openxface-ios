
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
//  XFileDownloaderManager.m
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import "XFileDownloaderManager.h"
#import "XApplication.h"
#import "XFileDownloader.h"
#import "XFileUtils.h"

@implementation XFileDownloaderManager

- (id) init
{
    self = [super init];
    if(self)
    {
        self->dictDownloaders = [NSMutableDictionary dictionaryWithCapacity:1];
        self->dictDownloadInfoRecorders = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void) removeDownloaderWithAppId:(NSString *)appId url:(NSString *)url
{
    NSMutableDictionary *downloaders = [self->dictDownloaders valueForKey:appId];
    if (nil != downloaders)
    {
        [downloaders removeObjectForKey:url];
    }
}

- (void) addDownloaderWithMessenger:(XMessenger *)msger messageHandler:(XJavaScriptEvaluator *)msgHandler callback:(XJsCallback *)callback application:(id<XApplication>)application url:(NSString *)aUrl filePath:(NSString *)filePath
{
    XFileDownloadInfoRecorder *downloadInfoRecorder = [self->dictDownloadInfoRecorders valueForKey:[application getAppId]];
    if (nil == downloadInfoRecorder)
    {
        downloadInfoRecorder = [[XFileDownloadInfoRecorder alloc] initWithApp:application];
        [self->dictDownloadInfoRecorders setObject:downloadInfoRecorder forKey:[application getAppId]];
    }

    NSMutableDictionary *downloaders = [self->dictDownloaders valueForKey:[application getAppId]];
    XFileDownloader *downloader = nil;
    if(nil == downloaders)
    {
        downloader = [[XFileDownloader alloc] initWithMessenger:msger messageHandler:msgHandler application:application url:aUrl filePath:filePath downloadInfoRecorder:downloadInfoRecorder downloaderManager:self];
        downloaders = [NSMutableDictionary dictionaryWithCapacity:1];
        [downloaders setObject:downloader forKey:aUrl];
        [self->dictDownloaders setObject:downloaders forKey:[application getAppId]];
    }
    else
    {
        downloader = [downloaders objectForKey:aUrl];
        if(nil == downloader)
        {
            downloader = [[XFileDownloader alloc] initWithMessenger:msger messageHandler:msgHandler application:application url:aUrl filePath:filePath downloadInfoRecorder:downloadInfoRecorder downloaderManager:self];
            [downloaders setObject:downloader forKey:aUrl];
        }
    }
    [downloader download:callback];
}

- (void) pauseWithAppId:(NSString *)appId url:(NSString *)url
{
    NSMutableDictionary *downloaders = [self->dictDownloaders valueForKey:appId];
    if(nil != downloaders)
    {
        XFileDownloader *downloader = [downloaders valueForKey:url];
        if(nil != downloader)
        {
            [downloader pause];
        }
    }
}

- (void)pauseAll
{
    [self->dictDownloaders enumerateKeysAndObjectsUsingBlock:^(id key, id downloaders, BOOL* stop){
        if(nil != downloaders)
        {
            [(NSMutableDictionary*)downloaders enumerateKeysAndObjectsUsingBlock:^(id key, id downloader, BOOL* stop){
                if(nil != downloader)
                {
                    [downloader pause];
                }
            }];

        }

    }];
}

- (void) cancelWithAppId:(NSString *)appId url:(NSString *)url filePath:(NSString *)filePath
{
    [self pauseWithAppId:appId url:url];
    [self removeDownloaderWithAppId:appId url:url];
    XFileDownloadInfoRecorder *recorder = [self->dictDownloadInfoRecorders objectForKey:appId];
    [recorder deleteDownloadInfo:url];

    //删掉已下载的temp文件
    [XFileUtils removeItemAtPath:[filePath stringByAppendingString:TEMP_FILE_SUFFIX] error:nil];
}

- (void)dealloc
{
    [self pauseAll];
}

@end

#endif
