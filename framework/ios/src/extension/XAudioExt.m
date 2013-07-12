
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
//  XAudioExt.m
//  xFaceLib
//
//

#ifdef __XAudioExt__

#import "XAudioExt.h"
#import "XAudioExt_Privates.h"
#import "XExtensionResult.h"
#import "XJsCallback.h"
#import "NSObject+JSONSerialization.h"
#import "XAppWebView.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XQueuedMutableArray.h"

#define DOCUMENTS_SCHEME_PREFIX @"documents://"
#define HTTP_SCHEME_PREFIX @"http://"
#define HTTPS_SCHEME_PREFIX @"https://"
#define FILE_SCHEME_PREFIX @"file://"

@implementation XAudioFile

@synthesize resourcePath;
@synthesize resourceURL;
@synthesize player;
@synthesize volume;
@synthesize recorder;
@synthesize application;

@end
@implementation XAudioPlayer
@synthesize mediaId;

@end

@implementation XAudioRecorder
@synthesize mediaId;

@end

#pragma mark XAudioExt

@implementation XAudioExt

@synthesize soundCache;
@synthesize avSession;

- (void)play:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
#pragma unused(callback)
    id<XApplication> app = [self getApplication:options];
    NSString* mediaId = [arguments objectAtIndex:0];
    NSString* resourcePath = [arguments objectAtIndex:1];
    NSDictionary *jsOptions = [arguments objectAtIndex:2 withDefault:nil];

    BOOL bError = NO;
    NSString* jsString = nil;
    XAudioFile* audioFile = [self audioFileForResource:resourcePath withId:mediaId withPath:[app getWorkspace] isRecord:NO];
    if (audioFile != nil)
    {
        audioFile.application = app;
        [[self soundCache] setObject:audioFile forKey:mediaId];
        if (audioFile.player == nil)
        {
            //创建 audioFile.player
            bError = [self prepareToPlay:audioFile withId:mediaId];
        }
        if (!bError)
        {
            //设置允许在锁屏下播放 或在ring/silent切换下
            if ([self hasAudioSession])
            {
                NSError* __autoreleasing err = nil;
                //options可选参数 playAudioWhenScreenIsLocked是否允许在锁屏状态下播放
                NSNumber* playAudioWhenScreenIsLocked = [jsOptions objectForKey:@"playAudioWhenScreenIsLocked"];
                BOOL bPlayAudioWhenScreenIsLocked = YES;
                if (playAudioWhenScreenIsLocked != nil)
                {
                    bPlayAudioWhenScreenIsLocked = [playAudioWhenScreenIsLocked boolValue];
                }
                //AVAudioSessionCategoryPlayback 允许后台播放
                //AVAudioSessionCategorySoloAmbient 不允许
                NSString* sessionCategory = bPlayAudioWhenScreenIsLocked ? AVAudioSessionCategoryPlayback : AVAudioSessionCategorySoloAmbient;
                [self.avSession setCategory:sessionCategory error:&err];
                if (![self.avSession setActive:YES error:&err])
                {
                    // Unable to play audio
                    XLogE(@"Unable to play audio: %@", [err localizedFailureReason]);
                    bError = YES;
                }
            }

            if (!bError)
            {
                XLogI(@"Playing audio sample '%@'", audioFile.resourcePath);
                //options可选参数 numberOfLoops 播放次数
                NSNumber* loopOption = [jsOptions objectForKey:@"numberOfLoops"];
                NSInteger numberOfLoops = 0;
                if (loopOption != nil)
                {
                    numberOfLoops = [loopOption intValue] - 1;
                }
                audioFile.player.numberOfLoops = numberOfLoops;

                if (audioFile.player.isPlaying)
                {
                    [audioFile.player stop];
                    audioFile.player.currentTime = 0;
                }

                if (audioFile.volume != nil)
                {
                    audioFile.player.volume = [audioFile.volume floatValue];
                }

                [audioFile.player play];
                double position = round(audioFile.player.duration * 1000) / 1000;
                jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%.3f);\n%@(\"%@\",%d,%d);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_DURATION, position, @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_STATE, MEDIA_RUNNING];
                [self eavlJs:jsString by:app];
            }
        }

        if (bError)
        {
            jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_NONE_SUPPORTED message:nil]];
            [self eavlJs:jsString by:app];
        }
    }
    else//error
    {
        NSString* errMsg = [NSString stringWithFormat:@"Cannot use audio file from resource '%@'", resourcePath];
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_ABORTED message:errMsg]];
        [self eavlJs:jsString by:app];
    }
}

- (void)pause:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* mediaId = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    NSString* jsString = nil;
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];

    if ((audioFile != nil) && (audioFile.player != nil))
    {
        XLogI(@"Paused playing audio sample '%@'", audioFile.resourcePath);
        [audioFile.player pause];
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%d);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_STATE, MEDIA_PAUSED];
        [self eavlJs:jsString by:app];
    }
}

- (void)stop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* mediaId = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
    NSString* jsString = nil;

    if ((audioFile != nil) && (audioFile.player != nil))
    {
        XLogI(@"Stopped playing audio sample '%@'", audioFile.resourcePath);
        [audioFile.player stop];
        audioFile.player.currentTime = 0;
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%d);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_STATE, MEDIA_STOPPED];
        [self eavlJs:jsString by:app];
    }
}

- (void)seekTo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* mediaId = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
    double position = [[arguments objectAtIndex:1] doubleValue];

    if ((audioFile != nil) && (audioFile.player != nil) && position)
    {
        double posInSeconds = position / 1000;
        audioFile.player.currentTime = posInSeconds;
        NSString* jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%f);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_POSITION, posInSeconds];
        [self eavlJs:jsString by:app];
    }
}

- (void)release:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* mediaId = [arguments objectAtIndex:0];
    if (mediaId != nil)
    {
        XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
        if (audioFile != nil)
        {
            if (audioFile.player && [audioFile.player isPlaying])
            {
                [audioFile.player stop];
            }
            if (audioFile.recorder && [audioFile.recorder isRecording])
            {
                [audioFile.recorder stop];
            }
            if (self.avSession)
            {
                [self.avSession setActive:NO error:nil];
                self.avSession = nil;
            }
            [[self soundCache] removeObjectForKey:mediaId];
            XLogI(@"Media with id %@ released", mediaId);
        }
    }
}

- (void)getCurrentPosition:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSString* mediaId = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
#pragma unused(mediaId)
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
    double position = -1;

    if ((audioFile != nil) && (audioFile.player != nil) && [audioFile.player isPlaying])
    {
        position = round(audioFile.player.currentTime * 1000) / 1000;
    }
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsDouble:position];
    NSString* jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%.3f);\n%@", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_POSITION, position, [result toCallbackString:[callback callbackId]]];
    [self eavlJs:jsString by:app];
}

- (void)startRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
#pragma unused(callback)
    id<XApplication> app = [self getApplication:options];
    NSString* mediaId = [arguments objectAtIndex:0];
    NSString* resourcePath = [arguments objectAtIndex:1];

    XAudioFile* audioFile = [self audioFileForResource:resourcePath withId:mediaId withPath:[app getWorkspace] isRecord:YES];
    NSString* jsString = nil;
    NSString* errorMsg = @"";

    if (audioFile != nil)
    {
        audioFile.application = app;
        [[self soundCache] setObject:audioFile forKey:mediaId];
        NSError* __autoreleasing error = nil;
        if (audioFile.recorder != nil)
        {
            [audioFile.recorder stop];
            audioFile.recorder = nil;
        }

        //设置允许在锁屏下录音 或在ring/silent切换下
        if ([self hasAudioSession])
        {
            [self.avSession setCategory:AVAudioSessionCategoryRecord error:nil];
            if (![self.avSession setActive:YES error:&error])
            {
                // Unable to record audio
                errorMsg = [NSString stringWithFormat:@"Unable to record audio: %@", [error localizedFailureReason]];
                XLogE(@"Unable to record audio: %@", [error localizedFailureReason]);
                jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_ABORTED message:errorMsg]];
                [self eavlJs:jsString by:app];
                return;
            }
        }

        // create a new recorder for each start record
        NSError* err = nil;
        audioFile.recorder = [[XAudioRecorder alloc] initWithURL:audioFile.resourceURL settings:nil error:&err];

        if (err != nil)
        {
            XLogE(@"Failed to initialize AVAudioRecorder: %@\n", [err  localizedFailureReason]);
            errorMsg = [NSString stringWithFormat:@"Failed to initialize AVAudioRecorder: %@\n", [err  localizedFailureReason]];
            audioFile.recorder = nil;
            if (self.avSession)
            {
                [self.avSession setActive:NO error:nil];
            }
            jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_ABORTED message:errorMsg]];
        }
        else
        {
            audioFile.recorder.delegate = self;
            audioFile.recorder.mediaId = mediaId;
            [audioFile.recorder record];
            XLogI(@"Started recording audio sample '%@'", audioFile.resourcePath);
            jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%d);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_STATE, MEDIA_RUNNING];
        }
    }
    else
    {
        // file does not exist
        XLogE(@"Could not start recording audio, file '%@' does not exist.", audioFile.resourcePath);
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_ABORTED message:@"File to record to does not exist"]];
    }

    if (jsString)
    {
        [self eavlJs:jsString by:app];
    }
    return;
}

- (void)stopRecording:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString* mediaId = [arguments objectAtIndex:0];
    id<XApplication> app = [self getApplication:options];
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
    NSString* jsString = nil;

    if ((audioFile != nil) && (audioFile.recorder != nil))
    {
        XLogI(@"Stopped recording audio sample '%@'", audioFile.resourcePath);
        [audioFile.recorder stop];
        // then will call audioRecorderDidFinishRecording
    }

    if (jsString)
    {
        [self eavlJs:jsString by:app];
    }
}

- (void)setVolume:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];

#pragma unused(callback)
    NSString* mediaId = [arguments objectAtIndex:0];
    NSNumber* volume = [arguments objectAtIndex:1 withDefault:[NSNumber numberWithFloat:1.0]];

    XAudioFile* audioFile;
    if ([self soundCache] == nil)
    {
        [self setSoundCache:[NSMutableDictionary dictionaryWithCapacity:1]];
    }
    else
    {
        audioFile = [[self soundCache] objectForKey:mediaId];
        audioFile.volume = volume;
        [[self soundCache] setObject:audioFile forKey:mediaId];
    }
    //no callbacks
}

#pragma mark AVAudioRecorderDelegate

//audio record 完的回调
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag
{
    XAudioRecorder* aRecorder = (XAudioRecorder*)recorder;
    NSString* mediaId = aRecorder.mediaId;
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
    NSString* jsString = nil;

    if (audioFile != nil)
    {
        XLogI(@"Finished recording audio sample '%@'", audioFile.resourcePath);
    }

    if (flag)
    {
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%d);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_STATE, MEDIA_STOPPED];
    }
    else
    {
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_DECODE message:nil]];
    }

    if (self.avSession)
    {
        [self.avSession setActive:NO error:nil];
    }
    [self eavlJs:jsString by:audioFile.application];
}

//audio播放完的回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
    XAudioPlayer* aPlayer = (XAudioPlayer*)player;
    NSString* mediaId = aPlayer.mediaId;
    XAudioFile* audioFile = [[self soundCache] objectForKey:mediaId];
    NSString* jsString = nil;

    if (audioFile != nil)
    {
        XLogI(@"Finished playing audio sample '%@'", audioFile.resourcePath);
    }
    if (flag)
    {
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%d);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_STATE, MEDIA_STOPPED];
    }
    else
    {
        jsString = [NSString stringWithFormat:@"%@(\"%@\",%d,%@);", @"xFace.require('xFace/extension/Media').onStatus", mediaId, MEDIA_ERROR, [self createMediaErrorWithCode:MEDIA_ERR_DECODE message:nil]];
    }
    if (self.avSession)
    {
        [self.avSession setActive:NO error:nil];
    }
    [self eavlJs:jsString by:audioFile.application];
}

#pragma mark private methods

- (BOOL)hasAudioSession
{
    BOOL bSession = YES;

    if (!self.avSession)
    {
        NSError* error = nil;

        self.avSession = [AVAudioSession sharedInstance];
        if (error)
        {
            // is not fatal if can't get AVAudioSession , just log the error
            XLogE(@"error creating audio session: %@", [[error userInfo] description]);
            self.avSession = nil;
            bSession = NO;
        }
    }
    return bSession;
}

// Maps a url for a resource path
- (NSURL*)urlForResource:(NSString*)resourcePath withPath:(NSString*)workspace isRecord:(BOOL)isRecord
{
    NSURL* resourceURL = nil;
    NSString* filePath = nil;

    if ([resourcePath hasPrefix:HTTP_SCHEME_PREFIX] || [resourcePath hasPrefix:HTTPS_SCHEME_PREFIX])
    {
        // 网络资源
        XLogI(@"Will use resource '%@' from the Internet.", resourcePath);
        resourceURL = [NSURL URLWithString:resourcePath];
    }
    else if ([resourcePath hasPrefix:DOCUMENTS_SCHEME_PREFIX])
    {
        //将形如Documents://a/b -》 ~application/Documents/a/b
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        filePath = [resourcePath stringByReplacingOccurrencesOfString:DOCUMENTS_SCHEME_PREFIX withString:[NSString stringWithFormat:@"%@/", documentDirectory]];
        XLogI(@"Will use resource '%@' from the documents folder with path = %@", resourcePath, filePath);
    }
    else if ([resourcePath hasPrefix:FILE_SCHEME_PREFIX])
    {
        //file 协议开头的完整路径
        XLogI(@"Will use resource '%@' from the file://.", resourcePath);
        resourceURL = [NSURL URLWithString:resourcePath];
        filePath = [resourceURL path];
    }
    else
    {
        //都是相对workspace的相对路径，不能是 形如C:/a/bc 这种
        if(NSNotFound !=[resourcePath rangeOfString:@":"].location)
        {
            XLogE(@"error resourcePath '%@'", resourcePath);
            resourceURL = nil;
        }
        // 将相对路径filePath转到workspace下
        filePath = [XUtils resolvePath:resourcePath usingWorkspace:workspace];
        if (nil == filePath)
        {
            XLogE(@"error resourcePath '%@'", resourcePath);
            resourceURL = nil;
        }
    }

    // 检查本地文件存不存在将合法resourcePath转换为file协议
    if (filePath && [[filePath pathExtension] length])
    {
        //音频播放 指定的文件路径 文件必须存在，不能是文件夹，否则在返回nil
        NSFileManager* fMgr = [NSFileManager defaultManager];
        //录音情况 可以指定路径文件不存在
        if (![fMgr fileExistsAtPath:filePath])
        {
            if (isRecord)
            {
                resourceURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
            }
            else
            {
                resourceURL = nil;
                XLogE(@"Unknown resource '%@'", resourcePath);
            }
        }
        else
        {
            resourceURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
        }
    }
    return resourceURL;
}

- (XAudioFile*)audioFileForResource:(NSString*)resourcePath withId:(NSString*)mediaId withPath:(NSString*)workspace isRecord:(BOOL)isRecord
{
    BOOL bError = NO;
    XMediaError errcode = MEDIA_ERR_NONE_SUPPORTED;
    NSString* errMsg = @"";
    XAudioFile* audioFile = nil;
    NSURL* resourceURL = nil;

    if ([self soundCache] == nil)
    {
        [self setSoundCache:[NSMutableDictionary dictionaryWithCapacity:1]];
    }
    else
    {
        audioFile = [[self soundCache] objectForKey:mediaId];
    }

    if (audioFile == nil)
    {
        // check resourcePath and create
        if ((resourcePath == nil) || ![resourcePath isKindOfClass:[NSString class]] || [resourcePath length] == 0)
        {
            bError = YES;
            errcode = MEDIA_ERR_ABORTED;
            errMsg = @"invalid media src argument";
        }
        else
        {
            resourceURL = [self urlForResource:resourcePath withPath:workspace isRecord:isRecord];
        }

        if (resourceURL == nil)
        {
            bError = YES;
        }

        if (bError)
        {
            audioFile = nil;
        }
        else
        {
            audioFile = [[XAudioFile alloc] init];
            audioFile.resourcePath = [resourceURL path];
            audioFile.resourceURL = resourceURL;
        }
    }
    return audioFile;
}

- (BOOL)prepareToPlay:(XAudioFile*)audioFile withId:(NSString*)mediaId
{
    BOOL bError = NO;
    NSError* __autoreleasing playerError = nil;

    // create the player
    NSURL* resourceURL = audioFile.resourceURL;

    if ([resourceURL isFileURL])
    {
        audioFile.player = [[XAudioPlayer alloc] initWithContentsOfURL:resourceURL error:&playerError];
    }
    else
    {
        NSURLRequest* request = [NSURLRequest requestWithURL:resourceURL];
        NSURLResponse* __autoreleasing response = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&playerError];
        if (playerError)
        {
            XLogI(@"Unable to download audio from: %@", [resourceURL absoluteString]);
        }
        else
        {
            // bug in AVAudioPlayer when playing downloaded data in NSData
            //we have to download the file and play from disk
            CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
            CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
            NSString* filePath = [NSString stringWithFormat:@"%@/%@.mp3", [NSTemporaryDirectory ()stringByStandardizingPath], uuidString];
            CFRelease(uuidString);
            CFRelease(uuidRef);

            [data writeToFile:filePath atomically:YES];
            NSURL* fileURL = [NSURL fileURLWithPath:filePath];
            audioFile.player = [[XAudioPlayer alloc] initWithContentsOfURL:fileURL error:&playerError];
        }
    }

    if (playerError != nil)
    {
        XLogE(@"Failed to initialize AVAudioPlayer: %@\n", [playerError localizedDescription]);
        audioFile.player = nil;
        if (self.avSession)
        {
            [self.avSession setActive:NO error:nil];
        }
        bError = YES;
    }
    else
    {
        audioFile.player.mediaId = mediaId;
        audioFile.player.delegate = self;
        bError = ![audioFile.player prepareToPlay];
    }
    return bError;
}

- (NSString*)createMediaErrorWithCode:(XMediaError)code message:(NSString*)message
{
    NSMutableDictionary* errorDict = [NSMutableDictionary dictionaryWithCapacity:2];

    [errorDict setObject:[NSNumber numberWithUnsignedInt:code] forKey:@"code"];
    [errorDict setObject:message ? message:@"" forKey:@"message"];
    return [errorDict JSONString];
}

- (void)eavlJs:(NSString*)jsScript by:(id<XApplication>)app
{
    id<XAppView> appView = [app appView];
    if(jsScript)
    {
        [(XAppWebView *)appView stringByEvaluatingJavaScriptFromString:jsScript];
    }
}

- (void) onPageStarted:(NSString*)appId
{
    for (XAudioFile* audioFile in [[self soundCache] allValues]) {
        if (audioFile != nil) {
            if (audioFile.player != nil) {
                [audioFile.player stop];
                audioFile.player.currentTime = 0;
            }
            if (audioFile.recorder != nil) {
                [audioFile.recorder stop];
            }
        }
    }

    [[self soundCache] removeAllObjects];
}

@end

#endif
