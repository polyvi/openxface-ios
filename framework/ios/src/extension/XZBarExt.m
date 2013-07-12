
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
//  XZBarExt.m
//  xFaceLib
//
//

#ifdef __XZBarExt__

#import "XZBarExt.h"
#import "XZBarExt_Privates.h"
#import "XExtensionResult.h"
#import "XJsCallback.h"

@implementation XZBarExt

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if(self)
    {
        jsCallback = nil;
        zbarReaderVC = nil;
    }
    return self;
}

- (void) start:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    jsCallback = [self getJsCallback:options];

    //检测有没有camera
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    bool hasCamera = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (!hasCamera)
    {
        XLogE(@"BarcodeScanner can't work !! no camera available");
        XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: @"no camera available"];
        [jsCallback setExtensionResult:result];
        [self sendAsyncResult:jsCallback];
        return;
    }

    [self showBarcodeScanView];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [self hideBarcodeScanView];

    // 处理扫描结果
    ZBarSymbolSet *results = [info objectForKey:ZBarReaderControllerResults];
    if (results != nil && [results count] > 0 )
    {
        NSString *barcodeString = nil;
        // ZBarSymbolSet Conforms to: NSFastEnumeration
        // 详情请参看ZBar SDK文档。
        for(ZBarSymbol *symbol in results)
        {
            //只获取第一个结果
            barcodeString = (NSString*)symbol.data;
            break;
        }
        XExtensionResult *result = nil;
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:barcodeString];
        [jsCallback setExtensionResult:result];
        [self sendAsyncResult:jsCallback];
    }
}

- (void)showBarcodeScanView
{
    if (nil == zbarReaderVC)
    {
        zbarReaderVC = [[ZBarReaderViewController alloc] init];
        float screen_width = self.viewController.view.frame.size.width;
        float screen_height = self.viewController.view.frame.size.height;
        // customOverlay用于在摄像头扫描界面左下方显示一个取消按钮
        UIView *customOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
        customOverlay.backgroundColor = [UIColor clearColor];

        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.opaque = NO;
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.alpha = 0.4;
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(hideBarcodeScanView) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton sizeToFit];
        // 调整取消按钮的坐标
        CGRect buttonFrame = [cancelButton frame];
        buttonFrame.origin.x = 10.0;
        buttonFrame.origin.y = screen_height - buttonFrame.size.height - 10.0;
        [cancelButton setFrame:buttonFrame];
        [customOverlay addSubview:cancelButton];

        // 定制ZBar
        zbarReaderVC.videoQuality = UIImagePickerControllerQualityTypeHigh;
        zbarReaderVC.cameraOverlayView = customOverlay;
        zbarReaderVC.readerDelegate = self;
        zbarReaderVC.supportedOrientationsMask = ZBarOrientationMaskAll;
        // 隐藏ZBar默认的导航栏，只显示自定义的取消按钮
        zbarReaderVC.showsZBarControls = NO;
    }

    [self.viewController presentViewController:zbarReaderVC animated:YES completion:nil];
}

- (void)hideBarcodeScanView
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

#endif
