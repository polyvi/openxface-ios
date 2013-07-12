
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
//  XAppUpdater.m
//  xFaceLib
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XAppUpdater.h"
#import "XAppUpdater_Privates.h"
#import "XConstants.h"
#import "XUtils.h"

#define SUCCESS_STATUS_OK                        200
#define REDIRECTION_STATUS_REDIRECTION           300
#define URL_REQUEST_TIMEOUT_INTERVAL             30.0

@implementation XAppUpdater

- (void) run
{
    BOOL willCheckUpdate = [[XUtils getPreferenceForKey:CHECK_UPDATE_PROP_NAME] boolValue];
    if (NO == willCheckUpdate)
    {
        return;
    }

    NSString* serverAddress = [XUtils getPreferenceForKey:UPDATE_ADDRESS_PROP_NAME];
    if (0 == serverAddress.length)
    {
        XLogW(@"please set the update address");
        return;
    }

    NSString *currentVersionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:BUNDLE_VERSION_KEY];
    [self checkNewVersionWith:serverAddress  currentVersionCode:currentVersionCode];
}

#pragma mark Privates

- (void) checkNewVersionWith:(NSString *)serverAddress currentVersionCode:(NSString *)currentVersionCode
{
    serverAddress = [NSString stringWithFormat:@"%@?platform=iOS&currentVersionCode=%@", serverAddress, currentVersionCode];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:serverAddress]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:URL_REQUEST_TIMEOUT_INTERVAL];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection)
    {
        self->downloadAddressData = [NSMutableData data];
       [downloadAddressData setLength:0];
    }
    else
    {
         XLogW(@"check new version failed!");
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
    if(self->responseCode >= SUCCESS_STATUS_OK && self->responseCode < REDIRECTION_STATUS_REDIRECTION && downloadAddressData.length > 0)
    {
        //TODO 规范化提示信息，显示更新日志
        NSString* title = @"发现新版本";
        NSString* message = @"是否下载新版本";
        UIAlertView *alertView = [[UIAlertView alloc]
                                 initWithTitle:title
                                 message:message
                                 delegate:self
                                 cancelButtonTitle:@"暂不更新"
                                 otherButtonTitles:nil];
        [alertView addButtonWithTitle:@"更新"];
        [alertView show];
    }
    else
    {
        XLogW(@"check new version failed!");
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    XLogW(@"check new version connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     [downloadAddressData appendData:data];
}

#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(0 == buttonIndex)
    {
        return;          //cancel, do nothing
    }

    NSString* urlStr = [[NSString alloc] initWithData:downloadAddressData encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    BOOL ret = [[UIApplication sharedApplication] canOpenURL:url];
    if (ret)
    {
        ret = [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        XLogE(@"check new version failed when open url");
    }
}

@end
