
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
//  XFileDownloadInfoLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XFileDownloadInfo.h"

@interface XFileDownloadInfoLogicTests : SenTestCase

@end

@implementation XFileDownloadInfoLogicTests

- (void) testInitWithURL
{
    NSString *url = @"http://www.baidu.com";
    NSInteger totalSize = 10000;
    NSInteger completeSize = 1000;
    XFileDownloadInfo *downloadInfo = [[XFileDownloadInfo alloc] initWithURL:url andTotalSize:totalSize andCompleteSize:completeSize];
    STAssertNotNil(downloadInfo, nil);
    STAssertEquals(url, [downloadInfo url], nil);
    STAssertEquals(totalSize, [downloadInfo totalSize], nil);
    STAssertEquals(completeSize, [downloadInfo completeSize], nil);
}

@end
