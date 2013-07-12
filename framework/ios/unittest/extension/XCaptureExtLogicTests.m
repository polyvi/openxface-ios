
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
//  XCaptureExtLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XCaptureExt.h"
#import "XCaptureExt_Privates.h"
#import "XAudioRecorderViewController.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "NSObject+JSONSerialization.h"
#import "XJsCallback.h"
#import "XApplication.h"
#import "XApplicationFactory.h"

@interface XCaptureExtLogicTests : SenTestCase
{
    @private
    XCaptureExt* captureExt;
}
@end

@implementation XCaptureExtLogicTests

- (void)setUp
{
    [super setUp];
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:@"appId"];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XJavaScriptEvaluator *jsEvaluator = webApp.jsEvaluator;
    self->captureExt = [[XCaptureExt alloc] initWithMsgHandler:jsEvaluator];
    STAssertNotNil(self->captureExt, @"Failed to create capture extension instance");
}

-(void) testGetMediaDictionaryFromPath
{
    NSString* tmpPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSString* fullPath = [NSString stringWithFormat:@"%@/image.png",tmpPath];
    STAssertNoThrow([captureExt getMediaDictionaryFromPath:fullPath ofType:@"image/png"],nil);
    NSDictionary* fileDict = [captureExt getMediaDictionaryFromPath:fullPath ofType:@"image/png"];
    STAssertNotNil(fileDict, nil);
}

-(void) testCaptureAudioResult
{
    NSString *callbackId = @"Capture0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"CaptureAudio"];
    STAssertNoThrow([captureExt captureAudioResult:callback],nil);
}

-(void) testProcessImage
{
    UIImage* image = [[UIImage alloc] init];
    STAssertNoThrow([captureExt processImage:image type:@"image/png"],nil);
    XExtensionResult* result = [captureExt processImage:image type:@"image/png"];
    STAssertNotNil(result, nil);
}

-(void) testProcessVideo
{
    NSString* moviePath = [NSTemporaryDirectory() stringByStandardizingPath];
    STAssertNoThrow([captureExt processVideo:moviePath],nil);
    XExtensionResult* result = [captureExt processVideo:moviePath];
    STAssertNotNil(result, nil);
}

-(void) testGetMediaTypeFromFullPath
{
    NSString* tmpPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSString* fullPath = [NSString stringWithFormat:@"%@/audio.wav",tmpPath];
    STAssertNoThrow([captureExt getMediaTypeFromFullPath:fullPath], nil);
    STAssertEqualObjects(@"audio/wav", [captureExt getMediaTypeFromFullPath:fullPath], nil);
}

-(void)testResolveDestPath
{
    NSString* jpgPath = @"/var/test/test.jpg";
    NSString* pngPath = @"/var/test/test.png";
    NSString* noneExtensionPath = @"/var/test/test";
    NSString* nilPath = nil;
    NSString* emptyPath = @"";
    STAssertTrue([[captureExt resolveDestPath:jpgPath] length] > 0, nil);
    STAssertTrue([[captureExt resolveDestPath:pngPath] length] > 0, nil);

    NSString* resolvedPath = [captureExt resolveDestPath:noneExtensionPath];
    STAssertTrue([[resolvedPath pathExtension] isEqualToString:@"jpg"], nil);

    resolvedPath = [captureExt resolveDestPath:emptyPath];
    STAssertTrue([[resolvedPath pathExtension] isEqualToString:@"jpg"], nil);

    resolvedPath = [captureExt resolveDestPath:nilPath];
    STAssertTrue([[resolvedPath pathExtension] isEqualToString:@"jpg"], nil);

}

-(void)testResolveImageType
{
    NSString* jpgPath = @"/var/test/test.jpg";
    NSString* pngPath = @"/var/test/test.png";
    NSString* unknownExtensionPath = @"/var/test/test.unknown";
    NSString* noneExtensionPath = @"/var/test/test";
    STAssertTrue([captureExt resolveImageTypeByPath:jpgPath] == kImageTypeJPEG, nil);
    STAssertTrue([captureExt resolveImageTypeByPath:pngPath] == kImageTypePNG, nil);
    STAssertTrue([captureExt resolveImageTypeByPath:unknownExtensionPath] == kImageTypeUnknown, nil);
    STAssertTrue([captureExt resolveImageTypeByPath:noneExtensionPath] == kImageTypeUnknown, nil);
}

-(void)testResolveTargetRect
{
    CGRect defaultRect = CGRectMake(0, 0, 320, 460);
    CGRect targetRect = CGRectMake(0, 0, 0, 0);

    targetRect= [captureExt resolveTargetRect:targetRect withDefaultRect:defaultRect];
    STAssertTrue(CGRectEqualToRect(targetRect, defaultRect), nil);

    targetRect = CGRectMake(1, 1, 0, 0);

    targetRect= [captureExt resolveTargetRect:targetRect withDefaultRect:defaultRect];
    STAssertTrue(!CGRectIsEmpty(targetRect), nil);

    targetRect = CGRectMake(0, 0, -1, -1);

    targetRect= [captureExt resolveTargetRect:targetRect withDefaultRect:defaultRect];
    STAssertTrue(CGRectIsEmpty(targetRect), nil);

    targetRect = CGRectMake(-3, -3, 3, 3);

    targetRect= [captureExt resolveTargetRect:targetRect withDefaultRect:defaultRect];
    STAssertTrue(CGRectIsEmpty(targetRect), nil);
}

@end
