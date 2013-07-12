
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
//  XCameraExt.m
//  xFaceLib
//
//

#ifdef __XCameraExt__

#import <MobileCoreServices/UTCoreTypes.h>
#import "XCameraExt.h"
#import "XCameraExt_Privates.h"
#import "XBase64Data.h"
#import "XExtendedDictionary.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XFileUtils.h"
#import "XQueuedMutableArray.h"

#define POPOVERVIEW_DEFAULT_WIDTH   320
#define POPOVERVIEW_DEFAULT_HEIGHT  480
#define DEFAULT_QUALITY             50
#define PATH_PHOTO                  @"/photo"

#pragma mark -
#pragma mark XCameraPicker

@implementation XCameraPicker

@synthesize quality;
@synthesize jsCallback;
@synthesize returnType;
@synthesize encodingType;
@synthesize popoverController;
@synthesize targetSize;
@synthesize correctOrientation;
@synthesize saveToPhotoAlbum;
@synthesize cropToSize;
@synthesize popoverSupported;

@end

#pragma mark -
#pragma mark XCameraPicker

@implementation XCameraExt

@synthesize pickerController;

-(NSString*) generateFilePathFromType:(EncodingType)Type
{
    NSString* filePath;
    NSString* imageType;
    if (ENCODING_TYPE_PNG == Type)
    {
        imageType = @"png";
    }
    else
    {
        imageType = @"jpg";
    }

    //照片的file name 使用时间命名
    NSDate* nowDate = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString* dateString = [dateFormatter stringFromDate:nowDate];
    NSString* fileDir = [self createPhotoDirPath];
    filePath = [NSString stringWithFormat:@"%@/%@.%@", fileDir, dateString, imageType];

    return filePath;
}

-(NSString*) createPhotoDirPath
{
    // get the tmp directory path
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSString* fileDir = [NSString stringWithFormat:@"%@%@", docsPath,PATH_PHOTO];
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    BOOL isDirectoryExisted = [fileMrg fileExistsAtPath:fileDir];
    if (!isDirectoryExisted)
    {
        [fileMrg createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileDir;
}

-(BOOL) cleanupAtPath:(NSString*)path
{
    //删除文件或文件夹
    BOOL ret = [XFileUtils removeItemAtPath:path error:nil];
    return ret;
}

//检测 popover 的支持,主要是iPad
- (BOOL) popoverSupported
{
    return ( NSClassFromString(@"UIPopoverController") != nil) &&
    (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM());
}

- (void) popoverControllerDidDismissPopover:(id)popoverController
{
    UIPopoverController* popover = (UIPopoverController*)popoverController;
    [popover dismissPopoverAnimated:YES];
    popover.delegate = nil;
}

- (void) cleanup:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    XExtensionResult* result    = nil;

    //删除存储照片的photo文件夹
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSString* fileDir = [NSString stringWithFormat:@"%@%@", docsPath,PATH_PHOTO];
    BOOL hasSuccess = [self cleanupAtPath:fileDir];
    if (!hasSuccess)
    {
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: @"One or more files failed to be deleted."];
    }
    else
    {
        result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: @"Camera cleanup success"];
    }

    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (void) takePicture:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString* sourceTypeString = [arguments objectAtIndex:2];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera; //默认
    if (sourceTypeString != nil)
    {
        sourceType = (UIImagePickerControllerSourceType)[sourceTypeString intValue];
    }
    bool hasCamera = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (!hasCamera)//错误结果返回
    {
        XLogW(@"Camera.getPicture: source type %d not available.", sourceType);
        XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: @"no camera available"];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
        return;
    }

    bool allowEdit          = [[arguments objectAtIndex:7] boolValue];
    NSNumber* targetWidth   = [arguments objectAtIndex:3];
    NSNumber* targetHeight  = [arguments objectAtIndex:4];
    NSNumber* mediaValue    = [arguments objectAtIndex:6];
    MediaType mediaType     = (mediaValue) ? [mediaValue intValue] : MEDIA_TYPE_PICTURE;
    NSNumber* cropToSize    = [arguments objectAtIndex:10 withDefault:@(NO)];

    CGSize targetSize = CGSizeMake(0, 0);
    if (targetWidth != nil && targetHeight != nil)
    {
        targetSize = CGSizeMake([targetWidth floatValue], [targetHeight floatValue]);
    }
    //为XCameraPicker 的属性赋值,回调和可选参数
    XCameraPicker* cameraPicker     = [[XCameraPicker alloc] init];
    self.pickerController           = cameraPicker;
    cameraPicker.delegate           = self;
    cameraPicker.sourceType         = sourceType;
    cameraPicker.allowsEditing      = allowEdit;
    cameraPicker.jsCallback         = callback;
    cameraPicker.targetSize         = targetSize;
    cameraPicker.cropToSize         = [cropToSize boolValue];
    cameraPicker.popoverSupported   = [self popoverSupported];
    cameraPicker.correctOrientation = [[arguments objectAtIndex:8] boolValue];
    cameraPicker.saveToPhotoAlbum   = [[arguments objectAtIndex:9] boolValue];
    cameraPicker.encodingType       = ([arguments objectAtIndex:5]) ? [[arguments objectAtIndex:5] intValue] : ENCODING_TYPE_JPEG;
    cameraPicker.quality            = ([arguments objectAtIndex:0]) ? [[arguments objectAtIndex:0] intValue] : DEFAULT_QUALITY;
    cameraPicker.returnType         = ([arguments objectAtIndex:1]) ? [[arguments objectAtIndex:1] intValue] : DESTINATION_TYPE_FILE_URL;

    if (UIImagePickerControllerSourceTypeCamera == sourceType)
    {
        // 使用此API只允许使用拍照
        cameraPicker.mediaTypes = [NSArray arrayWithObjects: (NSString*) kUTTypeImage, nil];
    }
    else if (MEDIA_TYPE_ALL == mediaType)
    {
        cameraPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: sourceType];
    }
    else
    {
        NSArray* mediaArray = [NSArray arrayWithObjects: (NSString*) (MEDIA_TYPE_VIDEO == mediaType ? kUTTypeMovie : kUTTypeImage), nil];
        cameraPicker.mediaTypes = mediaArray;
    }
    [self openPicker:cameraPicker];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    XCameraPicker* cameraPicker = (XCameraPicker*)picker;
    XJsCallback* callback       = cameraPicker.jsCallback;
    XExtensionResult* result    = nil;

    //解除cameraPicker的view
    [self closePicker:cameraPicker];

    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // IMAGE TYPE
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        // get the image
        UIImage* image = nil;
        if (cameraPicker.allowsEditing && [info objectForKey:UIImagePickerControllerEditedImage])
        {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }
        else
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }

        // 如果需要裁剪, 就缩放图片并根据目标尺寸裁剪, 否则只根据目标尺寸缩放图片，不裁剪。
        image = [self handleImage:image targetSize:cameraPicker.targetSize needCrop:cameraPicker.cropToSize];

        if (cameraPicker.correctOrientation)
        {
            image = [self imageCorrectedForCaptureOrientation:image];
        }

        //取出image的data
        NSData* data = [self getImageData:image encodeType:cameraPicker.encodingType quality:cameraPicker.quality];

        if (cameraPicker.saveToPhotoAlbum)
        {
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
        }

        //根据参数返回的目标文件类型决定是返回文件,还是返回base64的js字串
        if (DESTINATION_TYPE_FILE_URL == cameraPicker.returnType)
        {
            NSString* filePath = [self generateFilePathFromType:cameraPicker.encodingType];
            NSError* err = nil;
            // save file
            if (![data writeToFile: filePath options: NSAtomicWrite error: &err])
            {
                result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: [err localizedDescription]];
            }
            else
            {
                result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: [[NSURL fileURLWithPath: filePath] absoluteString]];
            }
        }
        else
        {
            result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: [data base64EncodedString]];
        }
    }
    // NOT IMAGE TYPE (MOVIE)
    else
    {
        NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] absoluteString];
        result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: moviePath];
    }

    if (result)
    {
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    XCameraPicker* cameraPicker = (XCameraPicker*)picker;
    XJsCallback* callback       = cameraPicker.jsCallback;
    //解除cameraPicker view
    [self closePicker:cameraPicker];

    XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: @"no image selected"];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)anImage toSize:(CGSize)targetSize
{
    UIImage *sourceImage    = anImage;
    UIImage *newImage       = nil;
    CGSize imageSize        = sourceImage.size;
    CGFloat width           = imageSize.width;
    CGFloat height          = imageSize.height;
    CGFloat targetWidth     = targetSize.width;
    CGFloat targetHeight    = targetSize.height;
    CGFloat scaleFactor     = 0.0;
    CGFloat scaledWidth     = targetWidth;
    CGFloat scaledHeight    = targetHeight;
    CGPoint thumbnailPoint  = CGPointMake(0.0,0.0);

    if (NO == CGSizeEqualToSize(imageSize, targetSize))
    {
        CGFloat widthFactor     = targetWidth / width;
        CGFloat heightFactor    = targetHeight / height;

        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;

        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    UIGraphicsBeginImageContext(targetSize); // this will crop

    CGRect thumbnailRect        = CGRectZero;
    thumbnailRect.origin        = thumbnailPoint;
    thumbnailRect.size.width    = scaledWidth;
    thumbnailRect.size.height   = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(nil == newImage)
    {
        XLogW(@"could not scale image");
    }

    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    UIImage *sourceImage    = anImage;
    UIImage *newImage       = nil;
    CGSize  imageSize       = sourceImage.size;
    CGFloat width           = imageSize.width;
    CGFloat height          = imageSize.height;
    CGFloat targetWidth     = frameSize.width;
    CGFloat targetHeight    = frameSize.height;
    CGFloat scaleFactor     = 0.0;
    CGSize  scaledSize      = frameSize;

    if (NO == CGSizeEqualToSize(imageSize, frameSize))
    {
        CGFloat widthFactor     = targetWidth / width;
        CGFloat heightFactor    = targetHeight / height;

        if (widthFactor > heightFactor)
        {
            scaleFactor = heightFactor; // scale to fit height
        }
        else
        {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(MIN(width * scaleFactor, targetWidth), MIN(height * scaleFactor, targetHeight));
    }

    UIGraphicsBeginImageContext(scaledSize); // this will resize
    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(nil == newImage)
    {
        XLogW(@"could not scale image");
    }

    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageCorrectedForCaptureOrientation:(UIImage*)anImage
{
    float rotation_radians  = 0;
    bool perpendicular      = false;//垂直？

    switch ([anImage imageOrientation])
    {
        case UIImageOrientationUp:
            rotation_radians = 0.0;
            break;
        case UIImageOrientationDown:
            rotation_radians = M_PI;//一个数学计算常量
            break;
        case UIImageOrientationRight:
            rotation_radians = M_PI_2;
            perpendicular = true;
            break;
        case UIImageOrientationLeft:
            rotation_radians = -M_PI_2;
            perpendicular = true;
            break;
        default:
            break;
    }

    UIGraphicsBeginImageContext(CGSizeMake(anImage.size.width, anImage.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();

    //Rotate around the center point
    CGContextTranslateCTM(context, anImage.size.width/2, anImage.size.height/2);
    CGContextRotateCTM(context, rotation_radians);

    CGContextScaleCTM(context, 1.0, -1.0);
    float width     = perpendicular ? anImage.size.height : anImage.size.width;
    float height    = perpendicular ? anImage.size.width : anImage.size.height;
    CGContextDrawImage(context, CGRectMake(-width / 2, -height / 2, width, height), [anImage CGImage]);

    //if its 90 degrees
    if (perpendicular)
    {
        CGContextTranslateCTM(context, -anImage.size.height/2, -anImage.size.width/2);
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) closePicker:(XCameraPicker*)picker
{
    XCameraPicker* cameraPicker = (XCameraPicker*)picker;

    //解除cameraPicker的view
    if(cameraPicker.popoverSupported && cameraPicker.popoverController != nil)
    {
        [cameraPicker.popoverController dismissPopoverAnimated:YES];
        cameraPicker.popoverController.delegate = nil;
        cameraPicker.popoverController = nil;
    }
    else
    {
        [[cameraPicker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void) openPicker:(XCameraPicker*)cameraPicker
{
    //popover 一个不接管整个屏幕的视图,悬浮窗口;主要是在iPad上
    if ([self popoverSupported] && cameraPicker.sourceType != UIImagePickerControllerSourceTypeCamera)
    {
        if (nil == cameraPicker.popoverController)
        {
            cameraPicker.popoverController = [[NSClassFromString(@"UIPopoverController") alloc]
                                              initWithContentViewController:cameraPicker];
        }
        cameraPicker.popoverController.delegate = self;
        [cameraPicker.popoverController presentPopoverFromRect:CGRectMake(0,0,POPOVERVIEW_DEFAULT_WIDTH,POPOVERVIEW_DEFAULT_HEIGHT)
                                                        inView:[self.viewController.view superview]
                                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                                      animated:YES];
    }
    else
    {
        [self.viewController presentViewController:cameraPicker animated:YES completion:nil];
    }
}

-(UIImage*) handleImage:(UIImage*)image targetSize:(CGSize)size needCrop:(BOOL)crop
{
    UIImage *scaledImage = nil;
    if (size.width > 0 && size.height > 0)
    {
        if(crop)
        {
            scaledImage = [self imageByScalingAndCroppingForSize:image toSize:size];
        }
        else
        {
            scaledImage = [self imageByScalingNotCroppingForSize:image toSize:size];
        }
    }
    else
    {
        scaledImage = image;
    }
    return scaledImage;
}

-(NSData*) getImageData:(UIImage*)image encodeType:(EncodingType)type quality:(NSInteger)aquality
{
    NSData* data = nil;
    if (ENCODING_TYPE_PNG == type)
    {
        data = UIImagePNGRepresentation(image);
    }
    else
    {
        data = UIImageJPEGRepresentation(image, aquality / 100.0f);
    }
    return data;
}

@end

#endif
