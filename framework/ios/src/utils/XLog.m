
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
//  XLog.m
//  xFace
//
//

#import "XLog.h"
#import "XLogRedirect.h"

#define TAG_NAME @"xface"

@implementation XLog

+(void) logV:(NSString*)className msg:(NSString*)msg
{
    NSString* s = [self constructLogMessage:className msg:msg logLevel:@"Verbose"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logV:@"xface" msg:s];
}

+(void) logD:(NSString*)className msg:(NSString*)msg
{
    NSString* s = [self constructLogMessage:className msg:msg logLevel:@"Debug"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logD:@"xface" msg:s];
}

+(void) logI:(NSString*)className msg:(NSString*)msg
{
    NSString* s = [self constructLogMessage:className msg:msg logLevel:@"Info"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logI:@"xface" msg:s];
}

+(void) logW:(NSString*)className msg:(NSString*)msg
{
    NSString* s = [self constructLogMessage:className msg:msg logLevel:@"Warning"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logW:@"xface" msg:s];
}

+(void) logE:(NSString*)className msg:(NSString*)msg
{
    NSString* s = [self constructLogMessage:className msg:msg logLevel:@"Error"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logE:@"xface" msg:s];
}

+(void) close
{
    [[XLogRedirect getInstance] close];
}

+(NSString *) constructLogMessage:(NSString *)className msg:(NSString *)msg logLevel:(NSString *)logLevel
{
    return [NSString stringWithFormat:@"[%@] [__%@__] %@\n", className, logLevel, msg];
}

@end
