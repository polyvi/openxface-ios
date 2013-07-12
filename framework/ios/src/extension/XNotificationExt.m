
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
//  XNotificationExt.m
//  xFaceLib
//
//

#ifdef __XNotificationExt__

#import "XNotificationExt.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"

@implementation XNotificationExt

- (id)initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    if (self) {
        NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"beep"
                                                    withExtension: @"aiff"];

        self->soundFileURLRef = (__bridge CFURLRef)(tapSound);
        AudioServicesCreateSystemSoundID (
                                          self->soundFileURLRef,
                                          &soundFileObject
                                          );

    }
    return self;
}

- (void) alert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    int argc = [arguments count];
    XJsCallback *callback = [self getJsCallback:options];

    NSString* message = argc > 0 ? [arguments objectAtIndex:0] : nil;
    NSString* title   = argc > 1 ? [arguments objectAtIndex:1] : nil;
    NSString* buttons = argc > 2 ? [arguments objectAtIndex:2] : nil;

    if (!title)
    {
        title = NSLocalizedString(@"Alert", @"Alert");
    }
	if (!buttons)
    {
        buttons = NSLocalizedString(@"OK", @"OK");
    }

    XAlertView *alertView = [[XAlertView alloc]
                               initWithTitle:title
                               message:message
                               delegate:self
                               cancelButtonTitle:nil
                               otherButtonTitles:nil];

    alertView.callback = callback;

    NSArray* labels = [buttons componentsSeparatedByString:@","];
    int count = [labels count];

    for(int index = 0; index < count; index++)
    {
        [alertView addButtonWithTitle:[labels objectAtIndex:index]];
    }

    [alertView show];
}

- (void) confirm:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    int argc = [arguments count];
    NSString* message = argc > 0 ? [arguments objectAtIndex:0] : nil;
    NSString* title   = argc > 1 ? [arguments objectAtIndex:1] : nil;
    NSString* buttons = argc > 2 ? [arguments objectAtIndex:2] : nil;

    if (!title)
    {
        title = NSLocalizedString(@"Confirm", @"Confirm");
    }
    if (!buttons)
    {
        buttons = NSLocalizedString(@"OK,Cancel", @"OK,Cancel");
    }

    NSMutableArray* newArguments = [NSMutableArray arrayWithObjects:message, title, buttons, nil];
    [self alert: newArguments withDict:options];
}

- (void) vibrate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void) beep:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    AudioServicesPlaySystemSound(soundFileObject);
}
/**
    Callback invoked when an alert dialog's buttons are clicked.
    Passes the index + label back to JS
 */
- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    XAlertView* xAlertView = (XAlertView*) alertView;
    XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_OK messageAsInt: ++buttonIndex];

    XJsCallback *callback = xAlertView.callback;
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

@end

@implementation XAlertView

@synthesize callback;

@end

#endif
