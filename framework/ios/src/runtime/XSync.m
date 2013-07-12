
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
//  XSync.m
//  xFaceLib
//
//
#import "XRuntime.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "APXML.h"
#import "XAPElement.h"
#import "XSync.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XConfiguration.h"

#define SUCCESS_STATUS_OK                        200
#define REDIRECTION_STATUS_REDIRECTION           300
#define URL_REQUEST_TIMEOUT_INTERVAL             4.0

#define APP_TMP_FILE                             @"xface_player.tmp"

#define PORT                       @"8018"

@implementation XSync

- (id) initWith:(id<XSyncDelegate>)delegate
{
    if (self)
    {
        syncDelegate = delegate;
    }
    return self;
}

- (void) run
{
    // localFile路径形如：<Applilcation_Home>/Documents/xface_player.zip, 下载成功覆盖已有的xface_player.zip
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    self->localFilePath = [documentDirectory stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, XFACE_PLAYER_PACKAGE_NAME];
    self->tmpFilePath = [documentDirectory stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, APP_TMP_FILE];

    NSString* ip = [XUtils getIpFromDebugConfig];
    if (0 == ip.length)
    {
        return [self finish:NO];
    }

    NSString* url = [NSString stringWithFormat:@"http://%@:%@/app.zip", ip, PORT];
    [self requestAppFromServerWith:url];
}

#pragma mark Privates

/**
 同步完成通知
 @param success 是否同步成功
 */
- (void) finish:(BOOL)success
{
    [fileHandle closeFile];
    fileHandle = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!success)
    {   //clean up
        [fileManager removeItemAtPath:tmpFilePath error:nil];
    } else
    {
        //覆盖xface_player.zip
        __autoreleasing NSError* error;
        //先删除掉原来的xface_player.zip，否则无法移到文件
        [fileManager removeItemAtPath:localFilePath error:nil];
        [fileManager moveItemAtPath:tmpFilePath toPath:localFilePath error:&error];
        if(error)
        {
            XLogE(@"move tmpfile to xface_player.zip failed! Error - %@ %@",
                  [error localizedDescription],
                  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        }
    }

    if(syncDelegate && [syncDelegate respondsToSelector:@selector(syncDidFinish)] )
    {

        [syncDelegate performSelector:@selector(syncDidFinish)];
    }

}

/**
 发起下载app的请求
 @param url app的url
 */
- (void) requestAppFromServerWith:(NSString *)url
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:URL_REQUEST_TIMEOUT_INTERVAL];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        //打开文件
        [[NSFileManager defaultManager] createFileAtPath:tmpFilePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tmpFilePath];
        if(fileHandle)
        {
            [fileHandle seekToEndOfFile];
        }
    }
    else
    {
        [self finish:NO];
    }
}

#pragma mark NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self->responseCode = [httpResponse statusCode];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(self->responseCode >= SUCCESS_STATUS_OK && self->responseCode < REDIRECTION_STATUS_REDIRECTION)
    {
        [self finish:YES];
    }
    else
    {
        [self finish:NO];
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   XLogE(@"sync player app failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
     [self finish:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (fileHandle)
    {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
    }
}

@end
