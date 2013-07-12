
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
//  AppDelegate.m
//  xFace
//
//

#import "AppDelegate.h"
#import "XRuntime.h"
#import "XRootViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize runtime;

- (id)init
{
    // If you need to do any extra app-specific initialization, you can do it here
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    self = [super init];
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.runtime = [[XRuntime alloc] init];

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    [self.window setRootViewController:self.runtime.rootViewController];
    [self.window makeKeyAndVisible];

    if (launchOptions != nil){
        NSDictionary* remoteInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteInfo) {
            application.applicationIconBadgeNumber = 0;
            //延迟5秒等待程序启动并xFace初始化
            [self.runtime performSelector:@selector(pushNotification:) withObject:remoteInfo afterDelay:5];
        }
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if (!url){
        return NO;
    }

    [self.runtime handleOpenURL:[url absoluteString]];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

// If a cellular or Wi-Fi connection is not available, neither the
// application:didRegisterForRemoteNotificationsWithDeviceToken: method
// or the application:didFailToRegisterForRemoteNotificationsWithError: method is called.
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [self.runtime didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Warning:register for remote notifications failed:%@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary*)userInfo{
    application.applicationIconBadgeNumber = 0;
    //后台切换到前台马上调用alert会卡死，延迟3秒
    [self.runtime performSelector:@selector(pushNotification:) withObject:userInfo afterDelay:3];
}

@end
