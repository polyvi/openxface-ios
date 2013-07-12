
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
//  XUIApplication.m
//  xFaceLib
//
//

#import "XUIApplication.h"
#import "XConstants.h"

@implementation XUIApplication

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimeoutInterval:)
                                                     name:UPDATE_TIMEOUT_INTERVAL_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        self->timeoutInterval = 0;
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
   用户操作监听
 */
-(void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];

    if (((UITouch *)[[event allTouches] anyObject]).phase == UITouchPhaseBegan)
    {
       [self resetIdleTimer];
    }
}

/*
    更新用户长时间无操作监听的定时器超时时间
 */
-(void)updateTimeoutInterval:(NSNotification*)notification
{
    NSNumber *timeout  = [[notification userInfo] objectForKey:@"timeout"];
    self->timeoutInterval = [timeout intValue];
    [self resetIdleTimer];
}

/*
    重置用户长时间无操作监听的定时器
 */
-(void)resetIdleTimer
{
    [self->idleTimer invalidate];
    if (timeoutInterval <= 0 ) {
        return;
    }

   self->idleTimer  = [NSTimer scheduledTimerWithTimeInterval:timeoutInterval target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:YES];

}

/*
    用户长时间无操作监听的定时器超时处理函数
 */
-(void)idleTimerExceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:XUIAPPLICATION_TIMEOUT_NOTIFICATION object:nil];
}

- (void)appWillEnterForeground:(NSNotification*)notification
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - lastActiveTime > timeoutInterval) {
        [self idleTimerExceeded];
    }
}

- (void)appDidEnterBackground:(NSNotification*)notification
{
    lastActiveTime = [[NSDate date] timeIntervalSince1970];
}
@end
