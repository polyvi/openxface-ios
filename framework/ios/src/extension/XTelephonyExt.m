
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
//  XTelephonyExt.m
//  xFace
//
//

#ifdef __XTelephonyExt__

#import "XTelephonyExt.h"
#import "XTelephonyExt_Privates.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XQueuedMutableArray.h"
#import "XJsCallback.h"

@implementation XTelephonyExt

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    self = [super initWithMsgHandler:msgHandler];
    return self;
}

- (BOOL)isTelePhoneNumber:(NSString *)phoneNumber
{
    NSString * regExpression = @"[+*#\\d]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExpression];

    return [predicate evaluateWithObject:phoneNumber];
}

- (void) initiateVoiceCall:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString *phoneNumber = [arguments objectAtIndex:0];

    XExtensionResult *result = nil;
    UIDevice *device = [UIDevice currentDevice];
    if( [self isTelePhoneNumber:phoneNumber] && [[device model] isEqualToString:@"iPhone"] )
    {
        NSString *tel = [NSString stringWithFormat:@"telprompt://%@",phoneNumber];
        NSURL *url = [NSURL URLWithString:tel];
        if([[UIApplication sharedApplication] openURL:url])//YES, means success
        {
            result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:@"phone call success"];
        }
        else
        {
            result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:@"phone call error"];
        }
    }
    else
    {
        result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsObject:@"phone call error"];
    }

    [callback setExtensionResult:result];
    // 将扩展结果返回给js端
    [self->jsEvaluator eval:callback];
}

@end

#endif
