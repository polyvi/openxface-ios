
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
//  XDeviceProperties.m
//  xFaceLib
//
//

#import "XDeviceProperties.h"
#import "XUtils.h"
#import "XUtils+Additions.h"
#import "XConfiguration.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "XNetworkReachability.h"
#import "XConstants.h"

#define UUID_USER_DEFAULTS_KEY      @"xFace_UUID"
#define PLATFORM_NAME               @"iOS"

@implementation XDeviceProperties

- (NSDictionary*) deviceProperties
{
    UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *devProps = [NSMutableDictionary dictionaryWithCapacity:10];
    //js device.platform = @"iOS"
    [devProps setObject:PLATFORM_NAME forKey:@"platform"];
    [devProps setObject:[device systemVersion] forKey:@"version"];
    //js device.model 的值形如 @“iPad2,5”;/@“iPhone5,1“/;...
    [devProps setObject:[XUtils modelVersion] forKey:@"model"];
    [devProps setObject:[self uuid] forKey:@"uuid"];
    //js device.name 的值形如  @“iPad Touch”;/@“iPhone“/;...
    [devProps setObject:[device model] forKey:@"name"];
    [devProps setObject:[XUtils getPreferenceForKey:ENGINE_VERSION] forKey:@"xFaceVersion"];
    [devProps setObject:[self productVersion] forKey:@"productVersion"];

    [devProps setObject:@([self isCameraAvailable]) forKey:@"isCameraAvailable"];
    [devProps setObject:@([self isFrontCameraAvailable]) forKey:@"isFrontCameraAvailable"];
    [devProps setObject:@([self isCompassAvailable]) forKey:@"isCompassAvailable"];
    [devProps setObject:@([self isAccelerometerAvailable]) forKey:@"isAccelerometerAvailable"];
    [devProps setObject:@([self isLocationAvailable]) forKey:@"isLocationAvailable"];
    [devProps setObject:@([self isWiFiAvailable]) forKey:@"isWiFiAvailable"];
    [devProps setObject:@([self isTelephonyAvailable]) forKey:@"isTelephonyAvailable"];
    [devProps setObject:@([self isSmsAvailable]) forKey:@"isSmsAvailable"];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [devProps setObject:@(screenRect.size.width) forKey:@"width"];
    [devProps setObject:@(screenRect.size.height) forKey:@"height"];

    return devProps;
}

//Returns the current version of product as read from the info.plist
- (NSString*) productVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];//get product version
}

//use the CFUUIDCreate replace device uuid
-(NSString*) uuid
{
    NSString *uuid = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	uuid = [defaults objectForKey:UUID_USER_DEFAULTS_KEY];//get form userdefault data
    if(!uuid)//create uuid
    {
        CFStringRef ref = CFUUIDCreateString(kCFAllocatorDefault,CFUUIDCreate(kCFAllocatorDefault));
        uuid = (__bridge NSString *)ref;
        //将uuid保存
        [defaults setValue:uuid forKey:UUID_USER_DEFAULTS_KEY];
        [defaults synchronize];
    }
    return uuid;
}

- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) isLocationAvailable
{
    return [CLLocationManager regionMonitoringAvailable];
}

- (BOOL) isWiFiAvailable
{
    XNetworkReachability *reachability = [XNetworkReachability reachabilityForInternetConnection];
    [reachability startNotifier];

    NetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];

    return (status == ReachableViaWiFi);
}

- (BOOL) isCompassAvailable
{
    return [CLLocationManager headingAvailable];
}

-(BOOL) isAccelerometerAvailable
{
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    return manager.accelerometerAvailable;
}

-(BOOL) isTelephonyAvailable
{
    NSURL* tel = [NSURL URLWithString:@"tel://1"];
    return ([[UIApplication sharedApplication] canOpenURL:tel]);
}

-(BOOL) isSmsAvailable
{
    NSURL* sms = [NSURL URLWithString:@"sms://1"];
    return ([[UIApplication sharedApplication] canOpenURL:sms]);
}

@end
