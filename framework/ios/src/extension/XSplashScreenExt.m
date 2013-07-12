
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
// XSplashScreenExt.m
//  xFace
//
//

#ifdef __XSplashScreenExt__

#import "XSplashScreenExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XQueuedMutableArray.h"
#import "XUtils.h"
#import "XJsCallback.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "UIDevice+Additions.h"
#import "XSplashScreenExt_Privates.h"

@implementation XSplashScreenExt

- (void)hide:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    XExtensionResult *result = nil;
    result = [XExtensionResult resultWithStatus:(splashView != nil ? STATUS_OK : STATUS_ERROR)];

    //隐藏native splash
    id autoHideSplashScreenValue = [XUtils getPreferenceForKey:AUTO_HIDE_SPLASH_SCREEN];
    if (autoHideSplashScreenValue && ![autoHideSplashScreenValue boolValue])
    {
        [self.viewController performSelectorOnMainThread:@selector(stopShowingSplash) withObject:nil waitUntilDone:NO];
    }

    //隐藏扩展splash
    [self hide];

    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (void)show:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    XExtensionResult *result = nil;

    id<XApplication> app = [self getApplication:options];
    NSString* imagePath = [arguments objectAtIndex:0 withDefault:nil];

    imagePath = [XUtils resolvePath:imagePath usingWorkspace:[app getWorkspace]];
    UIImage *image = [self getImage:imagePath];
    BOOL ret = [self showSplashWithImage:image inApp:app];

    result = [XExtensionResult resultWithStatus:(ret ? STATUS_OK : STATUS_ERROR)];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

-(void)onPageStarted:(NSString *)appId
{
    [self hide];
}

#pragma mark Privates

- (UIImage*)getImage:(NSString *)imagePath
{
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if(nil == image)
    {
        NSString *imageFile = [XUtils resolveSplashScreenImageResourceWithOrientation:self.viewController.interfaceOrientation];
        image = [UIImage imageNamed:imageFile];

        if (([UIDevice deviceType] & IPHONE)
            && ((UIDeviceOrientationLandscapeRight == self.viewController.interfaceOrientation)
                || (UIDeviceOrientationLandscapeLeft == self.viewController.interfaceOrientation)))
        {
            //当iPhone处于横屏时，需要调整图片的朝向，否则图片显示会发生变形
            UIImageOrientation imgOrientation = (UIDeviceOrientationLandscapeLeft == self.viewController.interfaceOrientation) ? UIImageOrientationLeft : UIImageOrientationRight;
            image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:imgOrientation];
        }
    }
    return image;
}

- (BOOL) showSplashWithImage:(UIImage*)image inApp:(id<XApplication>)app
{
    [self hide];
    splashView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [splashView setImage:image];
    [(UIView*)app.appView addSubview:splashView];
    [self.viewController.view setUserInteractionEnabled:NO];

    [self updateBounds];
    return YES;
}

- (void)updateBounds
{
    UIImage* img = splashView.image;
    if (!img)
    {
        return;
    }

    CGRect imgBounds = CGRectMake(0, 0, img.size.width, img.size.height);
    CGSize screenSize = [self.viewController.view convertRect:[UIScreen mainScreen].bounds fromView:nil].size;

    // There's a special case when the image is the size of the screen.
    if (CGSizeEqualToSize(screenSize, imgBounds.size))
    {
        CGRect statusFrame = [self.viewController.view convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
        imgBounds.origin.y -= statusFrame.size.height;
    }
    else
    {
        CGRect viewBounds = self.viewController.view.bounds;
        CGFloat imgAspect = imgBounds.size.width / imgBounds.size.height;
        CGFloat viewAspect = viewBounds.size.width / viewBounds.size.height;
        CGFloat ratio;
        if (viewAspect > imgAspect)
        {
            ratio = viewBounds.size.width / imgBounds.size.width;
        }
        else
        {
            ratio = viewBounds.size.height / imgBounds.size.height;
        }
        imgBounds.size.height *= ratio;
        imgBounds.size.width *= ratio;
    }

    splashView.frame = imgBounds;
}

- (void) hide
{
    [splashView removeFromSuperview];
    splashView = nil;
    [self.viewController.view setUserInteractionEnabled:YES];
}

@end

#endif
