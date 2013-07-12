
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
//  XBrowserViewController.h
//  xFace
//
//

#ifdef __XInAppBrowserExt__



/*
   浏览器界面控制器
 */
@interface XBrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate>
{
    id delegate;
    XJsCallback* jsCallback;
    id<XApplication> application;
    NSMutableDictionary* registeredCallback;
}

@property (nonatomic, strong)  UIWebView* webView;
@property (nonatomic, strong)  UIBarButtonItem* closeButton;
@property (nonatomic, strong)  UITextField* addressBar;
@property (nonatomic, strong)  UIBarButtonItem* backButton;
@property (nonatomic, strong)  UIBarButtonItem* forwardButton;
@property (nonatomic, strong)  UIBarButtonItem* refreshButton;
@property (nonatomic, strong)  UIActivityIndicatorView* spinner;
@property (nonatomic, strong)  UIToolbar* toolbar;

@property (nonatomic, strong) NSString* userAgent;

/**
   关闭浏览器
 */
- (void)close;

/**
   转到指定的url
   @param url 指定的url
 */
- (void)navigateTo:(NSURL*)url;

/**
   显示地址栏
   @param show 是否显示
 */
- (void)showLocationBar:(BOOL)show;

/**
    初始化方法
    @param aUserAgent  用户代理
    @param aDelegate   浏览器事件代理
    @param anApp       拥有该浏览器对象的app
    @param aCallback   js回调器
    @returns 初始化后的XBrowserViewController对象，如果初始化失败，则返回nil
 */
- (id)initWithUserAgent:(NSString*)aUserAgent delegate:(id)aDelegate app:(id<XApplication>)anApp jsCallback:(XJsCallback*)aCallback;

/**
    执行js
    @param code 要执行的js代码
    @returns js的执行结果
 */
-(NSString*) evaljs:(NSString*)code;

/**
    加载指定的js文件
    @param src js文件的源地址
    @param callback onload回调
 */
-(void) loadJsFile:(NSString*)src callback:(BOOL(^)(void))callback;

/**
    插入css元素
    @param code css的代码
    @param callback onload回调
 */
-(void) insertCSS:(NSString*)code callback:(BOOL(^)(void))callback;

/**
    加载指定的css文件
    @param src css文件的源地址
    @param callback onload回调
 */
-(void) loadCSSFile:(NSString*)src callback:(BOOL(^)(void))callback;

@end

/*
   特性列表
 */
@interface XInAppBrowserOptions : NSObject

@property (nonatomic, assign) BOOL location;

/*
   解析特性列表
   一个特定格式的字符串解析为特性列表，
   例如将字符串location=yes,foo=yes,bar=no 转换成
   XInAppBrowserOptions.location =YES;
   XInAppBrowserOptions.foo = YES;
   XInAppBrowserOptions.bar = NO;
*/
+ (XInAppBrowserOptions*)parseOptions:(NSString*)options;

@end

#endif
