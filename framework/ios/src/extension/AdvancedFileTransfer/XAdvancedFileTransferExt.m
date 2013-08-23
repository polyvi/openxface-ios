
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
//  XAdvancedFileTransferExt.m
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import "XAdvancedFileTransferExt.h"
#import "XApplication.h"
#import "XMessenger.h"
#import "XUtils.h"
#import "XFileTransferExt.h"
#import "XExtensionResult.h"
#import "XFileUtils.h"
#import "XJsCallback.h"
#import "XUtils.h"

@implementation XAdvancedFileTransferExt

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        self->downloaderManager = [[XFileDownloaderManager alloc] init];
        self->messenger = [[XMessenger alloc] init];
    }

    return self;
}

- (void) download:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString *source = [arguments objectAtIndex:0];
    NSString *filePath = [arguments objectAtIndex:1];
    id<XApplication> app = [self getApplication:options];
    XFileTransferError errorCode = 0;
    XExtensionResult *result = nil;

    if (NSNotFound != [filePath rangeOfString:@":"].location)
    {
        errorCode = FILE_NOT_FOUND_ERR;
    }

    NSString *fullPath = [XUtils resolvePath:filePath usingWorkspace:[app getWorkspace]];
    if (!fullPath)
    {
        errorCode = FILE_NOT_FOUND_ERR;
    }

    NSURL *file = [NSURL fileURLWithPath:filePath];
    NSURL *url = [NSURL URLWithString:source];

    if (!url)
    {
        errorCode = INVALID_URL_ERR;
        XLogE(@"Advanced File Transfer Error: Invalid server URL");
    }
    else if(![file isFileURL])
    {
        errorCode = FILE_NOT_FOUND_ERR;
        XLogE(@"Advanced File Transfer Error: Invalid file path or URL");
    }

    if(errorCode > 0)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject: [XFileUtils createFileTransferError:errorCode andSource:source andTarget:filePath]];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
        return;
    }

    [downloaderManager addDownloaderWithMessenger:self->messenger messageHandler:self->jsEvaluator callback:callback application:app url:source filePath:fullPath];
}

- (void) pause:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *source = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    [downloaderManager pauseWithAppId:[app getAppId] url:source];
}

- (void) cancel:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString *url = [arguments objectAtIndex:0];
    NSString *filePath = [arguments objectAtIndex:1];
    id<XApplication> app = [self getApplication:options];
    filePath = [XUtils resolvePath:filePath usingWorkspace:[app getWorkspace]];
    [downloaderManager cancelWithAppId:[app getAppId] url:url filePath:filePath];
}

- (void) onAppClosed:(NSString *)appId
{
    // 退出app时暂停该app中的所有下载任务
    [downloaderManager stopAllWithAppId:appId];
}

@end

#endif
