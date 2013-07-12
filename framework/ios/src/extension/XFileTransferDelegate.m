
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
//  XFileTransferDelegate.m
//  xFace
//
//

#ifdef __XFileTransferExt__

#import "XFileTransferDelegate.h"
#import "XExtensionResult.h"
#import "XConstants.h"
#import "XJavaScriptEvaluator.h"
#import "XFileUtils.h"
#import "XJsCallback.h"

@implementation XFileTransferDelegate

@synthesize connection;
@synthesize jsCallback;
@synthesize objectId;
@synthesize source;
@synthesize target;
@synthesize jsEvaluator;
@synthesize workspace;
@synthesize responseData;
@synthesize command;
@synthesize direction;
@synthesize responseCode;
@synthesize bytesTransfered;
@synthesize bytesExpected;

#define SUCCESS_STATUS_OK                  200
#define REDIRECTION_STATUS_REDIRECTION     300

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    BOOL downloadResponse = NO;
    NSString* uploadResponse = nil;
    NSMutableDictionary* uploadResult;
    XExtensionResult *result = nil;
    NSError __autoreleasing *error = nil;
    NSString *parentPath = nil;
    BOOL dirRequest = NO;
    BOOL errored = NO;

    if(TRANSFER_UPLOAD == self.direction)
    {
        if(self.responseCode >= SUCCESS_STATUS_OK && self.responseCode < REDIRECTION_STATUS_REDIRECTION)
        {
            uploadResponse = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
            uploadResult = [NSMutableDictionary dictionaryWithCapacity:3];
            if (uploadResponse != nil)
            {
                [uploadResult setObject: uploadResponse forKey: @"response"];
            }
            [uploadResult setObject:[NSNumber numberWithInt: self.bytesTransfered] forKey:@"bytesSent"];
            [uploadResult setObject:[NSNumber numberWithInt:self.responseCode] forKey: @"responseCode"];
            result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: uploadResult];
        }
        else
        {
            result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject: [self.command createFileTransferError: CONNECTION_ERR andSource:source andTarget:target andHttpStatus:self.responseCode]];
            errored = YES;
        }
    }
    if(TRANSFER_DOWNLOAD == self.direction)
    {
        XLogI(@"Write file %@", target);
        XLogI(@"File Transfer Finished with response code %d", self.responseCode);

        if(self.responseCode >= SUCCESS_STATUS_OK && self.responseCode < REDIRECTION_STATUS_REDIRECTION)
        {
            parentPath = [self.target stringByDeletingLastPathComponent];

            // check if the path exists => create directories if needed
            NSFileManager* fileMgr = [NSFileManager defaultManager];
            if(![fileMgr fileExistsAtPath:parentPath ])
            {
                [fileMgr createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            downloadResponse = [self.responseData writeToFile:self.target options:NSDataWritingFileProtectionNone error:&error];

            if (!downloadResponse)
            {
                result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject: [self.command createFileTransferError: INVALID_URL_ERR andSource:source andTarget:target andHttpStatus:self.responseCode]];
                errored = YES;
            }
            else
            {
                XLogE(@"File Transfer Download success");

                result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: [XFileUtils getEntry:target usingWorkspace:self.workspace isDir:dirRequest]];
            }
        }
        else
        {
            result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject: [self.command createFileTransferError: CONNECTION_ERR andSource:source andTarget:target andHttpStatus:self.responseCode]];
            errored = YES;
        }
    }
    [jsCallback setExtensionResult:result];
    [self.jsEvaluator eval:jsCallback];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // required for iOS 4.3, for some reason; response is
    // a plain NSURLResponse, not the HTTP subclass
    if (![response isKindOfClass:[NSHTTPURLResponse class]])
    {
        self.responseCode = 403;
        self.bytesExpected = [response expectedContentLength];
        return;
    }

    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseCode = [httpResponse statusCode];
    self.bytesExpected = [response expectedContentLength];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject: [self.command createFileTransferError: CONNECTION_ERR andSource:source andTarget:target andHttpStatus:self.responseCode]];
    XLogE(@"File Transfer Error: %@", [error localizedDescription]);
    [jsCallback setExtensionResult:result];
    [self.jsEvaluator eval:jsCallback];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.bytesTransfered += data.length;
    [self.responseData appendData:data];

    if (TRANSFER_DOWNLOAD == self.direction)
    {
        BOOL lengthComputable = (self.bytesExpected != NSURLResponseUnknownLength);
        [self sendProgressCallBack:lengthComputable bytesTransfer:self.bytesTransfered bytesTotal:self.bytesExpected];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (TRANSFER_UPLOAD == self.direction)
    {
        [self sendProgressCallBack:true bytesTransfer:totalBytesWritten bytesTotal:totalBytesExpectedToWrite];
    }
    self.bytesTransfered = totalBytesWritten;
}

-(void) sendProgressCallBack:(BOOL)lengthComputable bytesTransfer:(NSInteger)transfer bytesTotal:(NSInteger)total
{
    NSMutableDictionary* progress = [NSMutableDictionary dictionaryWithCapacity:3];

    [progress setObject:[NSNumber numberWithBool:lengthComputable] forKey:@"lengthAvailable"];
    [progress setObject:[NSNumber numberWithInt:transfer] forKey:@"loaded"];
    [progress setObject:[NSNumber numberWithInt:total] forKey:@"total"];
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:progress];
    [result setKeepCallback:true];
    [jsCallback setExtensionResult:result];
    [self.jsEvaluator eval:jsCallback];
}

- (id) init
{
    if ((self = [super init]))
    {
        self.responseData = [NSMutableData data];
    }
    return self;
}

@end

#endif
