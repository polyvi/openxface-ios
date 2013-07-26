
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
//  XResourceURLProtocol.m
//  xFaceLib
//
//

#import "XResourceURLProtocol.h"
#import "XConstants.h"

@implementation XResourceURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    //只处理local app 的xface.js的请求, url形如：file://*/xface.js
    return  [[[theRequest URL] scheme] isEqualToString:@"file"]
         && [[[[theRequest URL] path] lastPathComponent] isEqualToString:XFACE_JS_FILE_NAME];
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)request
{
    return request;
}

- (void)startLoading
{
    NSString *srcJsPath = [[NSBundle bundleForClass:[self class]] pathForResource:XFACE_JS_FILE_NAME ofType:nil];
    NSData* data = [NSData dataWithContentsOfFile:srcJsPath];

    NSString* mimeType = @"application/javascript";
    NSString* encodingName = @"UTF-8";

    NSHTTPURLResponse* response =
    [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL]
                                   MIMEType:mimeType
                      expectedContentLength:[data length]
                           textEncodingName:encodingName];

    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    if (data != nil) {
        [[self client] URLProtocol:self didLoadData:data];
    }
    [[self client] URLProtocolDidFinishLoading:self];


}

- (void)stopLoading
{
    // TODO:执行清理操作
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest*)requestA toRequest:(NSURLRequest*)requestB
{
    return [[[[requestA URL] path] lastPathComponent] isEqualToString:XFACE_JS_FILE_NAME] &&
           [[[[requestB URL] path] lastPathComponent] isEqualToString:XFACE_JS_FILE_NAME];
}

@end
