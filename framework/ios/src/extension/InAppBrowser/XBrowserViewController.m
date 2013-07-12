
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
//  XBrowserViewController.m
//  xFace
//
//

#ifdef __XInAppBrowserExt__

#import "XInAppBrowserExt.h"
#import "XBrowserViewController.h"
#import "XExtensionResult.h"
#import "XJsCallback.h"
#import "XInAppBrowserXHRURLProtocol.h"

#define    TOOLBAR_HEIGHT            44.0
#define    ADDRESSBAR_HEIGHT         30.0
#define    FOOTER_HEIGHT             ((TOOLBAR_HEIGHT) + (ADDRESSBAR_HEIGHT))

#pragma mark XBrowserViewController

@implementation XBrowserViewController

- (id)initWithUserAgent:(NSString*)aUserAgent delegate:(id)aDelegate app:(id<XApplication>)anApp jsCallback:(XJsCallback*)aCallback;
{
    self = [super init];
    if (self != nil) {
        self.userAgent = aUserAgent;
        self->jsCallback = aCallback;
        self->application = anApp;
        self->delegate = aDelegate;
        self->registeredCallback = [[NSMutableDictionary alloc] initWithCapacity:8];
        [self createViews];
        [NSURLProtocol registerClass:[XInAppBrowserXHRURLProtocol class]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBrigdeRequest:)
                                                     name:XFACE_IAB
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSURLProtocol unregisterClass:[XInAppBrowserXHRURLProtocol class]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createViews
{
    // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included

    CGRect webViewBounds = self.view.bounds;

    webViewBounds.size.height -= FOOTER_HEIGHT;
    webViewBounds.origin.y += ADDRESSBAR_HEIGHT;

    if (!self.webView) {
        // setting the UserAgent must occur before the UIWebView is instantiated.
        // This is read per instantiation, so it does not affect the main xFace UIWebView
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.userAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];

        self.webView = [[UIWebView alloc] initWithFrame:webViewBounds];
        self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        [self.view addSubview:self.webView];
        [self.view sendSubviewToBack:self.webView];

        self.webView.delegate = self;
        self.webView.scalesPageToFit = TRUE;
        self.webView.backgroundColor = [UIColor whiteColor];

        self.webView.clearsContextBeforeDrawing = YES;
        self.webView.clipsToBounds = YES;
        self.webView.contentMode = UIViewContentModeScaleToFill;
        self.webView.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
        self.webView.multipleTouchEnabled = YES;
        self.webView.opaque = YES;
        self.webView.scalesPageToFit = NO;
        self.webView.userInteractionEnabled = YES;
    }

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.alpha = 1.000;
    self.spinner.autoresizesSubviews = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.spinner.clearsContextBeforeDrawing = NO;
    self.spinner.clipsToBounds = NO;
    self.spinner.contentMode = UIViewContentModeScaleToFill;
    self.spinner.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.spinner.frame = CGRectMake(454.0, 231.0, 20.0, 20.0);
    self.spinner.hidden = YES;
    self.spinner.hidesWhenStopped = YES;
    self.spinner.multipleTouchEnabled = NO;
    self.spinner.opaque = NO;
    self.spinner.userInteractionEnabled = NO;
    [self.spinner stopAnimating];

    self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.closeButton.enabled = YES;
    self.closeButton.imageInsets = UIEdgeInsetsZero;
    self.closeButton.style = UIBarButtonItemStylePlain;
    self.closeButton.width = 32.000;

    UIBarButtonItem* flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIBarButtonItem* fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceButton.width = 20;

    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, (self.view.bounds.size.height - TOOLBAR_HEIGHT), self.view.bounds.size.width, TOOLBAR_HEIGHT)];
    self.toolbar.alpha = 1.000;
    self.toolbar.autoresizesSubviews = YES;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    self.toolbar.clearsContextBeforeDrawing = NO;
    self.toolbar.clipsToBounds = NO;
    self.toolbar.contentMode = UIViewContentModeScaleToFill;
    self.toolbar.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.toolbar.hidden = NO;
    self.toolbar.multipleTouchEnabled = NO;
    self.toolbar.opaque = NO;
    self.toolbar.userInteractionEnabled = YES;

    self.addressBar = [[UITextField alloc] initWithFrame:CGRectMake(0.0, (self.view.bounds.origin.y), self.view.bounds.size.width, ADDRESSBAR_HEIGHT)];
    [self.addressBar setReturnKeyType:UIReturnKeyGo];
    self.addressBar.alpha = 1.000;
    self.addressBar.autoresizesSubviews = YES;
    self.addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.addressBar.clearsContextBeforeDrawing = YES;
    self.addressBar.clipsToBounds = YES;
    self.addressBar.contentMode = UIViewContentModeScaleToFill;
    self.addressBar.contentStretch = CGRectFromString(@"{{0, 0}, {1, 1}}");
    self.addressBar.enabled = YES;
    self.addressBar.hidden = NO;
    self.addressBar.opaque = NO;
    self.addressBar.textColor = [UIColor blackColor];
    self.addressBar.userInteractionEnabled = YES;
    self.addressBar.borderStyle = UITextBorderStyleRoundedRect;
    self.addressBar.delegate = self;

    NSString* frontArrowString = @"►"; // create arrow from Unicode char
    self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:frontArrowString style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    self.forwardButton.enabled = YES;
    self.forwardButton.imageInsets = UIEdgeInsetsZero;

    NSString* backArrowString = @"◄"; // create arrow from Unicode char
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:backArrowString style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    self.backButton.enabled = YES;
    self.backButton.imageInsets = UIEdgeInsetsZero;

    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    [self.toolbar setItems:@[self.closeButton, flexibleSpaceButton, self.backButton, fixedSpaceButton, self.forwardButton, fixedSpaceButton, self.refreshButton]];

    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.addressBar];
    [self.view addSubview:self.spinner];
}

- (void)showLocationBar:(BOOL)show
{
    CGRect addressBarFrame = self.addressBar.frame;
    BOOL locationBarVisible = (addressBarFrame.size.height > 0);

    // prevent double show/hide
    if (locationBarVisible == show) {
        return;
    }

    if (show) {
        CGRect webViewBounds = self.view.bounds;
        webViewBounds.size.height -= FOOTER_HEIGHT;
        webViewBounds.origin.y += FOOTER_HEIGHT;
        self.webView.frame = webViewBounds;

        CGRect addressBarFrame = self.addressBar.frame;
        addressBarFrame.size.height = ADDRESSBAR_HEIGHT;
        self.addressBar.frame = addressBarFrame;
    } else {
        CGRect webViewBounds = self.view.bounds;
        webViewBounds.size.height -= TOOLBAR_HEIGHT;
        self.webView.frame = webViewBounds;

        CGRect addressBarFrame = self.addressBar.frame;
        addressBarFrame.size.height = 0;
        self.addressBar.frame = addressBarFrame;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)close
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self->delegate browserExitWithApp:self->application callback:self->jsCallback];
}

- (void)navigateTo:(NSURL*)url
{
    NSURLRequest* request = [NSURLRequest requestWithURL:url];

    [self.webView loadRequest:request];
}

- (void)goBack:(id)sender
{
    [self.webView goBack];
}

- (void)goForward:(id)sender
{
    [self.webView goForward];
}

- (void)refresh:(id)sender
{
    [self.webView reload];
}

-(NSString*) evaljs:(NSString*)code
{
    return [self.webView stringByEvaluatingJavaScriptFromString:code];
}

-(void) loadJsFile:(NSString*)src callback:(BOOL(^)(void))callback
{
    [registeredCallback setObject:callback forKey:@((long long)callback)];
    NSString* js = [NSString stringWithFormat:
                    @"(function(d) {\
                    var c = d.createElement('script');\
                    c.src = '%@';\
                    c.onload = function()\
                    {\
                        execXhr = new XMLHttpRequest();\
                        execXhr.open('HEAD', 'http://xfaceiab/%lld', true);\
                        execXhr.send(null);\
                    };\
                    d.body.appendChild(c);\
                    })(document)",
                    src, (long long)callback];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

-(void) insertCSS:(NSString*)code callback:(BOOL(^)(void))callback
{
    [registeredCallback setObject:callback forKey:@((long long)callback)];
    NSString* js = [NSString stringWithFormat:@"(function(d) { \
                    var c = d.createElement('style'); \
                    c.innerHTML = '%@'; \
                    c.onload = function()\
                    {\
                        execXhr = new XMLHttpRequest();\
                        execXhr.open('HEAD', 'http://xfaceiab/%lld', true);\
                        execXhr.send(null);\
                    }; \
                    d.body.appendChild(c); \
                    })(document)", code, (long long)callback];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

-(void) loadCSSFile:(NSString*)src callback:(BOOL(^)(void))callback
{
    [registeredCallback setObject:callback forKey:@((long long)callback)];
    NSString* js = [NSString stringWithFormat:@"(function(d){ \
                    var c = d.createElement('link'); \
                    c.rel='stylesheet'; \
                    c.type='text/css'; \
                    c.href = '%@'; \
                    c.onload = function() \
                    { \
                        execXhr = new XMLHttpRequest();\
                        execXhr.open('HEAD', 'http://xfaceiab/%lld', true);\
                        execXhr.send(null);\
                    };\
                    d.body.appendChild(c); \
                    })(document)", src, (long long)callback];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark - private APIs

- (void)handleBrigdeRequest:(NSNotification*)notification
{
    NSURLRequest* request =notification.object;
    NSString* callbackAddr = [request.URL path];
    callbackAddr = [callbackAddr substringFromIndex:1];
    id key = @((long long)[callbackAddr longLongValue]);

    BOOL (^callbackBlock)(void) = [registeredCallback objectForKey:key];
    if (callbackBlock &&  !callbackBlock()) {
        [registeredCallback removeObjectForKey:key];
    }

}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)theWebView
{
    // loading url, start spinner, update back/forward
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;

    [self.spinner startAnimating];

    [self->delegate browserLoadStart:theWebView.request.URL app:self->application callback:self->jsCallback];
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // update url, stop spinner, update back/forward

    self.addressBar.text = theWebView.request.URL.absoluteString;
    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;

    [self.spinner stopAnimating];

    [self->delegate browserLoadStop:theWebView.request.URL app:self->application callback:self->jsCallback];
}

- (void)webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    // log fail message, stop spinner, update back/forward
    XLogE(@"webView:didFailLoadWithError - %@", [error localizedDescription]);

    self.backButton.enabled = theWebView.canGoBack;
    self.forwardButton.enabled = theWebView.canGoForward;
    [self.spinner stopAnimating];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    if (theTextField == self.addressBar)
    {
        [self.addressBar resignFirstResponder];
        //go to the new url
        [self navigateTo:[NSURL URLWithString:theTextField.text]];
    }
    return YES;
}

@end

#pragma mark browser options

@implementation XInAppBrowserOptions

- (id)init
{
    if (self = [super init]) {
        // default values
        self.location = YES;
    }

    return self;
}

+ (XInAppBrowserOptions*)parseOptions:(NSString*)options
{
    XInAppBrowserOptions* obj = [[XInAppBrowserOptions alloc] init];

    // NOTE: this parsing does not handle quotes within values
    NSArray* pairs = [options componentsSeparatedByString:@","];

    // parse keys and values, set the properties
    for (NSString* pair in pairs) {
        NSArray* keyvalue = [pair componentsSeparatedByString:@"="];

        if ([keyvalue count] == 2) {
            NSString* key = [[keyvalue objectAtIndex:0] lowercaseString];
            NSString* value = [keyvalue objectAtIndex:1];
            BOOL valueBool = [[value lowercaseString] isEqualToString:@"yes"];

            // set the property according to the key name
            if ([obj respondsToSelector:NSSelectorFromString(key)]) {
                [obj setValue:[NSNumber numberWithBool:valueBool] forKey:key];
            }
        }
    }

    return obj;
}

@end

#endif
