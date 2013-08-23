
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
//  XFileDownloadInfoRecorder.m
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import "XFileDownloadInfoRecorder.h"
#import "XApplication.h"
#import "XConstants.h"
#import "APDocument+XAPDocument.h"
#import "XAPElement.h"
#import "XFileDownloadInfo.h"
#import "XUtils.h"

#define TAG_URL                      @"url"
#define ATTR_ID                      @"id"
#define ATTR_TOTALSIZE               @"totalSize"
#define ATTR_COMPLETESIZE            @"completeSize"

#define DOWNLOAD_INFO_FILE_NAME     @"download_info.xml"


@implementation XFileDownloadInfoRecorder

- (id) initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self)
    {
        self->configFilePath = [[app getDataDir] stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, DOWNLOAD_INFO_FILE_NAME];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL exists = [fileMgr fileExistsAtPath:self->configFilePath isDirectory: &isDir];
        NSString *data = @"\n<download_info>\n</download_info>\n";
        NSData* encData = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        if(!exists)
        {
            [fileMgr createFileAtPath:self->configFilePath contents:encData attributes:nil];
        }
        @synchronized(self)
        {
            self->document = [APDocument documentWithFilePath:configFilePath];
        }
    }
    return self;
}

- (BOOL) hasInfo:(NSString *)url
{
    if(nil != self->document)
    {
        APElement *rootElement = [self->document rootElement];
        APElement *urlElement = [rootElement elementNamed:TAG_URL attribute:ATTR_ID withValue:url];
        return urlElement != nil;
    }
    return NO;
}

- (void) saveDownloadInfo:(XFileDownloadInfo *)downloadInfo
{
    if(nil != self->document)
    {
        APElement *rootElement = [self->document rootElement];
        APElement *urlElement = [APElement elementWithName:TAG_URL];
        NSAssert(nil != urlElement, nil);
        [urlElement addAttributeNamed:ATTR_ID withValue:[downloadInfo url]];
        NSString *completeSizeStr = [NSString stringWithFormat:@"%d", [downloadInfo completeSize]];
        [urlElement addAttributeNamed:ATTR_COMPLETESIZE withValue:completeSizeStr];
        NSString *totalSizeStr = [NSString stringWithFormat:@"%d", [downloadInfo totalSize]];
        [urlElement addAttributeNamed:ATTR_TOTALSIZE withValue:totalSizeStr];
        [urlElement setParent:rootElement];
        [rootElement addChild:urlElement];
        @synchronized(self)
        {
            [XUtils saveDoc:self->document toFile:self->configFilePath];
        }
    }
}

- (XFileDownloadInfo *) getDownloadInfo:(NSString *)url
{
    XFileDownloadInfo *downloadInfo = nil;
    if(nil != self->document)
    {
        APElement *rootElement = [self->document rootElement];
        APElement *urlElement = [rootElement elementNamed:TAG_URL attribute:ATTR_ID withValue:url];
        if(nil != urlElement)
        {
            NSString *url = [urlElement valueForAttributeNamed:ATTR_ID];
            NSInteger totalSize = [[urlElement valueForAttributeNamed:ATTR_TOTALSIZE] integerValue];
            NSInteger completeSize = [[urlElement valueForAttributeNamed:ATTR_COMPLETESIZE] integerValue];
            downloadInfo = [[XFileDownloadInfo alloc] initWithURL:url andTotalSize:totalSize andCompleteSize:completeSize];
        }
    }
    return downloadInfo;
}

- (void) setTotalSize:(NSInteger)totalSize withUrl:(NSString *)url
{
    if(nil != self->document)
    {
        APElement *rootElement = [self->document rootElement];
        APElement *urlElement = [rootElement elementNamed:TAG_URL attribute:ATTR_ID withValue:url];
        if(nil != urlElement)
        {
            NSString *totalSizeStr = [NSString stringWithFormat:@"%d", totalSize];
            [urlElement addAttributeNamed:ATTR_TOTALSIZE withValue:totalSizeStr];
        }
        @synchronized(self)
        {
            [XUtils saveDoc:self->document toFile:self->configFilePath];
        }
    }
}

- (void) deleteDownloadInfo:(NSString *)url
{
    if(nil != self->document)
    {
        APElement *rootElement = [self->document rootElement];
        APElement *urlElement = [rootElement elementNamed:TAG_URL attribute:ATTR_ID withValue:url];
        if(nil != urlElement)
        {
            [rootElement removeChild:urlElement];
        }
        @synchronized(self)
        {
            [XUtils saveDoc:self->document toFile:self->configFilePath];
        }
    }
}

@end

#endif
