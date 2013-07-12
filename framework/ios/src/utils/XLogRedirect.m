
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
//  XLogRedirect.m
//  xFace
//
//

#import "XLogRedirect.h"
#import "XUtils.h"

#define LEVEL_V   @"verbose:"
#define LEVEL_D   @"debug:"
#define LEVEL_I   @"info:"
#define LEVEL_W   @"warn:"
#define LEVEL_E   @"error:"

#define PORT      6656
#define CLOSESIGNAL  @"close_signal"

@implementation XLogRedirect

static XLogRedirect *instance;


-(void) logV:(NSString *)tag msg:(NSString *)msg
{
    NSString* s = [NSString stringWithFormat:@"%@%@%@", LEVEL_V, tag, msg];
    [self log:s];
}

-(void) logD:(NSString *)tag msg:(NSString *)msg
{
    NSString* s = [NSString stringWithFormat:@"%@%@%@", LEVEL_D, tag, msg];
    [self log:s];
}

-(void) logI:(NSString *)tag msg:(NSString *)msg
{
    NSString* s = [NSString stringWithFormat:@"%@%@%@", LEVEL_I, tag, msg];
    [self log:s];
}

-(void) logW:(NSString *)tag msg:(NSString *)msg
{
    NSString* s = [NSString stringWithFormat:@"%@%@%@", LEVEL_W, tag, msg];
    [self log:s];
}

-(void) logE:(NSString *)tag msg:(NSString *)msg
{
    NSString* s = [NSString stringWithFormat:@"%@%@%@", LEVEL_E, tag, msg];
   [self log:s];
}

+ (XLogRedirect *) getInstance
{
    if (nil == instance) {
        instance = [[XLogRedirect alloc] init];
        [instance connect];
    }
    return instance;
}

#pragma mark privates

-(void) log:(NSString *)msg
{
    NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    if(NSStreamStatusOpening == outputStream.streamStatus)
    {
        [self->dataBuf appendData:data];
    } else
    {
        [self->outputStream write:[data bytes] maxLength:data.length];
    }
}

- (void)connect
{
    NSString* ip = [XUtils getIpFromDebugConfig];
    if(ip.length == 0)
    {
        return;
    }
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, PORT, &readStream, &writeStream);
    self->inputStream = (__bridge_transfer NSInputStream *)readStream;
    self->outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self->inputStream setDelegate:self];
    [self->outputStream setDelegate:self];
    [self->inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self->outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self->inputStream open];
    [self->outputStream open];
    self->dataBuf = [NSMutableData data];
}

-(void) close
{
    if (self->outputStream)
    {
        [self->dataBuf appendData:[CLOSESIGNAL dataUsingEncoding:NSUTF8StringEncoding]];
        [self->outputStream write:[dataBuf bytes] maxLength:dataBuf.length];
    }
    [self cleanup];
}

-(void) cleanup
{
    [self->outputStream close];
    [self->inputStream close];
    self->outputStream = nil;
    self->inputStream = nil;
    self->dataBuf = nil;
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            if (self->dataBuf.length > 0 && self->outputStream)
            {
                int n = [self->outputStream write:[dataBuf bytes] maxLength:dataBuf.length];
                //如果放送成功，就清除已发送的数据
                if (n != -1)
                {
                    [self->dataBuf setLength:0];
                }
            }
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            [self cleanup];
            break;
        }
        default:break;
    }
}
@end
