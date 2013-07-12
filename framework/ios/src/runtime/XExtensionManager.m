
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
//  XExtensionManager.m
//  xFace
//
//

#import "XExtensionManager.h"
#import "XCommand.h"
#import "XExtension.h"
#import "NSObject+JSONSerialization.h"
#import "XConstants.h"
#import "XApplication.h"
#import "XJavaScriptEvaluator.h"
#import "XExtensionResult.h"
#import "XRootViewController.h"
#import "XExtensionManager_Privates.h"
#import "XExtension.h"
#import "XUtils.h"
#import "XJsCallback.h"
#import "XCommandQueue.h"
#import "iToast.h"
#import "XLocalStorageExt.h"
#import "XConfiguration.h"
#import "XSystemConfigInfo.h"

#define EXTENSION_MAP_INITIAL_CAPACITY                 4

#define CLOSE_XAPPLICATION_COMMAND                     @"closeApplication"
#define XAPPLICATION_SEND_MESSAGE_COMMAND              @"appSendMessage"

@implementation XExtensionManager

@synthesize extensionObjects;
@synthesize rootViewController;
@synthesize commandQueue;
@synthesize extensionsDict;

- (id) initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self)
    {
        self->_app = app;
        self.extensionsDict = [[[XConfiguration getInstance] systemConfigInfo] extensionsDict];

        //TODO:以后会通过配置文件加载XLocalStorageExt模块
        //TODO:只有iOS 5.1及其以上的版本才有可能需要注册XLocalStorageExt
        self.extensionObjects = [[NSMutableDictionary alloc] initWithCapacity:EXTENSION_MAP_INITIAL_CAPACITY];
        XLocalStorageExt *localStorageExt = [[XLocalStorageExt alloc] initWithMsgHandler:_app.jsEvaluator];
        [self registerExtension:localStorageExt withName:EXTENSION_LOCAL_STORAGE_NAME];
        self.rootViewController = [XUtils rootViewController];
        self.commandQueue = [[XCommandQueue alloc] initWithApp:app];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fireDocumentEvent:)
                                                     name:DOCUMENT_EVENT_NOTIFICATION object:nil];
    }
    return self;
}

- (BOOL) registerExtension:(XExtension*)extension withName:(NSString *)extensionName
{
    NSAssert((nil == [self.extensionObjects objectForKey:extensionName]), nil);

    [self.extensionObjects setObject:extension forKey:extensionName];
    //让扩展对象拥有rootViewController
    if ([extension respondsToSelector:@selector(setViewController:)]) {
        [extension setViewController:(UIViewController*)self.rootViewController];
    }
    return YES;
}

- (BOOL) exec:(XCommand *)cmd
{
    //TODO:由XCommandQueue负责执行command

    if ([self tryExecuteXApplicationCmd:cmd])
    {
        return YES;
    }

    if (cmd.className == nil || cmd.methodName == nil) {
        return NO;
    }

    // Fetch an instance of this class
    XExtension* obj = [self getCommandInstance:cmd.className];
    if (!([obj isKindOfClass:[XExtension class]]))
    {
        XLogE(@"ERROR: XExtension '%@' not found, or is not an extension. Check your extension mapping in config.xml!", cmd.className);

        return NO;
    }

    NSString *callbackId = [cmd callbackId];
    // construct the fill method name to ammend the second argument.
    NSString *fullMethodName = [[NSString alloc] initWithFormat:@"%@:withDict:", cmd.methodName];
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([obj class]) withMethod:fullMethodName];

    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];
    // 将callback对象放入options中
    [options setObject:callback forKey:JS_CALLBACK_KEY];

    // 执行扩展命令
    BOOL retVal = [obj respondsToSelector:NSSelectorFromString(fullMethodName)];
    if (retVal)
    {
        [_app registerJsCallback:callbackKey withCallback:callback];

        // 将调用该扩展的app放入options中
        [options setObject:_app forKey:APPLICATION_KEY];
        NSMutableArray *extArguments = [NSMutableArray arrayWithObjects:obj, fullMethodName, cmd.arguments, options, nil];

        if ([obj shouldExecuteInBackground:fullMethodName])
        {
            [XUtils performSelectorInBackgroundWithTarget:self selector:@selector(executeExtension:) withObject:extArguments];
        }
        else
        {
            [self executeExtension:extArguments];
        }
    }
    else
    {
        // There's no method to call, so throw an error.
        XLogE(@"Error: method '%@' not defined in Extension '%@'", fullMethodName, cmd.className);
    }
    return retVal;
}

- (id) getCommandInstance:(NSString *)extensionName
{
    id obj = [self.extensionObjects objectForKey:extensionName];
    if (!obj)
    {
        // ams扩展由XRuntime创建
        if ([extensionName isEqualToString:EXTENSION_AMS_NAME])
        {
            XLogE(@"Error:%@ should not be non-existent", extensionName);
            return nil;
        }

        // 扩展集合中不存在相应的对象时，则需创建相应的对象并添加到扩展对象集合中
        NSString *extNativeName = [self.extensionsDict objectForKey:extensionName];
        XJavaScriptEvaluator* jsEvaluator = _app.jsEvaluator;
        obj = [[NSClassFromString(extNativeName) alloc] initWithMsgHandler:jsEvaluator];
        if (nil != obj)
        {
            //注册扩展对象，让扩展对象拥有rootViewController.
            [self registerExtension:obj withName:extensionName];
        }
        else
        {
            XLogE(@"extensionName: %@ is non-existent.", extensionName);

            NSString* toastInfo = [NSString stringWithFormat:@"There's no such %@ extension registered!", extensionName];
            [[[[iToast makeText:toastInfo] setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
        }
    }
    return obj;
}

- (void) executeExtension:(NSArray*)arguments
{
    XExtension *obj              = [arguments objectAtIndex:0];
    NSString *fullMethodName     = [arguments objectAtIndex:1];
    NSMutableArray *cmdArgs      = [arguments objectAtIndex:2];
    NSMutableDictionary *options = [arguments objectAtIndex:3];

    [obj performSelector:NSSelectorFromString(fullMethodName) withObject:cmdArgs withObject:options];
}

- (BOOL) tryExecuteXApplicationCmd:(XCommand *)cmd
{
    NSString *cmdMethodName = cmd.methodName;
    if (![self isXApplicationCmd:cmdMethodName])
    {
        return NO;
    }

    if ([CLOSE_XAPPLICATION_COMMAND isEqualToString:cmdMethodName])
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_CLOSE_NOTIFICATION object:_app]];
    }
    else if ([XAPPLICATION_SEND_MESSAGE_COMMAND isEqualToString:cmdMethodName])
    {
        NSString *msgId = [cmd.arguments objectAtIndex:0];

        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_SEND_MESSAGE_NOTIFICATION object:_app userInfo:@{@"msgId": msgId}]];
    }
    else
    {
         NSAssert(NO, nil);
    }

    return YES;
}

- (BOOL) isXApplicationCmd:(NSString *)cmdMethodName
{
    BOOL ret = NO;
    if ([CLOSE_XAPPLICATION_COMMAND isEqualToString:cmdMethodName] ||
        [XAPPLICATION_SEND_MESSAGE_COMMAND isEqualToString:cmdMethodName])
    {
        ret = YES;
    }
    return ret;
}

- (void) onAppClosed:(NSString *)appId
{
    //得到词典中所有Value值
    NSEnumerator * enumeratorValue = [self.extensionObjects objectEnumerator];

    for (XExtension *extension in enumeratorValue)
    {
        [extension onAppClosed:appId];
    }
}

- (void) onAppWillUninstall:(NSString *)appId
{
    //得到词典中所有Value值
    NSEnumerator * enumeratorValue = [self.extensionObjects objectEnumerator];

    for (XExtension *extension in enumeratorValue)
    {
        [extension onAppWillUninstall:appId];
    }
}

- (void) onPageStarted:(NSString*)appId
{
    // 当一个app中发生页面切换时，清除该app注册的所有回调
    [_app clearJsCallbacks];
    // 清除js框架（xface.js）中command queue中缓存的扩展命令，因为js的执行与native从
    // command queue中取命令是在两个不同的线程中执行，在切换页面并清除native的js回调时，
    // 在js端的command queue中可能存在还没有取出来的老页面的命令，这种情况下需要在页面
    // 切换时一并清除。
    [self.commandQueue clearJsCommandQueue];
    NSEnumerator * enumeratorValue = [self.extensionObjects objectEnumerator];

    //得到词典中所有Value值
    for (XExtension *extension in enumeratorValue)
    {
        [extension onPageStarted:appId];
    }
}

- (void)dealloc
{
    [self->commandQueue dispose];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - document event

- (void)fireDocumentEvent:(NSNotification*)notification
{
    NSString* js = [[notification userInfo] objectForKey:@"js"];

    XJsCallback *callback = [[XJsCallback alloc] init];
    [callback setJsScript:js];
    [_app.jsEvaluator eval:callback];
}

@end
