
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XFileTransferExt.m
//  xFace
//
//

#ifdef __XFileTransferExt__

#import "XFileTransferExt.h"
#import "XExtensionResult.h"
#import "XConstants.h"
#import "XJavaScriptEvaluator.h"
#import "XFileTransferDelegate.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XFileUtils.h"
#import "XJsCallback.h"
#import "XQueuedMutableArray.h"
#import "XFileTransferExt_Privates.h"
#import "XLog.h"
#include <CFNetwork/CFNetwork.h>

// 使用块流传输时的缓冲区大小 32K
#define KSTREAMBUFFERSIZE   32768

@implementation XFileTransferExt

@synthesize activeTransfers;

- (void) download:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    XJsCallback *callback = [self getJsCallback:options];
    id<XApplication> app = [self getApplication:options];
    NSString *sourceUrl = [arguments objectAtIndex:0];
    NSString *filePath = [arguments objectAtIndex:1];
    // ios 不支持 arguments中的第二个参数 trustAllHosts
    NSString* objectId = [arguments objectAtIndex:3];
    NSString *workspace = [app getWorkspace];
    XExtensionResult *result = nil;
    XFileTransferError errorCode = 0;

    if (NSNotFound != [filePath rangeOfString:@":"].location)
    {
        errorCode = FILE_NOT_FOUND_ERR;
    }

    NSString* fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
    if (!fullPath)
    {
        errorCode = FILE_NOT_FOUND_ERR;
    }

    NSURL *file = [NSURL fileURLWithPath:filePath];
    NSURL *url = [NSURL URLWithString:sourceUrl];

    if (!url)
    {
        errorCode = INVALID_URL_ERR;
        XLogE(@"File Transfer Error: Invalid server URL");
    }
    else if(![file isFileURL])
    {
        errorCode = FILE_NOT_FOUND_ERR;
        XLogE(@"File Transfer Error: Invalid file path or URL");
    }

    if(errorCode > 0)
    {
        NSDictionary *errorInfo = [XFileUtils createFileTransferError:errorCode andSource:sourceUrl andTarget:fullPath];
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:errorInfo];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    XFileTransferDelegate* delegate = [[XFileTransferDelegate alloc] init];
    delegate.command = self;
    delegate.jsEvaluator = self->jsEvaluator;
    delegate.workspace = workspace;
    delegate.direction = TRANSFER_DOWNLOAD;
    delegate.jsCallback = callback;
    delegate.source = sourceUrl;
    delegate.target = fullPath;
    delegate.objectId = objectId;
    delegate.connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    if (activeTransfers == nil)
    {
        activeTransfers = [[NSMutableDictionary alloc] init];
    }

    [activeTransfers setObject:delegate forKey:delegate.objectId];
}

- (CFIndex) writeDataToStream:(NSData *)data stream:(CFWriteStreamRef)stream
{
    UInt8* bytes = (UInt8*)[data bytes];
    NSUInteger bytesToWrite = [data length];
    NSUInteger totalBytesWritten = 0;
    while (totalBytesWritten < bytesToWrite)
    {
        CFIndex result = CFWriteStreamWrite(stream, bytes + totalBytesWritten, bytesToWrite - totalBytesWritten);
        if (result < 0)
        {
            CFStreamError error = CFWriteStreamGetError(stream);
            XLogE(@"WriteStreamError domain: %ld error: %ld", error.domain, error.error);
            return result;
        }
        else if (result == 0)
        {
            return result;
        }
        totalBytesWritten += result;
    }
    return totalBytesWritten;
}

- (void) handleHeaders:(NSMutableURLRequest *)request withDict:(NSDictionary *) headers
{
    NSEnumerator *enumerator = [headers keyEnumerator];
    id val;
    NSString *nkey;

    while (nkey = [enumerator nextObject])
    {
        val = [headers objectForKey:nkey];
        if(!val || val == [NSNull null] || [nkey isEqualToString:@"__cookie"])
        {
            continue;
        }
        if ([val respondsToSelector:@selector(stringValue)])
        {
            val = [val stringValue];
        }
        if (![val isKindOfClass:[NSString class]])
        {
            continue;
        }
        [request setValue:val forHTTPHeaderField:nkey];
    }
}

- (NSMutableData *)createHeadersForUploadingFile:(NSMutableArray*)arguments withDict:(NSDictionary*)options fileData:(NSData*)fileData
{
    NSString* fileKey = [arguments objectAtIndex:2];
    NSString* fileName = [arguments objectAtIndex:3 withDefault:@"no-filename"];
    NSString* mimeType = [arguments objectAtIndex:4 withDefault:nil];
    NSDictionary *params = [arguments objectAtIndex:5];

    NSString *boundary = @"*****com.polyvi.formBoundary";
    NSMutableData *bodyBeforeFile = [NSMutableData data];
	NSEnumerator *enumerator = [params keyEnumerator];
    id val;
    id key;
    while ((key = [enumerator nextObject]))
    {
        val = [params objectForKey:key];
        if(!val || val == [NSNull null])
        {
            continue;
        }
        if ([val respondsToSelector:@selector(stringValue)])
        {
            val = [val stringValue];
        }
        if (![val isKindOfClass:[NSString class]])
        {
            continue;
        }

        [bodyBeforeFile appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyBeforeFile appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyBeforeFile appendData:[val dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyBeforeFile appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [bodyBeforeFile appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyBeforeFile appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileKey, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    if (mimeType != nil)
    {
        [bodyBeforeFile appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [bodyBeforeFile appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n\r\n", [fileData length]] dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyBeforeFile;
}

- (NSURLRequest*) requestForUpload:(NSMutableArray*)arguments withDict:(NSDictionary*)options fileData:(NSData*)fileData
{
    XJsCallback *callback = [self getJsCallback:options];
    id<XApplication> app = [self getApplication:options];
    NSString* filePath = [arguments objectAtIndex:0];
    NSString* server = [arguments objectAtIndex:1];
    NSDictionary *params = [arguments objectAtIndex:5];
    // ios 不支持 arguments中的第六个参数 trustAllHosts
    BOOL chunkedMode = [[arguments objectAtIndex:7 withDefault:[NSNumber numberWithBool:YES]] boolValue];
    NSDictionary* headers = [arguments objectAtIndex:8 withDefault:nil];

    // iOS < 5 调用CFStreamCreateBoundPair方法会crash.
    if (!SYSTEM_VERSION_NOT_LOWER_THAN(@"5"))
    {
        chunkedMode = NO;
    }

    XExtensionResult* result = nil;
    XFileTransferError errorCode = 0;

    NSURL *url = [NSURL URLWithString:server];

    if (!url)
    {
        errorCode = INVALID_URL_ERR;
        XLogE(@"File Transfer Error: Invalid server URL %@", server);
    }
    else if(!fileData)
    {
        errorCode = FILE_NOT_FOUND_ERR;
    }

    if (errorCode > 0)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject: [XFileUtils createFileTransferError:errorCode andSource:filePath andTarget:server]];

        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

    //    Magic value to set a cookie
    if ([params objectForKey:@"__cookie"]) {
        [request setValue:[params objectForKey:@"__cookie"] forHTTPHeaderField:@"Cookie"];
        [request setHTTPShouldHandleCookies:NO];
    }

    NSString *boundary = @"*****com.polyvi.formBoundary";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];

    UIWebView *webview = nil;
    NSString* userAgent = nil;
    if([app respondsToSelector:@selector(appView)])
    {
        webview = (UIWebView *)[app performSelector:@selector(appView)];
        userAgent = [[webview request] valueForHTTPHeaderField:@"User-agent"];
    }
    if(userAgent)
    {
        [request setValue: userAgent forHTTPHeaderField:@"User-Agent"];
    }

    [self handleHeaders:request withDict:headers];

    NSMutableData *bodyBeforeFile = [self createHeadersForUploadingFile:arguments withDict:options fileData:fileData];
    XLogI(@"fileData length: %d", [fileData length]);
    NSData *bodyAfterFile = [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];

    NSUInteger totalPayloadLength = [bodyBeforeFile length] + [fileData length] + [bodyAfterFile length];
    [request setValue:[[NSNumber numberWithInteger:totalPayloadLength] stringValue] forHTTPHeaderField:@"Content-Length"];

    if (chunkedMode)
    {
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreateBoundPair(NULL, &readStream, &writeStream, KSTREAMBUFFERSIZE);
        [request setHTTPBodyStream:CFBridgingRelease(readStream)];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (CFWriteStreamOpen(writeStream))
            {
                NSData* chunks[] = { bodyBeforeFile, fileData, bodyAfterFile};
                int numChunks = sizeof(chunks) / sizeof(chunks[0]);
                for (int index = 0; index < numChunks; ++index)
                {
                    CFIndex result = [self writeDataToStream:chunks[index] stream:writeStream];
                    if (result <= 0)
                    {
                        break;
                    }
                }
            }
            else
            {
                XLogE(@"FileTransfer: Failed to open writeStream");
            }
            CFWriteStreamClose(writeStream);
            CFRelease(writeStream);
        });
    }
    else
    {
        [bodyBeforeFile appendData:fileData];
        [bodyBeforeFile appendData:bodyAfterFile];
        [request setHTTPBody:bodyBeforeFile];
    }
    return request;
}

- (NSData*) fileDataForUploadArguments:(NSMutableArray*)arguments withDict:(NSDictionary *)options
{
    NSString* filePath = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString *workspace = [app getWorkspace];
    __autoreleasing NSError *err = nil;

    NSString* fullPath = nil;
    // 如果不是以file://协议开头认为是相对路径，相对路径应该是在workspace下
    if(![filePath hasPrefix:@"file://"])
    {
        fullPath = [XUtils resolvePath:filePath usingWorkspace:workspace];
        if(nil == fullPath)
        {
            return nil;
        }
    }
    else
    {
        // 如果是绝对路径直接使用
        fullPath = [[NSURL URLWithString:filePath] path];
    }

    NSData* fileData = [NSData dataWithContentsOfFile:fullPath options:NSDataReadingMappedIfSafe error:&err];
    if (err != nil)
    {
        XLogE(@"Error opening file %@: %@", filePath, err);
    }
    return fileData;
}

-(NSMutableDictionary*) createFileTransferError:(int)code andSource:(NSString*)source andTarget:(NSString*)target andHttpStatus:(int)httpStatus
{
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:4];
    [result setObject: [NSNumber numberWithInt:code] forKey:@"code"];
    [result setObject: source forKey:@"source"];
    [result setObject: target forKey:@"target"];
    [result setObject: [NSNumber numberWithInt:httpStatus] forKey:@"http_status"];
    XLogE(@"FileTransferError %@", result);

    return result;
}

- (void) upload:(NSMutableArray*)arguments withDict:(NSDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString* filePath = [arguments objectAtIndex:0];
    NSString* server = [arguments objectAtIndex:1];
    NSString* objectId = [arguments objectAtIndex:9];

    NSData* fileData = [self fileDataForUploadArguments:arguments withDict:options];
    NSURLRequest* request = [self requestForUpload:arguments withDict:options fileData:fileData];
    if (nil == request)
    {
        return;
    }

    XFileTransferDelegate* delegate = [[XFileTransferDelegate alloc] init];
    delegate.command = self;
    delegate.direction = TRANSFER_UPLOAD;
    delegate.jsCallback = callback;
    delegate.source = server;
    delegate.target = filePath;
    delegate.command = self;
    delegate.jsEvaluator = self->jsEvaluator;
    delegate.objectId = objectId;
    delegate.connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    if (activeTransfers == nil)
    {
        activeTransfers = [[NSMutableDictionary alloc] init];
    }

    [activeTransfers setObject:delegate forKey:delegate.objectId];
}

- (void)abort:(NSMutableArray*)arguments withDict:(NSDictionary*)options
{
    NSString* objectId = [arguments objectAtIndex:0];

    XFileTransferDelegate* delegate = [activeTransfers objectForKey:objectId];

    if (delegate != nil)
    {
        [delegate.connection cancel];
        [activeTransfers removeObjectForKey:objectId];
        NSDictionary *errorInfo = [XFileUtils createFileTransferError:CONNECTION_ABORTED andSource:delegate.source andTarget:delegate.target];
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:errorInfo];
        [delegate.jsCallback setExtensionResult:result];
        [self->jsEvaluator eval:delegate.jsCallback];
    }
}

@end

#endif
