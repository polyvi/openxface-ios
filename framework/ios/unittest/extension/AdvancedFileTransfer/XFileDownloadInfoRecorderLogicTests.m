
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
//  XFileDownloadInfoRecorderLogicTests.m
//  xFaceLib
//
//


#import <SenTestingKit/SenTestingKit.h>
#import "XFileDownloadInfoRecorder.h"
#import "XJavaScriptEvaluator.h"
#import "XAppInfo.h"
#import "XApplication.h"
#import "XFileDownloadInfo.h"
#import "XApplicationFactory.h"

#define XAPPLICATION_LOGIC_TESTS_APP_ID                @"appId"

@interface XFileDownloadInfoRecorderLogicTests : SenTestCase
{
@private
    XFileDownloadInfoRecorder *downloadInfoRecorder;
    NSString                  *url;
}
@end

@implementation XFileDownloadInfoRecorderLogicTests

- (void)setUp
{
    [super setUp];
    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XAPPLICATION_LOGIC_TESTS_APP_ID];
    downloadInfoRecorder = [[XFileDownloadInfoRecorder alloc] initWithApp:app];
    url = @"http://www.baidu.com";
    STAssertNotNil(downloadInfoRecorder, @"Failed to create rootViewController instance");
}

- (void) testHasInfo
{
    BOOL hasInfo = [downloadInfoRecorder hasInfo:url];
    STAssertFalse(hasInfo, nil);
}

- (void) testSaveDownloadInfo
{
    NSInteger totalSize = 10000;
    NSInteger completeSize = 1000;
    XFileDownloadInfo *downloadInfo = [[XFileDownloadInfo alloc] initWithURL:url andTotalSize:totalSize andCompleteSize:completeSize];
    [downloadInfoRecorder saveDownloadInfo:downloadInfo];
    BOOL hasInfo = [downloadInfoRecorder hasInfo:url];
    STAssertTrue(hasInfo, nil);
    NSString *sceUrl = @"http://www.google.com.hk/";
    downloadInfo = [[XFileDownloadInfo alloc] initWithURL:sceUrl andTotalSize:totalSize andCompleteSize:completeSize];
    [downloadInfoRecorder saveDownloadInfo:downloadInfo];
    hasInfo = [downloadInfoRecorder hasInfo:sceUrl];
    STAssertTrue(hasInfo, nil);

    [downloadInfoRecorder deleteDownloadInfo:url];
    [downloadInfoRecorder deleteDownloadInfo:sceUrl];
}

- (void) testGetDownloadInfo
{
    NSInteger totalSize = 10000;
    NSInteger completeSize = 1000;
    XFileDownloadInfo *downloadInfo = [[XFileDownloadInfo alloc] initWithURL:url andTotalSize:totalSize andCompleteSize:completeSize];
    [downloadInfoRecorder saveDownloadInfo:downloadInfo];
    BOOL hasInfo = [downloadInfoRecorder hasInfo:url];
    STAssertTrue(hasInfo, nil);
    downloadInfo = [downloadInfoRecorder getDownloadInfo:url];
    STAssertEquals(totalSize, [downloadInfo totalSize], nil);
    STAssertEquals(completeSize, [downloadInfo completeSize], nil);
    [downloadInfoRecorder deleteDownloadInfo:url];
}

- (void) testUpdateDownloadInfo
{
    NSInteger totalSize = 10000;
    NSInteger completeSize = 1000;
    XFileDownloadInfo *downloadInfo = [[XFileDownloadInfo alloc] initWithURL:url andTotalSize:totalSize andCompleteSize:completeSize];
    [downloadInfoRecorder saveDownloadInfo:downloadInfo];
    BOOL hasInfo = [downloadInfoRecorder hasInfo:url];
    STAssertTrue(hasInfo, nil);
    downloadInfo = [downloadInfoRecorder getDownloadInfo:url];
    STAssertEquals(totalSize, [downloadInfo totalSize], nil);
    STAssertEquals(completeSize, [downloadInfo completeSize], nil);

    completeSize = 2000;
    [downloadInfoRecorder updateDownloadInfo:completeSize withUrl:url];
    downloadInfo = [downloadInfoRecorder getDownloadInfo:url];
    STAssertEquals(totalSize, [downloadInfo totalSize], nil);
    STAssertEquals(completeSize, [downloadInfo completeSize], nil);

    [downloadInfoRecorder deleteDownloadInfo:url];
}

- (void) testDeleteDownloadInfo
{
    NSInteger totalSize = 10000;
    NSInteger completeSize = 1000;
    XFileDownloadInfo *downloadInfo = [[XFileDownloadInfo alloc] initWithURL:url andTotalSize:totalSize andCompleteSize:completeSize];
    [downloadInfoRecorder saveDownloadInfo:downloadInfo];
    BOOL hasInfo = [downloadInfoRecorder hasInfo:url];
    STAssertTrue(hasInfo, nil);
    [downloadInfoRecorder deleteDownloadInfo:url];
    hasInfo = [downloadInfoRecorder hasInfo:url];
    STAssertFalse(hasInfo, nil);
}

@end
