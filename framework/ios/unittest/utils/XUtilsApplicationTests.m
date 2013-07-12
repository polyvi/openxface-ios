
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
//  XUtilsApplicationTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XUtils.h"
#import "XConstants.h"
#import "XRootViewController.h"
#import "XApplicationTests.h"

@interface XUtilsApplicationTests : XApplicationTests

@end

@implementation XUtilsApplicationTests

- (void) testResolveLaunchImageResource
{
    NSString *resolvedImgFile = [XUtils resolveSplashScreenImageResourceWithOrientation:UIDeviceOrientationLandscapeRight];
    STAssertNotNil(resolvedImgFile, nil);

    NSString *launchImageFile = [[NSBundle mainBundle] objectForInfoDictionaryKey:UI_LAUNCH_IMAGE_FILE_KEY];
    if (launchImageFile)
    {
        STAssertTrue([resolvedImgFile hasPrefix:launchImageFile], nil);
    }
    else
    {
        STAssertTrue([resolvedImgFile hasPrefix:SPLASH_FILE_NAME], nil);
    }
}

- (void) testAppController
{
    id rootViewController = [XUtils rootViewController];
    STAssertTrue(rootViewController, nil);
    STAssertTrue([rootViewController isKindOfClass:[XRootViewController class]], nil);
}

@end
