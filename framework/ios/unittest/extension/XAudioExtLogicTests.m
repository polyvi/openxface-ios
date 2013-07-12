
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
//  XAudioExtLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XAudioExt.h"
#import "XAudioExt_Privates.h"
#import "XAppInfo.h"
#import "XApplication.h"
#import "XApplicationFactory.h"

#define XAPPLICATION_LOGIC_TESTS_APP_ID                @"appId"

@interface XAudioExtLogicTests : SenTestCase
{
@private
    XAudioExt *audioExt;
    id<XApplication> testapp;
}
@end

@implementation XAudioExtLogicTests

- (void)setUp
{
    [super setUp];
    self->audioExt = [[XAudioExt alloc] init];
    STAssertNotNil(self->audioExt, @"Failed to create device extension instance");

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    self->testapp = [XApplicationFactory create:appInfo];
    [[self->testapp appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
}

- (void) testUrlForResource
{
    NSURL* testResult = nil;
    NSString* resourcePath = nil;
    NSString* workSpace = [self->testapp getWorkspace];
    BOOL isRecord = NO;

    //网络资源
    resourcePath = @"http://audio.ibeat.org/content/p1rj1s/p1rj1s_-_rockGuitar.mp3";
    testResult = [self->audioExt urlForResource:resourcePath withPath:workSpace isRecord:isRecord];
    STAssertNotNil(testResult, nil);

    //file://资源 对应资源不存在testResult 应该为nil
    resourcePath = @"file://test/resourcenotexist/test.mp3";
    testResult = [self->audioExt urlForResource:resourcePath withPath:workSpace isRecord:isRecord];
    STAssertNil(testResult, nil);

    //本地资源 对应资源不存在testResult 应该为nil
    resourcePath = @"test.mp3";
    testResult = [self->audioExt urlForResource:resourcePath withPath:workSpace isRecord:isRecord];
    STAssertNil(testResult, nil);

    isRecord = YES;
    //本地资源 录音模型 允许资源路径代表的文件不存在
    testResult = [self->audioExt urlForResource:resourcePath withPath:workSpace isRecord:isRecord];
    STAssertNotNil(testResult, nil);
}

- (void) testAudioFileForResource
{
    XAudioFile* testResult = nil;
    NSString* resourcePath = nil;
    NSString* mediaId = nil;
    NSString* workSpace = [self->testapp getWorkspace];
    BOOL isRecord = NO;

    //网络资源
    resourcePath = @"http://audio.ibeat.org/content/p1rj1s/p1rj1s_-_rockGuitar.mp3";
    mediaId = @"testid";
    testResult = [self->audioExt audioFileForResource:resourcePath withId:mediaId withPath:workSpace isRecord:isRecord];
    STAssertNotNil(testResult, nil);

    //file://资源 对应资源不存在, testResult 应该为nil
    resourcePath = @"file://test/resourcenotexist/test.mp3";
    mediaId = @"testid1";
    testResult = [self->audioExt audioFileForResource:resourcePath withId:mediaId withPath:workSpace isRecord:isRecord];
    STAssertNil(testResult, nil);

    //本地资源 对应资源不存在, testResult 应该为nil
    resourcePath = @"test.mp3";
    mediaId = @"testid2";
    testResult = [self->audioExt audioFileForResource:resourcePath withId:mediaId withPath:workSpace isRecord:isRecord];
    STAssertNil(testResult, nil);

    isRecord = YES;
    //本地资源 录音模型 允许资源路径代表的文件不存在 成功创建XAudioFile对象
    mediaId = @"testid3";
    testResult = [self->audioExt audioFileForResource:resourcePath withId:mediaId withPath:workSpace isRecord:isRecord];
    STAssertNotNil(testResult, nil);
}

@end
