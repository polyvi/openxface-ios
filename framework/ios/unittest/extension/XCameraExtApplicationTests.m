
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
//  XCameraExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XCameraExt.h"
#import "XCameraExt_Privates.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XConstants.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "XApplication.h"

#define QUALITY_STRING                  @"50"
#define RETURN_TYPE_STRING              @"1"
#define SOURCE_TYPE_STRING              @"1"
#define TARGET_WIDTH_STRING             @"640"
#define TARGET_HEIGHT_STRING            @"480"
#define ENCODING_TYPE_STRING            @"0"
#define MEDIA_VALUE_STRING              @"0"
#define ALLOW_EDIT_STRING               @"false"
#define CORRECT_ORIENTATION_STRING      @"false"
#define SAVE_TO_PHOTOALBUM_STRING       @"false"

@interface XCameraExtApplicationTests : XApplicationTests
{
@private
    XCameraExt *cameraExt;
}
@end

@implementation XCameraExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    self->cameraExt = [[XCameraExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(self->cameraExt, @"Failed to create cameraExt extension instance");
}

- (void) testGetPicture
{
    //创建测试环境
    NSString *callbackId = @"Camera0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"getPicture"];
    NSString* quality = QUALITY_STRING;
    NSString* returnType = RETURN_TYPE_STRING;
    NSString* sourceTypeString = SOURCE_TYPE_STRING;
    NSString* targetWidth   = TARGET_WIDTH_STRING;
    NSString* targetHeight  = TARGET_HEIGHT_STRING;
    NSString* encodingType = ENCODING_TYPE_STRING;
    NSString* mediaValue = MEDIA_VALUE_STRING;
    NSString* allowEdit = ALLOW_EDIT_STRING;
    NSString* correctOrientation = CORRECT_ORIENTATION_STRING;
    NSString* saveToPhotoAlbum = SAVE_TO_PHOTOALBUM_STRING;
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:12];
    [arguments addObject:quality];
    [arguments addObject:returnType];
    [arguments addObject:sourceTypeString];
    [arguments addObject:targetWidth];
    [arguments addObject:targetHeight];
    [arguments addObject:encodingType];
    [arguments addObject:mediaValue];
    [arguments addObject:allowEdit];
    [arguments addObject:correctOrientation];
    [arguments addObject:saveToPhotoAlbum];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
    [options setObject:callback forKey:JS_CALLBACK_KEY];
    [options setObject:[self app] forKey:APPLICATION_KEY];
    STAssertNoThrow([self->cameraExt takePicture:arguments withDict:options], nil);

    //分支
    [arguments replaceObjectAtIndex:3 withObject:@""];//sourceTypeString = nil
    [arguments replaceObjectAtIndex:4 withObject:@"0"];//targetWidth = 0
    [arguments replaceObjectAtIndex:5 withObject:@"0"];//targetHeight = 0
    [arguments replaceObjectAtIndex:7 withObject:@"2"];//mediaValue = MEDIA_TYPE_ALL
    STAssertNoThrow([self->cameraExt takePicture:arguments withDict:options], nil);

}

- (void) testCleanup
{
    //创建测试环境
    NSString *callbackId = @"Camera0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"cleanUp"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    [arguments addObject:callback];
    [arguments addObject:[self app]];
    //测试
    STAssertNoThrow([self->cameraExt cleanup:arguments withDict:nil], nil);
}

- (void) testImagePickerControllerDidFinishPickingMediaWithInfo
{
    XCameraPicker* cameraPicker = [[XCameraPicker alloc] init];
    NSString *callbackId = @"Camera0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"getPicture"];
    cameraPicker.jsCallback = callback;
    cameraPicker.allowsEditing = true;
    cameraPicker.saveToPhotoAlbum = true;
    cameraPicker.correctOrientation = true;
    cameraPicker.returnType = DESTINATION_TYPE_FILE_URL;
    NSMutableDictionary* info = [NSMutableDictionary dictionaryWithCapacity:3];
    [info setObject:@"public.image" forKey:UIImagePickerControllerMediaType];
    UIImage* image = [[UIImage alloc] init];
    [info setObject:image forKey:UIImagePickerControllerEditedImage];
    [info setObject:image forKey:UIImagePickerControllerOriginalImage];
    STAssertNoThrow([self->cameraExt imagePickerController:cameraPicker didFinishPickingMediaWithInfo:info],nil);

    //分支
    cameraPicker.allowsEditing = false;
    cameraPicker.saveToPhotoAlbum = false;
    cameraPicker.correctOrientation = false;
    cameraPicker.returnType = DESTINATION_TYPE_DATA_URL;
    STAssertNoThrow([self->cameraExt imagePickerController:cameraPicker didFinishPickingMediaWithInfo:info],nil);
}

- (void) testImagePickerControllerDidCancel
{
    XCameraPicker* cameraPicker = [[XCameraPicker alloc] init];
    NSString *callbackId = @"Camera0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"getPicture"];
    cameraPicker.jsCallback = callback;
    STAssertNoThrow([self->cameraExt imagePickerControllerDidCancel:cameraPicker],nil);
}

@end
