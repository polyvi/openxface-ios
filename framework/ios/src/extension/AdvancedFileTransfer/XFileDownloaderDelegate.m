
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
//  XFileDownloaderDelegate.m
//  xFaceLib
//
//

#ifdef __XAdvancedFileTransferExt__

#import "XFileDownloaderDelegate.h"

#define SUCCESS_STATUS_OK                  200
#define REDIRECTION_STATUS_REDIRECTION     300

@implementation XFileDownloaderDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(self->responseCode >= SUCCESS_STATUS_OK && self->responseCode < REDIRECTION_STATUS_REDIRECTION)
    {
        [fileDownloader onSuccess];
    }
    else
    {
        [fileDownloader onError];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self->totalSize =  [httpResponse expectedContentLength];
    self->responseCode = [httpResponse statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [fileDownloader onError];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(![fileDownloader isPaused])
    {
        [fileDownloader onProgressUpdated:self->totalSize withData:data];
    }
}

- (id)initWithDownloader:(XFileDownloader *)downloader
{
    self = [super init];
    if(self)
    {
        self->fileDownloader = downloader;
        self->totalSize = 0;
    }
    return self;
}

@end

#endif
