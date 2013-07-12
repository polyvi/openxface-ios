
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
//  XCameraExtLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XCameraExt.h"
#import "XCameraExt_Privates.h"

@interface XCameraExtLogicTests : SenTestCase
{
@private
    XCameraExt *cameraExt;
}

@end

@implementation XCameraExtLogicTests

- (void)setUp
{
    [super setUp];

    self->cameraExt= [[XCameraExt alloc] init];
    STAssertNotNil(self->cameraExt, @"Failed to create camera extension instance");
}

- (void)testImageByScalingAndCroppingForSize
{
    UIImage *image = [[UIImage alloc] init];
    CGSize targetsize = CGSizeMake(0, 0);
    STAssertNoThrow([cameraExt imageByScalingAndCroppingForSize:image toSize:targetsize], nil);
}

- (void)testImageByScalingNotCroppingForSize
{
    UIImage *image = [[UIImage alloc] init];
    CGSize targetsize = CGSizeMake(0, 0);
    STAssertNoThrow([cameraExt imageByScalingNotCroppingForSize:image toSize:targetsize], nil);
}

- (void)testImageCorrectedForCaptureOrientation
{
    UIImage *image = [[UIImage alloc] init];
    STAssertNoThrow([cameraExt imageCorrectedForCaptureOrientation:image], nil);
}

- (void) testClosePicker
{
    XCameraPicker* picker = [[XCameraPicker alloc] init];
    STAssertNoThrow([cameraExt closePicker:picker], nil);
}

-(void) testGenerateFilePathFromType
{
    STAssertNoThrow([cameraExt generateFilePathFromType:ENCODING_TYPE_JPEG],nil);
    NSString* path = [cameraExt generateFilePathFromType:ENCODING_TYPE_JPEG];
    STAssertNotNil(path, nil);
}

-(void) testCreatePhotoDirPath
{
    STAssertNoThrow([cameraExt createPhotoDirPath], nil);
    NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
    NSString* fileDir = [NSString stringWithFormat:@"%@%@", docsPath,@"/photo"];
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    BOOL isDirectoryExisted = [fileMrg fileExistsAtPath:fileDir];
    STAssertTrue(isDirectoryExisted, nil);
}

-(void) testCleanupAtPath
{
    NSString* fileDir = [cameraExt createPhotoDirPath];
    STAssertNoThrow([cameraExt cleanupAtPath:fileDir], nil);
    NSFileManager* fileMrg = [NSFileManager defaultManager];
    BOOL isDirectoryExisted = [fileMrg fileExistsAtPath:fileDir];
    STAssertFalse(isDirectoryExisted, nil);
}

-(void) testHandleImage
{
    UIImage *image = [[UIImage alloc] init];
    CGSize targetsize = CGSizeMake(0, 0);
    BOOL crop = NO;
    STAssertNoThrow([cameraExt handleImage:image targetSize:targetsize needCrop:crop], nil);
}

-(void) testGetImageData
{
    UIImage *image = [[UIImage alloc] init];
    STAssertNoThrow([cameraExt getImageData:image encodeType:ENCODING_TYPE_JPEG quality:50],nil);
}

-(void) testOpenPicker
{
    XCameraPicker* picker = [[XCameraPicker alloc] init];
    STAssertNoThrow([cameraExt openPicker:picker], nil);
}

@end
