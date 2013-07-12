
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
//  XRootViewController.m
//  xFace
//
//

#import "XRootViewController.h"
#import "XAppWebView.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XVersionLableFactory.h"
#import "UIDevice+Additions.h"

#define MILLISECOND_PER_SECOND           1000
#define SPLASH_SCREEN_DURATION_DEFAULT   0.75f

@implementation XRootViewController

- (id<XAppView>) createView:(id<XApplication>) app
{
    CGRect webViewBounds = self.view.bounds;

    XAppWebView *appView = [[XAppWebView alloc] initWithFrame:webViewBounds];
    appView.hidden = YES;
    app.appView = appView;
    [appView setValid:YES];

    [self.view addSubview:appView];
    return appView;
}

- (void)showSplashIfNeeded
{
    BOOL willShowSplash = [[XUtils getPreferenceForKey:SHOW_SPLASH_SCREEN] boolValue];
    if(!willShowSplash)
    {
        return;
    }

    // FIXME:同时支持横竖屏时，native splash的处理还不完善，此处只能取到竖屏图片
    NSString *resolvedImgFile = [XUtils resolveSplashScreenImageResourceWithOrientation:self.interfaceOrientation];
    UIImage *image = [UIImage imageNamed:resolvedImgFile];
    if (!image)
    {
        XLogW(@"Splash-screen image '%@' was not found!", resolvedImgFile);
        return;
    }

    CGRect imgBounds = CGRectMake(0, 0, image.size.width, image.size.height);
    if (([UIDevice deviceType] & IPHONE)
        && (UIDeviceOrientationLandscapeRight == self.interfaceOrientation
            || UIDeviceOrientationLandscapeLeft == self.interfaceOrientation))
    {
        // 当iPhone处于横屏时，需要调整图片的朝向，否则图片显示会发生变形
        imgBounds = CGRectMake(0, 0, image.size.height, image.size.width);
        UIImageOrientation imgOrientation = (UIDeviceOrientationLandscapeLeft == self.interfaceOrientation) ? UIImageOrientationLeft : UIImageOrientationRight;
        image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:imgOrientation];
    }

    // 调整bounds,以避免显示splashscreen时有"跳跃"现象
    BOOL isFullScreen = [UIApplication sharedApplication].statusBarHidden;
    if (!isFullScreen)
    {
        CGRect statusBarFrame = [self.view convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
        CGFloat statusBarHeight = statusBarFrame.size.height;

        imgBounds = CGRectMake(imgBounds.origin.x, (imgBounds.origin.y - statusBarHeight), imgBounds.size.width, imgBounds.size.height);
    }

    splashView = [[UIImageView alloc] initWithFrame:imgBounds];
    [splashView setImage:image];

    [self.view addSubview:splashView];
    [self.view setUserInteractionEnabled:NO];

    // show splash spinner
    [self showSplashSpinnerIfNeededWithFrame:imgBounds];

    UILabel *versionLabel = [XVersionLableFactory createWithFrame:splashView.frame];
    if(versionLabel)
    {
        [splashView addSubview:versionLabel];
    }
}

- (void)showSplashSpinnerIfNeededWithFrame:(CGRect)aRect
{
    BOOL showSplashSpinner = [[XUtils getPreferenceForKey:SHOW_SPLASH_SCREEN_SPINNER] boolValue];
    if(!showSplashSpinner)
    {
        return;
    }

    NSString *topActivityIndicator = [XUtils getPreferenceForKey:TOP_ACTIVITY_INDICATOR];
    UIActivityIndicatorViewStyle topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;

    if ([topActivityIndicator isEqualToString:@"whiteLarge"])
    {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    else if ([topActivityIndicator isEqualToString:@"white"])
    {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    }
    else if ([topActivityIndicator isEqualToString:@"gray"])
    {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    }

    UIView* parentView = self.view;
    self->activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:topActivityIndicatorStyle];
    self->activityView.center = CGPointMake(parentView.bounds.size.width / 2, parentView.bounds.size.height / 2);
    self->activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self->activityView startAnimating];

    [self.view addSubview:self->activityView];
    return;
}

- (void)stopShowingSplash
{
    if (self->splashView)
    {
        [UIView transitionWithView:self.view
                          duration:[self fadeDuration]
                           options:UIViewAnimationOptionTransitionNone
                        animations:^(void){
                            [self->splashView setAlpha:0];
                            [self->activityView setAlpha:0];
                        }
                        completion:^(BOOL finished) {
                            [self destroySplashViews];
                        }];
    }
}

- (void) destroySplashViews
{
    [self->splashView removeFromSuperview];
    [self->activityView removeFromSuperview];

    self->splashView = nil;
    self->activityView = nil;

    [self.view setUserInteractionEnabled:YES];
}

//TODO: 定义为private方法
- (float) fadeDuration
{
    id fadeSplashScreenValue = [XUtils getPreferenceForKey:FADE_SPLASH_SCREEN];
    id fadeSplashScreenDuration = [XUtils getPreferenceForKey:FADE_SPLASH_SCREEN_DURATION];

    float fadeDurationVal = (nil == fadeSplashScreenDuration) ? SPLASH_SCREEN_DURATION_DEFAULT : [fadeSplashScreenDuration floatValue];

    if ((nil == fadeSplashScreenValue) || ![fadeSplashScreenValue boolValue])
    {
        fadeDurationVal = 0;
    }
    return fadeDurationVal;
}

- (void) showView:(id<XAppView>) appView
{
    [appView show];
}

- (void) closeView:(id<XAppView>)appView
{
    [appView close];
}

/**
    如果存在splash界面，停止显示splash界面，并显示应用视图界面
    Notice:调用者必须在非主线程中，否则会阻塞主线程
    @private
 */
- (void)tryTurnOffSplashAndShowWebView:(UIWebView *)appView
{
    if(splashView)
    {
        [self.view sendSubviewToBack:appView];
        id autoHideSplashScreenValue = [XUtils getPreferenceForKey:AUTO_HIDE_SPLASH_SCREEN];

        // if value is missing, default to yes
       if ((nil == autoHideSplashScreenValue) || [autoHideSplashScreenValue boolValue])
        {
            double delayMillisecond = [[XUtils getPreferenceForKey:SPLASH_SCREEN_DELAY_DURATION] doubleValue];
            // ios平台的sleep以秒为单位
            [NSThread sleepForTimeInterval:delayMillisecond / MILLISECOND_PER_SECOND];
            [self performSelectorOnMainThread:@selector(stopShowingSplash) withObject:nil waitUntilDone:NO];
        }
    }
    [appView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

/**
  @Override
  根据配置信息，判断是否自动转屏到指定方位
 */
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // TODO: ask the webview via JS if it supports the new orientation
    static NSString *orientationFlagNames[] = {
        nil,//UIDeviceOrientationUnknown
        @"UIInterfaceOrientationPortrait",
        @"UIInterfaceOrientationPortraitUpsideDown",
        @"UIInterfaceOrientationLandscapeRight",
        @"UIInterfaceOrientationLandscapeLeft"
    };

    // 如果是iPhone,则读取到的是Info.plist中的UISupportedInterfaceOrientations值
    // 如果是iPad,则读取到的是UISupportedInterfaceOrientations~iPad值
    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary] objectForKey:UI_ORIENTAIONS_TAG];

    BOOL ret = [supportedOrientations containsObject:orientationFlagNames[toInterfaceOrientation]];
    return ret;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger ret = 0;

    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])
    {
        ret = ret | (1 << UIInterfaceOrientationPortrait);
    }
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown])
    {
        ret = ret | (1 << UIInterfaceOrientationPortraitUpsideDown);
    }
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])
    {
        ret = ret | (1 << UIInterfaceOrientationLandscapeRight);
    }
    if ([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])
    {
        ret = ret | (1 << UIInterfaceOrientationLandscapeLeft);
    }

    return ret;
}



- (id) init
{
    self = [super init];
    if (self)
    {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedOrientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];

        self->splashView = nil;
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

BOOL gSplashScreenShown = NO;
- (void)receivedOrientationChange
{
    if (!self->splashView && !gSplashScreenShown)
    {
        gSplashScreenShown = YES;
        [self showSplashIfNeeded];
    }
}

@end
