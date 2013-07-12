
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
//  XAudioRecorderViewController.m
//  xFaceLib
//
//

#ifdef __XCaptureExt__

#import "XAudioRecorderViewController.h"
#import "XAudioRecorderViewController_Privates.h"
#import "XCaptureExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XConstants.h"

#define VERSION4                            @"4.0"
#define MICROPHONE_IMAGE_RESOURCE_NAME      @"Capture.bundle/microphone"
#define GRAYBG_IMAGE_RESOURCE_NAME          @"Capture.bundle/controls_bg"
#define RECORDINGBG_IMAGE_RESOURCE_NAME     @"Capture.bundle/recording_bg"
#define RECORD_IMAGE_RESOURCE_NAME          @"Capture.bundle/record_button"
#define STOPRECORD_IMAGE_RESOURCE_NAME      @"Capture.bundle/stop_button"
#define AUDIO_TYPE                          @"audio/wav"

@implementation XAudioNavigationController

- (NSUInteger)supportedInterfaceOrientations
{
    // delegate to XAudioRecorderViewController
    return [self.topViewController supportedInterfaceOrientations];
}

@end

@implementation XAudioRecorderViewController

@synthesize errorCode;
@synthesize jsCallback;
@synthesize duration;
@synthesize captureCommand;
@synthesize doneButton;
@synthesize recordingView;
@synthesize recordButton;
@synthesize recordImage;
@synthesize stopRecordImage;
@synthesize timerLabel;
@synthesize avRecorder;
@synthesize avSession;
@synthesize result;
@synthesize timer;
@synthesize isTimed;

- (NSString*) resolveImageResource:(NSString*)resource
{
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    BOOL isLessThaniOS4 = ([systemVersion compare:VERSION4 options:NSNumericSearch] == NSOrderedAscending);

    // the iPad image (nor retina) differentiation code was not in 3.x, and we have to explicitly set the path
    // if user wants iPhone only app to run on iPad they must remove *~ipad.* images from capture.bundle
    if (isLessThaniOS4)
    {
        NSString* iPadResource = [NSString stringWithFormat:@"%@~ipad.png", resource];
        if (IS_IPAD && [UIImage imageNamed:iPadResource])
        {
            return iPadResource;
        }
        else
        {
            return [NSString stringWithFormat:@"%@.png", resource];
        }
    }
    return resource;
}

- (id) initWithCommand:  (XCaptureExt*) theCommand duration: (NSNumber*) theDuration callback:(XJsCallback *)theCallback
{
    if ((self = [super init]))
    {
        self.captureCommand = theCommand;
        self.duration = theDuration;
        self.jsCallback = theCallback;
        self.errorCode = CAPTURE_NO_MEDIA_FILES;
        self.isTimed = self.duration != nil;
        return self;
    }
    return nil;
}

- (void)loadView
{
    // create view and display
    CGRect viewRect = [[UIScreen mainScreen] applicationFrame];
    UIView *tmp = [[UIView alloc] initWithFrame:viewRect];

    // make backgrounds
    UIImage* microphone = [UIImage imageNamed:[self resolveImageResource:MICROPHONE_IMAGE_RESOURCE_NAME]];
    UIView* microphoneView = [[UIView alloc] initWithFrame: CGRectMake(0,0,viewRect.size.width, microphone.size.height)];
    [microphoneView setBackgroundColor:[UIColor colorWithPatternImage:microphone]];
    [microphoneView setUserInteractionEnabled: NO];
    [microphoneView setIsAccessibilityElement:NO];
    [tmp addSubview:microphoneView];

    // add bottom bar view
    UIImage* grayBkg = [UIImage imageNamed: [self resolveImageResource:GRAYBG_IMAGE_RESOURCE_NAME]];
    UIView* controls = [[UIView alloc] initWithFrame:CGRectMake(0, microphone.size.height, viewRect.size.width,grayBkg.size.height )];
    [controls setBackgroundColor:[UIColor colorWithPatternImage: grayBkg]];
    [controls setUserInteractionEnabled: NO];
    [controls setIsAccessibilityElement:NO];
    [tmp addSubview:controls];

    // make red recording background view
    UIImage* recordingBkg = [UIImage imageNamed: [self resolveImageResource:RECORDINGBG_IMAGE_RESOURCE_NAME]];
    UIColor *background = [UIColor colorWithPatternImage:recordingBkg];
    self.recordingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, viewRect.size.width, recordingBkg.size.height)];
    [self.recordingView setBackgroundColor:background];
    [self.recordingView setHidden:YES];
    [self.recordingView setUserInteractionEnabled: NO];
    [self.recordingView setIsAccessibilityElement:NO];
    [tmp addSubview:self.recordingView];

    // add label
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewRect.size.width,recordingBkg.size.height)];
    [self.timerLabel setBackgroundColor:[UIColor clearColor]];
    [self.timerLabel setTextColor:[UIColor whiteColor]];
    [self.timerLabel setTextAlignment: UITextAlignmentCenter];
    [self.timerLabel setText:@"0:00"];
    [self.timerLabel setAccessibilityHint:NSLocalizedString(@"recorded time in minutes and seconds", nil)];
    self.timerLabel.accessibilityTraits |=  UIAccessibilityTraitUpdatesFrequently;
    self.timerLabel.accessibilityTraits &= ~UIAccessibilityTraitStaticText;
    [tmp addSubview:self.timerLabel];

    // Add record button
    self.recordImage = [UIImage imageNamed: [self resolveImageResource:RECORD_IMAGE_RESOURCE_NAME]];
    self.stopRecordImage = [UIImage imageNamed: [self resolveImageResource:STOPRECORD_IMAGE_RESOURCE_NAME]];
    self.recordButton.accessibilityTraits |= [self accessibilityTraits];
    self.recordButton = [[UIButton alloc  ] initWithFrame: CGRectMake((viewRect.size.width - recordImage.size.width)/2 , (microphone.size.height + (grayBkg.size.height - recordImage.size.height)/2), recordImage.size.width, recordImage.size.height)];
    [self.recordButton setAccessibilityLabel:  NSLocalizedString(@"toggle audio recording", nil)];
    [self.recordButton setImage: recordImage forState:UIControlStateNormal];
    [self.recordButton addTarget: self action:@selector(processButton:) forControlEvents:UIControlEventTouchUpInside];
    [tmp addSubview:recordButton];

    // make and add done button to navigation bar
    self.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAudioView:)];
    [self.doneButton setStyle:UIBarButtonItemStyleDone];
    self.navigationItem.rightBarButtonItem = self.doneButton;

    [self setView:tmp];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);

    if (self.avSession == nil)
    {
        // create audio session
        self.avSession = [AVAudioSession sharedInstance];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    //FixMe: 为减小ipa的大小,限制只支持竖屏
    NSUInteger orientation = UIInterfaceOrientationMaskPortrait; // must support portrait
    NSUInteger supported = [captureCommand.viewController supportedInterfaceOrientations];

    orientation = orientation | (supported & UIInterfaceOrientationMaskPortraitUpsideDown);
    return orientation;
}

- (void)viewDidUnload
{
    [self setView:nil];
    [self.captureCommand setInUse: NO];
}

- (void) processButton:(id)sender
{
    if (self.avRecorder.recording)
    {
        // stop recording
        [self.avRecorder stop];
        // recording was stopped via button so reset isTimed
        self.isTimed = NO;
    }
    else
    {

        NSString* filePath = [self generateFilePath];
        [self createAudioRecorder:filePath];
        [self beginAudioRecord];
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
}

// helper method to clean up when stop recording
- (void) stopRecordingCleanup
{
    if (self.avRecorder.recording)
    {
        [self.avRecorder stop];
    }
    [self.recordButton setImage: recordImage forState:UIControlStateNormal];
    self.recordButton.accessibilityTraits |= [self accessibilityTraits];
    [self.recordingView setHidden:YES];
    self.doneButton.enabled = YES;
    if (self.avSession)
    {
        // deactivate session so sounds can come through
        [self.avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.avSession  setActive: NO error: nil];
    }
    if (self.duration && self.isTimed)
    {
        // VoiceOver announcement so user knows timed recording has finished
        BOOL isUIAccessibilityAnnouncementNotification = (&UIAccessibilityAnnouncementNotification != NULL);
        if (isUIAccessibilityAnnouncementNotification)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500ull * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"timed recording complete", nil));
			});
        }
    }
    else
    {
        // issue a layout notification change so that VO will reannounce the button label when recording completes
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    }
}

- (void) dismissAudioView: (id) sender
{
    // called when done button pressed or when error condition to do cleanup and remove view
    [[self.captureCommand.viewController.presentedViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];

    if (!self.result)
    {
        // return error
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:self.errorCode];
    }

    self.avRecorder = nil;
    [self.avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.avSession  setActive: NO error: nil];
    [self.captureCommand setInUse:NO];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);

    [jsCallback setExtensionResult:result];
    // return result
    [self.captureCommand captureAudioResult:jsCallback];
}

- (void) updateTime
{
    // update the label with the ellapsed time
    [self.timerLabel setText:[self formatTime: self.avRecorder.currentTime]];
}

- (NSString *) formatTime: (int) interval
{
    // is this format universal?
    int secs = interval % 60;
    int min = interval / 60;
    if (interval < 60)
    {
        return [NSString stringWithFormat:@"0:%02d", interval];
    }
    else
    {
        return	[NSString stringWithFormat:@"%d:%02d", min, secs];
    }
}

- (void) createAudioRecorder:(NSString*)filePath
{
    NSError* err = nil;
    NSURL* fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    // create AVAudioPlayer
    self.avRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:nil error:&err];
    if (err)
    {
        XLogE(@"Failed to initialize AVAudioRecorder: %@\n", [err localizedDescription]);
		self.avRecorder = nil;
        // return error
        self.errorCode = CAPTURE_INTERNAL_ERR;
        [self dismissAudioView: nil];

    }
    else
    {
        self.avRecorder.delegate = self;
        [self.avRecorder prepareToRecord];
        self.recordButton.enabled = YES;
        self.doneButton.enabled = YES;
    }
}

- (void) beginAudioRecord
{
    [self.recordButton setImage: stopRecordImage forState:UIControlStateNormal];
    self.recordButton.accessibilityTraits &= ~[self accessibilityTraits];
    [self.recordingView setHidden:NO];
    NSError* error = nil;
    [self.avSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [self.avSession  setActive: YES error: &error];
    if(error)
    {
        // can't continue without active audio session
        self.errorCode = CAPTURE_INTERNAL_ERR;
        [self dismissAudioView: nil];
    }
    else
    {
        if(self.duration)
        {
            self.isTimed = true;
            [self.avRecorder recordForDuration: [duration doubleValue]];
        }
        else
        {
            [self.avRecorder record];
        }
        [self.timerLabel setText:@"0.00"];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target: self selector:@selector(updateTime) userInfo:nil repeats:YES ];
        self.doneButton.enabled = NO;
    }
}

- (NSString*) generateFilePath
{
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSDate* nowDate = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString* dateString = [dateFormatter stringFromDate:nowDate];

    NSString* filePath = [NSString stringWithFormat:@"%@/%@.%@", docsPath, dateString, @"wav"];
    return filePath;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag
{
    // may be called when timed audio finishes - need to stop time and reset buttons
    [self.timer invalidate];
    [self stopRecordingCleanup];

    // generate success result
    if (flag)
    {
        NSString* filePath = [avRecorder.url path];
        NSDictionary* fileDict = [captureCommand getMediaDictionaryFromPath:filePath ofType: AUDIO_TYPE];
        NSArray* fileArray = [NSArray arrayWithObject:fileDict];

        result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: fileArray];
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_INTERNAL_ERR];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [self.timer invalidate];
    [self stopRecordingCleanup];

    XLogE(@"error recording audio");
    result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_INTERNAL_ERR];
    [self dismissAudioView: nil];
}

@end

#endif
