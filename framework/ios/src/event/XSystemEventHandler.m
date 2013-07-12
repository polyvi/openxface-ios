
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
//  XSystemEventHandler.m
//  xFaceLib
//
//

#import <MediaPlayer/MPMusicPlayerController.h>
#import "XSystemEventHandler.h"
#import "XAppManagement.h"
#import "XExtensionManager.h"
#import "XApplication.h"
#import "XFileUtils.h"
#import "NSObject+JSONSerialization.h"
#import "XConstants.h"
#import "XSystemEventHandler_Privates.h"
#import "XJsCallback.h"
#import "XJavaScriptEvaluator.h"
#import "XAppList.h"

@implementation XSystemEventHandler

- (id) initWithAppManagement:(XAppManagement *)applicationManagement
{
    self = [super init];
    if (self)
    {
        self->appManagement = applicationManagement;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];

        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        self->oldVolume = [musicPlayer volume];
        [musicPlayer beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeDidChange:)
                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appWillTerminate:(NSNotification*)notification
{
    [self->appManagement closeAllApps];

    // 清空临时目录
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    [XFileUtils removeContentOfDirectoryAtPath:tempDirectoryPath error:nil];

    // TODO:如有扩展需要被通知，可在此处增加操作
}

- (void)appWillEnterForeground:(NSNotification*)notification
{
    [self handleNotification:@"resume"];
}

- (void)appDidEnterBackground:(NSNotification*)notification
{
    [self handleNotification:@"pause"];
}

- (void)appWillResignActive:(NSNotification*)notification
{
    [self handleNotification:@"resign"];
}

- (void)appDidBecomeActive:(NSNotification*)notification
{
    [self handleNotification:@"active"];
}

- (void)volumeDidChange:(NSNotification*)notification
{
    MPMusicPlayerController *appMusicPlayer = [notification object];
    float currentVolume = [appMusicPlayer volume];
    if(self->oldVolume > currentVolume || currentVolume == 0)
    {
        [self handleNotification:@"volumedownbutton"];
    }
    else
    {
        [self handleNotification:@"volumeupbutton"];
    }
    self->oldVolume = currentVolume;
}

#pragma mark Privates

- (void) handleNotification:(NSString *)eventType
{
        NSString *jsStatement = [NSString stringWithFormat:
                                 @"(function() { \
                                 try { \
                                 xFace.fireDocumentEvent('%@'); \
                                 } catch (e) { \
                                 console.log('exception in fireDocumentEvent:' + e);\
                                 } \
                                 })()",
                                 eventType];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:DOCUMENT_EVENT_NOTIFICATION object:nil userInfo:@{@"evnetType" : eventType, @"js" : jsStatement}]];
}

@end
