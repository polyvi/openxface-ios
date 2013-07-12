
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
//  XAppInstallListenerLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAppInstallListener.h"
#import "XExtensionResult.h"
#import "XMessenger.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XJsCallback.h"
#import "XApplicationFactory.h"
#import "XAppInfo.h"
#import "XAppList.h"
#import "XConstants.h"
#import "XAppViewStub.h"
#import "XConstantsLogicTests.h"

#define XAPP_INSTALL_LISTENER_LOGIC_TESTS_WEB_APP_ID         @"webApp"
#define XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID             @"app"

@interface XAppInstallListenerLogicTests : SenTestCase
{
    XMessenger           *messenger;
    XJavaScriptEvaluator *jsEvaluator;
    XJsCallback          *jsCallback;
    XAppInstallListener  *listener;
}

@end

@implementation XAppInstallListenerLogicTests

- (void)setUp
{
    [super setUp];

    XAppList *appList = [[XAppList alloc] init];
    self->messenger = [[XMessenger alloc] init];
    NSString *callbackId = INVALID_CALLBACK_ID;
    self->jsCallback  = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:nil];

    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_WEB_APP_ID];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];

    self->jsEvaluator = webApp.jsEvaluator;

    XAppViewStub *stub = [[XAppViewStub alloc] init];
    [webApp setAppView:stub];

    [appList add:webApp];
    [appList markAsDefaultApp:XAPP_INSTALL_LISTENER_LOGIC_TESTS_WEB_APP_ID];

    self->listener = [[XAppInstallListener alloc] initWithMessenger:self->messenger messageHandler:self->jsEvaluator callback:self->jsCallback];
    STAssertNotNil(self->listener, @"Failed to create XAppInstallListener instance");
}

- (void)testInit
{
    // app为web app
    XAppInfo *webAppInfo = [[XAppInfo alloc] init];
    [webAppInfo setAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_WEB_APP_ID];
    id<XApplication> webApp = [XApplicationFactory create:webAppInfo];
    XAppViewStub *stub = [[XAppViewStub alloc] init];
    [webApp setAppView:stub];

    XAppInstallListener *listenerForWebApp = nil;

    STAssertNoThrow((listenerForWebApp = [[XAppInstallListener alloc] initWithMessenger:self->messenger messageHandler:self->jsEvaluator callback:self->jsCallback]), nil);

    STAssertNotNil(listenerForWebApp, nil);

    // app为native app的情况
    XAppInfo *nativeAppInfo = [[XAppInfo alloc] init];
    [nativeAppInfo setAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_WEB_APP_ID];
    [nativeAppInfo setType:APP_TYPE_NAPP];
    id<XApplication> nativeApp = [XApplicationFactory create:nativeAppInfo];
    XAppInstallListener *listenerForNativeApp = nil;

    STAssertNoThrow((listenerForNativeApp = [[XAppInstallListener alloc] initWithMessenger:self->messenger messageHandler:self->jsEvaluator callback:self->jsCallback]), nil);

    STAssertNotNil(listenerForNativeApp, nil);
}

- (void)testOnProgressUpdated
{
    STAssertNoThrow([self->listener onProgressUpdated:INSTALL withStatus:INITIALIZED], nil);
    STAssertNoThrow([self->listener onProgressUpdated:UPDATE withStatus:INSTALLING], nil);
    STAssertNoThrow([self->listener onProgressUpdated:UNINSTALL withStatus:UPDATING_CONFIGURATION], nil);
}

- (void)testOnSuccess
{
    STAssertThrows([self->listener onSuccess:INSTALL withAppId:nil], nil);
    STAssertThrows([self->listener onSuccess:UPDATE withAppId:@""], nil);

    STAssertNoThrow([self->listener onSuccess:INSTALL withAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID], nil);
    STAssertNoThrow([self->listener onSuccess:UPDATE withAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID], nil);
    STAssertNoThrow([self->listener onSuccess:UNINSTALL withAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID], nil);
}

- (void)testOnError
{
    STAssertNoThrow([self->listener onError:INSTALL withAppId:nil withError:NO_APP_CONFIG_FILE], nil);
    STAssertNoThrow([self->listener onError:UPDATE withAppId:@"" withError:NO_SRC_PACKAGE], nil);

    STAssertNoThrow([self->listener onError:INSTALL withAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID withError:APP_ALREADY_EXISTED], nil);
    STAssertNoThrow([self->listener onError:UPDATE withAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID withError:NO_TARGET_APP], nil);
    STAssertNoThrow([self->listener onError:UNINSTALL withAppId:XAPP_INSTALL_LISTENER_LOGIC_TESTS_APP_ID withError:IO_ERROR], nil);
}

@end
