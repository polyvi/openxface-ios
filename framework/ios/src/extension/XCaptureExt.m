
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
//  XCaptureExt.m
//  xFaceLib
//
//

#ifdef __XCaptureExt__

#import "XCaptureExt.h"
#import "XCaptureExt_Privates.h"
#import "XAudioRecorderViewController.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XRootViewController.h"
#import "NSObject+JSONSerialization.h"
#import "XJsCallback.h"
#import "XBase64Data.h"
#import "XQueuedMutableArray.h"
#import "XApplication.h"

@implementation UIImage (Crop)

- (UIImage*)crop:(CGRect)rect
{

    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);

    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

+ (UIImage*)imageFromView:(UIView*)view
{
    //预留空白的区域。
    CGSize size = view.frame.size;
    size.height += view.frame.origin.y;
    size.width += view.frame.origin.x;

    UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    //裁掉之前预留的空白的区域。
    image = [image crop:view.frame];
    UIGraphicsEndImageContext();
    return image;
}

@end

#define kW3CMediaFormatHeight   @"height"
#define kW3CMediaFormatWidth    @"width"
#define kW3CMediaFormatCodecs   @"codecs"
#define kW3CMediaFormatBitrate  @"bitrate"
#define kW3CMediaFormatDuration @"duration"
#define kW3CMediaModeType       @"type"

#pragma mark XImagePicker

@implementation XImagePicker

@synthesize  quality;
@synthesize  jsCallback;
@synthesize  mimeType;

- (uint64_t) accessibilityTraits
{
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    if (([systemVersion compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending))
    {
        // this means system version is not less than 4.0
        return UIAccessibilityTraitStartsMediaSession;
    }
    return UIAccessibilityTraitNone;
}

@end

#pragma mark XCaptureExt
@implementation XCaptureExt

@synthesize inUse;
@synthesize pickerController;

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if(self)
    {
        self.inUse = NO;
    }
    return self;
}

- (void) captureAudio:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSDictionary *jsOptions = [arguments objectAtIndex:0];
    if([jsOptions isEqual:[NSNull null]])
    {
        jsOptions = nil;
    }
    NSNumber* duration = [jsOptions objectForKey:@"duration"];
    // the default value of duration is 0 so use nil (no duration) if default value
    if (duration)
    {
        duration = [duration doubleValue] == 0 ? nil : duration;
    }
    XExtensionResult *result = nil;

    if (NSClassFromString(@"AVAudioRecorder") == nil)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
    }
    else if (self.inUse == YES)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_APPLICATION_BUSY];
    }
    else
    {
        // 打开录音界面,录音的相关工作发生在这里
        [self openCaptureAudioView:duration callback:callback];
    }

    if (result)
    {
        [callback setExtensionResult:result];
        // 将扩展结果返回给js端
        [self->jsEvaluator eval:callback];
    }
}

- (void) openCaptureAudioView: (NSNumber*) theDuration callback: (XJsCallback*) theCallback
{
    XAudioRecorderViewController* audioViewController = [[XAudioRecorderViewController alloc] initWithCommand:self duration:theDuration callback:theCallback];

    // Now create a nav controller and display the view...
    XAudioNavigationController* navController = [[XAudioNavigationController alloc] initWithRootViewController:audioViewController];
    self.inUse = YES;

    [self.viewController presentViewController:navController animated:YES completion:nil];
}

- (void) captureImage:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSDictionary *jsOptions = [arguments objectAtIndex:0];
    if([jsOptions isEqual:[NSNull null]])
    {
        jsOptions = nil;
    }
    NSString* mode = [jsOptions objectForKey:@"mode"];
    XExtensionResult *result = nil;

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        XLogW(@"Capture.imageCapture: camera not available.");
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
        [callback setExtensionResult:result];
        // 将扩展结果返回给js端
        [self->jsEvaluator eval:callback];
    }
    else
    {
        //打开照相界面
        [self openCaptureImageView:mode callback:callback];
    }
}

- (void) openCaptureImageView:(NSString*)mode callback: (XJsCallback*) theCallback
{
    if (pickerController == nil)
    {
        pickerController = [[XImagePicker alloc] init];
    }
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.allowsEditing = NO;
    pickerController.mediaTypes = [NSArray arrayWithObjects: (NSString*) kUTTypeImage, nil];

    // XImagePicker specific property
    pickerController.jsCallback = theCallback;
    pickerController.mimeType = mode;

    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

- (void) captureVideo:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];

    //options could contain limit, duration and mode, only duration is supported (but is not due to apple bug)
    // taking more than one video (limit) is only supported if provide own controls via cameraOverlayView property

    NSString* mediaType = [self getCaptureVideoSupportMediaType];
    XExtensionResult *result = nil;
    if (!mediaType)
    {
        // don't have video camera return error
        XLogW(@"Capture.captureVideo: video mode not available.");
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];

        [callback setExtensionResult:result];
        // 将扩展结果返回给js端
        [self->jsEvaluator eval:callback];

    }
    else
    {
        //打开录制视频界面
        [self openCaptureVideoView:mediaType callback:callback];
    }
}

- (NSString*) getCaptureVideoSupportMediaType
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSArray* types = nil;
        if ([UIImagePickerController respondsToSelector: @selector(availableMediaTypesForSourceType:)])
        {
            types = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            if ([types containsObject:(NSString*)kUTTypeMovie])
            {
                return (NSString*)kUTTypeMovie;
            }
            else if ([types containsObject:(NSString*)kUTTypeVideo])
            {
                return (NSString*)kUTTypeVideo;
            }
        }
    }
    return nil;
}

- (void) openCaptureVideoView:(NSString*)mediaType callback: (XJsCallback*) theCallback
{
    if (pickerController == nil)
    {
        pickerController = [[XImagePicker alloc] init];
    }

    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.allowsEditing = NO;
    pickerController.mediaTypes = [NSArray arrayWithObjects:mediaType, nil];

    pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    // XImagePicker specific property
    pickerController.jsCallback = theCallback;

    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

- (void) getMediaModes: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSArray* imageArray = nil;
    NSArray* movieArray = nil;
    NSArray* audioArray = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {

        // there is a camera, find the modes
        // can get image/jpeg or image/png from camera
        // can't find a way to get the default height and width and other info
        // for images/movies taken with UIImagePickerController

        NSDictionary* jpg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:0], kW3CMediaFormatHeight,
                             [NSNumber numberWithInt:0], kW3CMediaFormatWidth,
                             @"image/jpeg", kW3CMediaModeType,
                             nil];
        NSDictionary* png = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:0], kW3CMediaFormatHeight,
                             [NSNumber numberWithInt:0], kW3CMediaFormatWidth,
                             @"image/png", kW3CMediaModeType,
                             nil];
        imageArray = [NSArray arrayWithObjects:jpg, png, nil];

        if ([UIImagePickerController respondsToSelector: @selector(availableMediaTypesForSourceType:)])
        {
            NSArray* types = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

            if ([types containsObject:(NSString*)kUTTypeMovie])
            {
                NSDictionary* mov = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:0], kW3CMediaFormatHeight,
                                     [NSNumber numberWithInt:0], kW3CMediaFormatWidth,
                                     @"video/quicktime", kW3CMediaModeType,
                                     nil];
                movieArray = [NSArray arrayWithObject:mov];
            }
        }
    }
    NSDictionary* modes = [NSDictionary dictionaryWithObjectsAndKeys:
                           imageArray ? (NSObject*)imageArray : [NSNull null], @"image",
                           movieArray ? (NSObject*)movieArray : [NSNull null], @"video",
                           audioArray ? (NSObject*)audioArray : [NSNull null], @"audio",
                           nil];
    NSString* jsString = [NSString stringWithFormat:@"navigator.device.capture.setSupportedModes(%@);", [modes JSONString]];

    [callback setJsScript:jsString];
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:callback];
}

- (void) getFormatData: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    // existence of fullPath checked on JS side
    NSString* fullPath = [arguments objectAtIndex:0];
    // mimeType could be empty/null
    NSString* mimeType = nil;
    if ([arguments count] >= 2)
    {
        if ( [NSNull null] != [arguments objectAtIndex:1])
        {
           mimeType = [arguments objectAtIndex:1];
        }
    }
    BOOL bError = NO;
    CaptureError errorCode = CAPTURE_INTERNAL_ERR;
    XExtensionResult* result = nil;

    if(!mimeType)
    {
        mimeType = [self getMediaTypeFromFullPath:fullPath];
        if (!mimeType)
        {
            // can't do much without mimeType, return error
            bError = YES;
            errorCode = CAPTURE_INVALID_ARGUMENT;
        }
    }

    if (!bError)
    {
        // create and initialize return dictionary
        NSMutableDictionary* formatData = [NSMutableDictionary dictionaryWithCapacity:5];
        [formatData setObject:[NSNull null] forKey: kW3CMediaFormatCodecs];
        [formatData setObject:[NSNumber numberWithInt:0] forKey: kW3CMediaFormatBitrate];
        [formatData setObject:[NSNumber numberWithInt:0] forKey: kW3CMediaFormatHeight];
        [formatData setObject:[NSNumber numberWithInt:0] forKey: kW3CMediaFormatWidth];
        [formatData setObject:[NSNumber numberWithInt:0] forKey: kW3CMediaFormatDuration];

        if ([mimeType rangeOfString:@"image/"].location != NSNotFound)
        {
            UIImage* image = [UIImage imageWithContentsOfFile:fullPath];
            if (image)
            {
                CGSize imgSize = [image size];
                [formatData setObject:[NSNumber numberWithInteger: imgSize.width] forKey: kW3CMediaFormatWidth];
                [formatData setObject:[NSNumber numberWithInteger: imgSize.height] forKey: kW3CMediaFormatHeight];
            }
        }
        else if ([mimeType rangeOfString: @"video/"].location != NSNotFound && NSClassFromString(@"AVURLAsset") != nil)
        {
            NSURL* movieURL = [NSURL fileURLWithPath: fullPath];
            AVURLAsset* movieAsset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
            CMTime duration = [movieAsset duration];
            [formatData setObject:[NSNumber numberWithFloat:CMTimeGetSeconds(duration)]  forKey: kW3CMediaFormatDuration];
            NSArray* tracks = [movieAsset tracks];
            CGSize size = [tracks count] != 0 ? [[tracks objectAtIndex:0] naturalSize] : CGSizeMake(0, 0);
            [formatData setObject:[NSNumber numberWithFloat: size.height] forKey: kW3CMediaFormatHeight];
            [formatData setObject:[NSNumber numberWithFloat: size.width] forKey: kW3CMediaFormatWidth];
        }
        else if ([mimeType rangeOfString: @"audio/"].location != NSNotFound)
        {
            // not sure how to get codecs or bitrate???
            //AVMetadataItem
            //AudioFile
            if (NSClassFromString(@"AVAudioPlayer") != nil)
            {
                NSURL* fileURL = [NSURL fileURLWithPath: fullPath];
                NSError* err = nil;

                AVAudioPlayer* avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];
                if (!err)
                {
                    // get the data
                    [formatData setObject: [NSNumber numberWithDouble: [avPlayer duration]] forKey: kW3CMediaFormatDuration];
                    NSDictionary* info = [avPlayer settings];
                    NSNumber* bitRate = [info objectForKey:AVEncoderBitRateKey];
                    if (bitRate)
                    {
                        [formatData setObject: bitRate forKey: kW3CMediaFormatBitrate];
                    }
                }
            }
        }
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:formatData];
        [callback setExtensionResult:result];
        XLogI(@"getFormatData: %@", [formatData description]);
    }
    if (bError)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:errorCode];
    }
    if (result)
    {
        [callback setExtensionResult:result];
        // 将扩展结果返回给js端
        [self->jsEvaluator eval:callback];
    }
}

-(XExtensionResult*) processImage: (UIImage*) image type: (NSString*) mimeType
{
    XExtensionResult* result = nil;
    // save the image to photo album
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

    NSData* data = nil;
    if (mimeType && [mimeType isEqualToString:@"image/png"])
    {
        data = UIImagePNGRepresentation(image);
    }
    else
    {
        data = UIImageJPEGRepresentation(image, 0.5);
    }

    // write to temp directory and reutrn URI
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];  // use file system temporary directory
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];

    // generate unique file name
    NSString* filePath;
    int i=1;
    do {
        filePath = [NSString stringWithFormat:@"%@/photo_%03d.jpg", docsPath, i++];
    } while([fileMgr fileExistsAtPath: filePath]);

    if (![data writeToFile: filePath options: NSAtomicWrite error: &err])
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_INTERNAL_ERR ];
        if (err)
        {
            XLogE(@"Error saving image: %@", [err localizedDescription]);
        }

    }
    else
    {
        // create MediaFile object
        NSDictionary* fileDict = [self getMediaDictionaryFromPath:filePath ofType: mimeType];
        NSArray* fileArray = [NSArray arrayWithObject:fileDict];

        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:fileArray];
    }
    return result;
}

-(XExtensionResult *) processVideo: (NSString*) moviePath
{
    XExtensionResult* result = nil;

    // create MediaFile object
    NSDictionary* fileDict = [self getMediaDictionaryFromPath:moviePath ofType:nil];
    NSArray* fileArray = [NSArray arrayWithObject:fileDict];

    result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:fileArray];

    return result;
}

-(NSDictionary*) getMediaDictionaryFromPath: (NSString*) fullPath ofType: (NSString*) type
{
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSMutableDictionary* fileDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [fileDict setObject: [fullPath lastPathComponent] forKey: @"name"];
    [fileDict setObject: fullPath forKey:@"fullPath"];
    // determine type
    if(!type)
    {
        NSString* mimeType = nil;
        mimeType = [self getMediaTypeFromFullPath:fullPath];
        [fileDict setObject: (mimeType != nil ? (NSObject*)mimeType : [NSNull null]) forKey:@"type"];
    }
    NSDictionary* fileAttrs = [fileMgr attributesOfItemAtPath:fullPath error:nil];
    [fileDict setObject: [NSNumber numberWithUnsignedLongLong:[fileAttrs fileSize]] forKey:@"size"];
    NSDate* modDate = [fileAttrs fileModificationDate];
    NSNumber* msDate = [NSNumber numberWithDouble:[modDate timeIntervalSince1970]*1000];
    [fileDict setObject:msDate forKey:@"lastModifiedDate"];

    return fileDict;
}

-(NSString*) getMediaTypeFromFullPath: (NSString*) fullPath
{
    NSString* mimeType = nil;
    if(fullPath)
    {
        CFStringRef typeId = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)[fullPath pathExtension], nil);
        if (typeId)
        {
            mimeType = (__bridge NSString*)UTTypeCopyPreferredTagWithClass(typeId,kUTTagClassMIMEType);
            if (!mimeType)
            {
                if (NSNotFound != [(__bridge NSString*)typeId rangeOfString: @"m4a-audio"].location)
                {
                    mimeType = @"audio/mp4";
                }
                else if (NSNotFound != [[fullPath pathExtension] rangeOfString:@"wav"].location)
                {
                    mimeType = @"audio/wav";
                }
            }
            CFRelease(typeId);
        }
    }
    return mimeType;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    XImagePicker* cameraPicker = (XImagePicker*)picker;
    XJsCallback* callback = cameraPicker.jsCallback;

    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];

    XExtensionResult* result = nil;

    UIImage* image = nil;
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (!mediaType || [mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        // mediaType is nil then only option is UIImagePickerControllerOriginalImage
        if (
(cameraPicker.allowsEditing && [info objectForKey:UIImagePickerControllerEditedImage]))
        {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }
        else
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    }
    if (image != nil)
    {
        // mediaType was image
        result = [self processImage: image type: cameraPicker.mimeType];
    }
    else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        // process video
        NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
        if (moviePath)
        {
            result = [self processVideo: moviePath];
        }
    }
    if (!result)
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_INTERNAL_ERR];
    }

    [callback setExtensionResult:result];
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:callback];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo
{
    // older api calls new one
    [self imagePickerController:picker didFinishPickingMediaWithInfo: editingInfo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    XImagePicker* cameraPicker = (XImagePicker*)picker;
    XJsCallback* callback = cameraPicker.jsCallback;

    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];

    XExtensionResult* result = nil;
    result = [XExtensionResult resultWithStatus:STATUS_ERROR messageToErrorObject:CAPTURE_NO_MEDIA_FILES];
    [callback setExtensionResult:result];

    // 将扩展结果返回给js端
    [self->jsEvaluator eval:callback];
}

-(void) captureAudioResult:(XJsCallback *)callback
{
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:callback];
}

- (void) captureScreen: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    id<XApplication> app = [self getApplication:options];
    XExtensionResult* result;

    NSDictionary* jsOptions = [arguments objectAtIndex:0 withDefault:nil];

    NSNumber* destinationType = [jsOptions objectForKey:@"destinationType"];
    NSString* destPath = [jsOptions objectForKey:@"destionationFile"];

    destPath = [self resolveDestPath:destPath];
    ImageType imageType = [self resolveImageTypeByPath:destPath];
    if (imageType == kImageTypeUnknown) {
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject:@{@"code": @(ARGUMENT_ERROR)} ];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
        return;
    }

    destPath = [[app getWorkspace] stringByAppendingPathComponent:destPath];

    NSNumber* height = [jsOptions objectForKey:@"height"];
    NSNumber* width = [jsOptions objectForKey:@"width"];
    NSNumber* x = [jsOptions objectForKey:@"x"];
    NSNumber* y = [jsOptions objectForKey:@"y"];

    CGRect targetRect = CGRectMake(x.intValue, y.intValue, width.intValue, height.intValue);
    CGRect defaultRect = self.viewController.view.frame;
    defaultRect.origin.y -= defaultRect.origin.y;

    targetRect = [self resolveTargetRect:targetRect withDefaultRect:defaultRect];

    if(CGRectIsEmpty(targetRect))
    {
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject:@{@"code": @(ARGUMENT_ERROR)} ];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
        return;
    }

    UIImage *image = [UIImage imageFromView:self.viewController.view];
    image = [image crop:targetRect];

    //根据参数返回的目标文件类型决定是返回文件,还是返回base64的js字串
    result = [self resolveImage:image imageType:imageType destType:destinationType.intValue destPath:destPath];

    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
    return;
}

#pragma mark - private api

- (NSString *)resolveDestPath:(NSString *)destPath
{
    if (destPath == nil) {
        destPath = @"";
    }

    NSMutableString* path = [NSMutableString stringWithString:destPath];
    [path replaceOccurrencesOfString:@" "
                          withString:@""
                             options:0
                               range:NSMakeRange(0, [path length])];
    destPath = path;
    if ([destPath length] == 0)
    {
        //照片的file name 使用时间命名
        NSDate* nowDate = [NSDate date];
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
        destPath = [dateFormatter stringFromDate:nowDate];
        destPath  = [destPath stringByAppendingPathExtension:@"jpg"];
    }

    if ([[destPath pathExtension] length] == 0)
    {
        destPath  = [destPath stringByAppendingPathExtension:@"jpg"];
    }
    return destPath;
}

- (ImageType)resolveImageTypeByPath:(NSString *)destPath
{
    if ([[destPath pathExtension] isEqualToString:@"jpg"])
    {
        return kImageTypeJPEG;
    } else if([[destPath pathExtension] isEqualToString:@"png"])
    {
        return kImageTypePNG;
    }
    return kImageTypeUnknown;
}

- (CGRect)resolveTargetRect:(CGRect)targetRect withDefaultRect:(CGRect)defaultRect
{
    if(CGRectEqualToRect(targetRect, CGRectZero))
    {
        targetRect = defaultRect;
    }

    if (CGSizeEqualToSize(targetRect.size, CGSizeZero)) {
        targetRect.size = defaultRect.size;
    }

    CGRect intersectionRect = CGRectIntersection(targetRect, defaultRect);
    return intersectionRect;
}

-(XExtensionResult*) resolveImage:(UIImage*)image imageType:(ImageType)imageType destType:(DestinationType)destType destPath:(NSString*)destPath
{
    XExtensionResult* result;
    NSData *data;
    if (imageType == kImageTypePNG) {
        data = UIImagePNGRepresentation(image);
    } else {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    if (DESTINATION_TYPE_FILE_URL == destType)
    {
        NSError* err = nil;
        // save file
        NSString* parentPath = [destPath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:parentPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:parentPath withIntermediateDirectories:NO attributes:nil error:&err];
        }
        if (![data writeToFile:destPath options:NSAtomicWrite error:&err])
        {
            result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject:@{@"code" : @(IO_ERROR)} ];

        }
        else
        {
            NSString* uri = [[NSURL fileURLWithPath: destPath] absoluteString];
            result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject:@{@"code" : @(SUCCESS), @"result" : uri}];
        }
    }
    else if(DESTINATION_TYPE_DATA_URL == destType)
    {
        result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: @{@"code" : @(SUCCESS), @"result" : [data base64EncodedString]}];
    }
    else
    {
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject:@{@"code": @(ARGUMENT_ERROR)}];
    }
    return result;
}

@end

#endif
