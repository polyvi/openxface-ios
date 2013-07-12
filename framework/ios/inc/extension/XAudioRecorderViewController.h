
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
//  XAudioRecorderViewController.h
//  xFaceLib
//
//

#ifdef __XCaptureExt__

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class XJsCallback;
@class XCaptureExt;

@interface XAudioRecorderViewController : UIViewController <AVAudioRecorderDelegate>
{
}

/**
    初始化方法
    @param theCommand 扩展命令对象
    @param theDuration 录音时间
    @param theCallback 回调
    @return 初始化后的XAudioRecorderViewController对象，用于管理captureAudio view；如果初始化失败，则返回nil
 */
- (id) initWithCommand: (XCaptureExt*) theCommand duration: (NSNumber*) theDuration callback: (XJsCallback*) theCallback;

@end

@interface XAudioNavigationController : UINavigationController

@end

#endif
