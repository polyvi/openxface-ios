
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
//  XAnalyzer.m
//  xFaceLib
//
//

#import "XAnalyzer.h"
#import "GAI.h"
#import "MobClick.h"

// TODO:从配置文件获取，因为不同的项目应有不同的trackingId(appKey)
static NSString *const kGATrackingId = @"UA-41120538-1";
static NSString *const kUMAppKey     = @"519d7d5356240bad2b0028e0";

@implementation XAnalyzer

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initializeGA];
        [self initializeUMA];

        // TODO:监听event实现event,screen统计功能
    }
    return self;
}

#pragma mark Privates

- (void)initializeGA
{
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:kGATrackingId];

    // We can use optOut flag to implement an opt-out setting in the app to allows users to opt out of Google Analytics tracking.
}

- (void)initializeUMA
{
    // 初始化UMAnalytics
    [MobClick setCrashReportEnabled:YES];

    // REALTIME只在模拟器和DEBUG模式下生效，真机release模式会自动改成BATCH
    // BATCH策略说明：应用程序每次只在启动时会向服务器发送一次消息(BATCH策略)，在应用使用过程中产生的所有消息都会在下次启动时候发送。
    // 如果应用程序启动时处在不联网状态，那么消息将会缓存在本地，下次再尝试发送
    [MobClick startWithAppkey:kUMAppKey reportPolicy:(ReportPolicy)REALTIME channelId:nil];
}

@end
