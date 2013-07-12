
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
//  XCaptureExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XCaptureExt.h"
#import "XCaptureExt_Privates.h"
#import "XAudioRecorderViewController.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XExtensionResult.h"
#import "XJsCallback+ExtensionResult.h"
#import "XConstants.h"
#import "XApplication.h"

@interface XCaptureExtApplicationTests : XApplicationTests
{
    @private
    XCaptureExt* captureExt;
}
@end

@implementation XCaptureExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->captureExt = [[XCaptureExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->captureExt, @"Failed to create captureExt extension instance");
}

- (void) testCaptureAudio
{
    //创建测试环境
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"captureAudio"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableDictionary* jsOptions = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSNumber* duration = [NSNumber numberWithInt:30];
    [jsOptions setObject:duration forKey:@"duration"];
    [arguments addObject:jsOptions];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->captureExt captureAudio:arguments withDict:options],nil);

    //不支持音频录制
    if (nil == NSClassFromString(@"AVAudioRecorder"))
    {
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
        STAssertEqualObjects([result status], [[callback getXExtensionResult] status], nil);
        STAssertEqualObjects([result message], [[callback getXExtensionResult] message], nil);
    }
}

- (void) testCaptureImage
{
    //创建测试环境
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"captureImage"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    [arguments addObject:[NSNull null]];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    STAssertNoThrow([self->captureExt captureImage:arguments withDict:options],nil);

    //不支持camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        XExtensionResult *result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
        STAssertEqualObjects([result status], [[callback getXExtensionResult] status], nil);
        STAssertEqualObjects([result message], [[callback getXExtensionResult] message], nil);
    }
}

- (void) testCaptureVideo
{
    //创建测试环境
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"captureVideo"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    [arguments addObject:[NSNull null]];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    STAssertNoThrow([self->captureExt captureVideo:arguments withDict:options],nil);

    //没有camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
        STAssertEqualObjects([result status], [[callback getXExtensionResult] status], nil);
        STAssertEqualObjects([result message], [[callback getXExtensionResult] message], nil);
    }
    else//有摄像头，但不支持视频录制
    {
        NSString* mediaType = nil;
        NSArray* types = nil;
        if ([UIImagePickerController respondsToSelector: @selector(availableMediaTypesForSourceType:)])
        {
            types = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            if ([types containsObject:@"public.movie"])
            {
                mediaType = @"public.movie";
            }
            else if ([types containsObject:@"public.video"])
            {
                mediaType = @"public.video";
            }
        }
        if (!mediaType)
        {
            XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
            STAssertEqualObjects([result status], [[callback getXExtensionResult] status], nil);
            STAssertEqualObjects([result message], [[callback getXExtensionResult] message], nil);
        }
    }
}

- (void) testGetMediaModes
{
    //创建测试环境
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"getMediaModes"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    [arguments addObject:[NSNull null]];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->captureExt getMediaModes:arguments withDict:options],nil);
}

- (void) testGetFormatData
{
    //创建测试环境
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"getFormatData"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    NSString* fullPath = [[NSBundle mainBundle] pathForResource:@"xface_logo" ofType:@"png"];
    [arguments addObject:fullPath];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];

    STAssertNoThrow([self->captureExt getFormatData:arguments withDict:options],nil);
}

- (void) testOpenCaptureAudioView
{
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"captureAudio"];
    NSNumber* duration = [[NSNumber alloc] initWithInt:30];
    STAssertNoThrow([self->captureExt openCaptureAudioView:duration callback:callback],nil);
    STAssertNoThrow([self->captureExt openCaptureAudioView:nil callback:callback],nil);
}

- (void) testOpenCaptureImageView
{
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"captureImage"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        STAssertNoThrow([self->captureExt openCaptureImageView:nil callback:callback],nil);
    }
}

- (void) testGetCaptureVideoSupportMediaType
{
    NSString* mediaType = [self->captureExt getCaptureVideoSupportMediaType];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSArray* types = nil;
        if ([UIImagePickerController respondsToSelector: @selector(availableMediaTypesForSourceType:)])
        {
            types = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            if ([types containsObject:@"public.movie"])
            {
                STAssertEqualObjects(@"public.movie", mediaType, nil);
            }
            else if ([types containsObject:@"public.video"])
            {
                STAssertEqualObjects(@"public.video", mediaType, nil);
            }
        }
    }
    else
    {
        STAssertNil(mediaType, nil);
    }
}

- (void) testOpenCaptureVideoView
{
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"captureVideo"];
    NSString* mediaType = [self->captureExt getCaptureVideoSupportMediaType];
    if (mediaType)
    {
        STAssertNoThrow([self->captureExt openCaptureVideoView:mediaType callback:callback], nil);
    }
}

@end
