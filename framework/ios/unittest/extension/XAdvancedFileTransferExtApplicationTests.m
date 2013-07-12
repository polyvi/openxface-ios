
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
//  XAdvancedFileTransferExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XApplication.h"
#import "XRootViewController.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XAdvancedFileTransferExt.h"
#import "XJsCallback+ExtensionResult.h"
#import "XExtensionResult.h"
#import "XConstants.h"

@interface XAdvancedFileTransferExtApplicationTests : XApplicationTests
{
    @private
    XAdvancedFileTransferExt* advancedFileTransferExt;
}
@end

@implementation XAdvancedFileTransferExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    advancedFileTransferExt = [[XAdvancedFileTransferExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(advancedFileTransferExt, @"Failed to create advancedFileTransfer extension instance");
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}

- (void) testDownloadWithDict
{
    NSString *callbackId = @"AdvancedFileTransfer0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"download"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    [arguments addObject:@"http://apollo.polyvi.com/develop/TestFileTransfer/test.exe"];
    [arguments addObject:@"test.exe"];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    STAssertNoThrow([advancedFileTransferExt download:arguments withDict:options], nil);

    //错误参数测试
    [arguments replaceObjectAtIndex:1 withObject:@"file/:aaa"];
    STAssertNoThrow([advancedFileTransferExt download:arguments withDict:options], nil);
    NSNumber* status_error = [[NSNumber alloc] initWithInt:STATUS_ERROR];
    STAssertEqualObjects(status_error, [[callback getXExtensionResult] status], nil);
}

- (void) testPauseWithDict
{
    NSString *callbackId = @"AdvancedFileTransfer0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"pause"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:1];
    [arguments addObject:@"http://apollo.polyvi.com/develop/TestFileTransfer/test.exe"];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    STAssertNoThrow([advancedFileTransferExt pause:arguments withDict:options], nil);
}

- (void) testCancelWithDict
{
    NSString *callbackId = @"AdvancedFileTransfer0";
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"cancel"];
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    [arguments addObject:@"http://apollo.polyvi.com/develop/TestFileTransfer/test.exe"];
    [arguments addObject:@"test.exe"];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    [self app], APPLICATION_KEY, nil];
    STAssertNoThrow([advancedFileTransferExt cancel:arguments withDict:options], nil);
}

@end
