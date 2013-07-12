
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
//  UIDevice+Additions.m
//  xFaceLib
//
//

#import "UIDevice+Additions.h"
#import "XConstants.h"

@implementation UIDevice (Additions)

+ (DEVICE_TYPE)deviceType
{
    DEVICE_TYPE curDevice = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        curDevice |= IPHONE;
        if ([[UIScreen mainScreen] scale] == 2.0)
        {
            curDevice |= IPHONE_RETINA;
            if ([[UIScreen mainScreen] bounds].size.height == IPHONE5_MAIN_SCREEN_BOUNDS_HEIGHT)
            {
                curDevice |= IPHONE5;
            }
        }
    }
    else
    {
        curDevice |= IPAD;
        if ([[UIScreen mainScreen] scale] == 2.0)
        {
            curDevice |= IPAD_RETINA;
        }
    }
    return curDevice;
}

@end
