
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
//  XAudioRecorderViewControllerLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAudioRecorderViewController.h"
#import "XAudioRecorderViewController_Privates.h"
#import "XCaptureExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XConstants.h"
#import "XApplication.h"
#import "XApplicationFactory.h"

@interface XAudioRecorderViewControllerLogicTests : SenTestCase
{
    @private
    XAudioRecorderViewController* audioRecorder;
}

@end

@implementation XAudioRecorderViewControllerLogicTests

- (void)setUp
{
    [super setUp];

    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XJavaScriptEvaluator *jsEvaluator = webApp.jsEvaluator;
    XCaptureExt *captureExt = [[XCaptureExt alloc] initWithMsgHandler:jsEvaluator];
    NSNumber* duration = nil;
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"CaptureAudio"];
    self->audioRecorder = [[XAudioRecorderViewController alloc] initWithCommand:captureExt duration:duration callback:callback];

    STAssertNotNil(self->audioRecorder, @"Failed to create XAudioRecorderViewController instance");
}

- (void) testResolveImageResource
{
    NSString* resourceName = [audioRecorder resolveImageResource:@"Capture.bundle/microphone"];
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    BOOL isLessThaniOS4 = ([systemVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedAscending);
    if (isLessThaniOS4)
    {
        if (IS_IPAD)
        {
            STAssertEqualObjects(resourceName, @"Capture.bundle/microphone~ipad.png", nil);
        }
        else
        {
            STAssertEqualObjects(resourceName, @"Capture.bundle/microphone.png", nil);
        }
    }
}

- (void) testProcessButton
{
    STAssertNoThrow([audioRecorder processButton:nil],nil);
}

- (void) testStopRecordingCleanup
{
    STAssertNoThrow([audioRecorder stopRecordingCleanup],nil);
}

- (void) testDismissAudioView
{
    STAssertNoThrow([audioRecorder dismissAudioView:nil],nil);;
}

- (void) testFormatTime
{
    NSString* timeStr = [audioRecorder formatTime:90];
    STAssertEqualObjects(@"1:30", timeStr, nil);
}

- (void) testUpdateTime
{
    STAssertNoThrow([audioRecorder updateTime],nil);
}

- (void) testCreateRecorder
{
    NSString* filePath = [audioRecorder generateFilePath];
    STAssertNotNil(filePath, nil);
    STAssertNoThrow([audioRecorder createAudioRecorder:filePath], nil);
}

- (void) testBeginAudioRecord
{
    STAssertNoThrow([audioRecorder beginAudioRecord], nil);
}

- (void) testGenerateFilePath
{
    NSString* filePath = [audioRecorder generateFilePath];
    STAssertNotNil(filePath, nil);
}

@end
