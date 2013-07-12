
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
//  XAudioRecorderViewController_Privates.h
//  xFaceLib
//
//

#ifdef __XCaptureExt__

#import "XAudioRecorderViewController.h"
#import "XCaptureExt.h"

@class XExtensionResult;

@interface XAudioRecorderViewController ()

@property (nonatomic) CaptureError errorCode;
@property (nonatomic, strong) XJsCallback* jsCallback;
@property (nonatomic, copy) NSNumber* duration;
@property (nonatomic, strong) XCaptureExt* captureCommand;
@property (nonatomic, strong) UIBarButtonItem* doneButton;
@property (nonatomic, strong) UIView* recordingView;
@property (nonatomic, strong) UIButton* recordButton;
@property (nonatomic, strong) UIImage* recordImage;
@property (nonatomic, strong) UIImage* stopRecordImage;
@property (nonatomic, strong) UILabel* timerLabel;
@property (nonatomic, strong) AVAudioRecorder* avRecorder;
@property (nonatomic, strong) AVAudioSession* avSession;
@property (nonatomic, strong) XExtensionResult* result;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic) BOOL isTimed;

/**
    传入图片资源的名称，返回相应设备该使用的资源图片.
    @param resource 图片资源的名称
    @return 返回正确的图片资源字串
 */
- (NSString*) resolveImageResource:(NSString*)resource;

/**
    Record Button 事件的处理；录音的Start 和 Stop
    @param sender 消息发送
 */
- (void) processButton: (id) sender;

/*
    停止录音，并进行相关的清理工作
 */
- (void) stopRecordingCleanup;

/**
    Done Button pressed 解除AudioView
    @param sender 消息发送
 */
- (void) dismissAudioView: (id) sender;

/**
    格式时间串
    @param interval 时间
    @return 返回格式化后的时间串
 */
- (NSString *) formatTime: (int) interval;

/**
    更新时间显示
 */
- (void) updateTime;

/**
    创建AVAudioRecorder对象,为录音进行初始化工作
    @param filePath 用保存录音数据的文件的完整路径
 */
- (void) createAudioRecorder:(NSString*)filePath;

/**
    开始音频录制
 */
- (void) beginAudioRecord;

/**
    生成存储录音文件的完整路径,录音文件的名字以时间命名
    @return 录音文件的完整路径
 */
- (NSString*) generateFilePath;

@end

#endif
