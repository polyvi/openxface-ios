
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
//  XFileTransferExtApplicationTests.m
//  xFace
//
//

#import "XApplicationTests.h"
#import "XApplication.h"
#import "XRootViewController.h"
#import "XRuntime.h"
#import "XRuntime_Privates.h"
#import "XJsCallback.h"
#import "XFileTransferExt.h"
#import "XFileTransferExt_Privates.h"
#import "XConstants.h"
#import "XApplication.h"

// 使用块流传输时的缓冲区大小 32K
#define KSTREAMBUFFERSIZE   32768

@interface XFileTransferExtApplicationTests : XApplicationTests
{
    @private
    XFileTransferExt* fileTransferExt;
    NSMutableArray* downloadArguments;
    NSMutableArray* uploadArguments;
    NSMutableDictionary* downloadOptions;
    NSMutableDictionary* uploadOptions;
    NSData* fileData;
}
@end

@implementation XFileTransferExtApplicationTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%@ setUp", self.name);
    fileTransferExt = [[XFileTransferExt alloc] initWithMsgHandler:[[self app] jsEvaluator]];
    STAssertNotNil(fileTransferExt, @"Failed to create FileTransfer extension instance");

    //fileTransfer 扩展下载文件接口的arguments
    downloadArguments = [[NSMutableArray alloc] initWithCapacity:4];
    NSString *callbackId = @"FileTransfer0";
    XJsCallback *downLoadCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"download"];
    [downloadArguments addObject:@"http://www.baidu.com"];//downloadserverURL
    [downloadArguments addObject:@"FileTransfer/test.html"];//filePath
    [downloadArguments addObject:@"true"];//trustAllHosts
    [downloadArguments addObject:@"id1"];//id
    downloadOptions = [[NSMutableDictionary alloc] init];
    [downloadOptions setObject:downLoadCallback forKey:JS_CALLBACK_KEY];
    [downloadOptions setObject:[self app] forKey:APPLICATION_KEY];

    //fileTransfer 扩展文件上传接口的arguments
    uploadArguments = [[NSMutableArray alloc] initWithCapacity:9];
    XJsCallback *upLoadCallback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:@"upload"];
    [uploadArguments addObject:@"test.png"];//uploadsource1
    [uploadArguments addObject:@"http://apollo.polyvi.com/index.php"];//server2
    [uploadArguments addObject:@"file"];//filekey3
    [uploadArguments addObject:@"test.png"];//filename4
    [uploadArguments addObject:@"image/png"];//mimetype5
    [uploadArguments addObject:[[NSMutableDictionary alloc] init]];
    [uploadArguments addObject:[NSNumber numberWithBool:NO]];//trustEveryone6
    [uploadArguments addObject:[NSNumber numberWithBool:NO]];//chunkedMode7
    [uploadArguments addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"key1", @"val2", @"key2", nil]];//headers8
    [uploadArguments addObject:@"id2"];
    uploadOptions = [[NSMutableDictionary alloc] init];
    [uploadOptions setObject:upLoadCallback forKey:JS_CALLBACK_KEY];//callback0
    [uploadOptions setObject:[self app] forKey:APPLICATION_KEY];//app8
}

- (void)tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}

- (void) testWriteDataToStream
{
    NSData* testData = [[uploadArguments objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreateBoundPair(NULL, &readStream, &writeStream, KSTREAMBUFFERSIZE);
    if (CFWriteStreamOpen(writeStream))
    {
        //使用块流传输时将给定的数据写入到stream中
        CFIndex result =[fileTransferExt writeDataToStream:testData stream:writeStream];
        //成功返回写入数据的字节数
        STAssertTrue(result > 0, nil);
    }
    CFWriteStreamClose(writeStream);
    CFRelease(writeStream);
}

- (void) testHandleHeaders
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    STAssertNoThrow([fileTransferExt handleHeaders:request withDict:nil], nil);
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"key1",
                             @"val2", @"key2", nil];
    STAssertNoThrow([fileTransferExt handleHeaders:request withDict:headers],nil);
    // Check that headers are properly set.
    STAssertTrue([@"val1" isEqualToString:[request valueForHTTPHeaderField:@"key1"]], nil);
    STAssertTrue([@"val2" isEqualToString:[request valueForHTTPHeaderField:@"key2"]], nil);

}

- (void) testCreateHeadersForUploadingFile
{
    NSData* testData = [[uploadArguments objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: @"val3", @"key3", nil];
    NSMutableDictionary *originalParams = [uploadArguments objectAtIndex:5];
    [originalParams removeAllObjects];
    [originalParams setDictionary:params];
    // with options
    STAssertNoThrow([fileTransferExt createHeadersForUploadingFile:uploadArguments withDict:uploadOptions fileData:testData], nil);
    // no options
    STAssertNoThrow([fileTransferExt createHeadersForUploadingFile:uploadArguments withDict:uploadOptions fileData:testData], nil);
}

- (void) testRequestForUpload
{
    NSData* testData = [[uploadArguments objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];

    // with options
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"val1", @"key1",
                             @"val2", @"key2", nil];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"cookieval", @"__cookie",
                             headers, @"headers", @"val3", @"key3", nil];
    NSMutableDictionary *originalParams = [uploadArguments objectAtIndex:5];
    [originalParams removeAllObjects];
    [originalParams setDictionary:params];
    NSURLRequest* request = [fileTransferExt requestForUpload:uploadArguments withDict:uploadOptions fileData:testData];
    NSString* payload = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    // Check that headers are properly set.
    STAssertTrue([@"val1" isEqualToString:[request valueForHTTPHeaderField:@"key1"]], nil);
    STAssertTrue([@"val2" isEqualToString:[request valueForHTTPHeaderField:@"key2"]], nil);
    // Check that key3 is in the payload.
    STAssertTrue([payload rangeOfString:@"key3"].length > 0, nil);
    STAssertTrue([payload rangeOfString:@"val3"].length > 0, nil);

    //chunkedMode
    // iOS < 5 不支持chunkedMode
    if (SYSTEM_VERSION_NOT_LOWER_THAN(@"5"))
    {
        [uploadArguments replaceObjectAtIndex:7 withObject:[NSNumber numberWithBool:YES]];
        STAssertNoThrow([fileTransferExt requestForUpload:uploadArguments withDict:uploadOptions fileData:testData], nil);
    }

    // error server url request must nil
    [uploadArguments replaceObjectAtIndex:1 withObject:@"*&&^ahg"];
    STAssertNil([fileTransferExt requestForUpload:uploadArguments withDict:uploadOptions fileData:testData], nil);

}

- (void) testFileDataForUploadArguments
{
    STAssertNoThrow(fileData = [fileTransferExt fileDataForUploadArguments:uploadArguments withDict:uploadOptions], nil);
}

- (void) testCreateFileTransferError
{
    int code = 3;
    NSString* source = @"fileTransfer/test.html";
    NSString* target = @"http://apollo.polyvi.com/index.php";
    int httpStatus = 691;
    NSMutableDictionary* result = [fileTransferExt createFileTransferError:code andSource:source andTarget:target andHttpStatus:httpStatus];
    STAssertNotNil(result,nil);
}


- (void) testDownload
{
    STAssertNoThrow([fileTransferExt download:downloadArguments withDict:downloadOptions], nil);
}

- (void) testUpload
{
    STAssertNoThrow([fileTransferExt upload:uploadArguments withDict:uploadOptions], nil);
}

- (void) testUploadWithMalformedUrl
{
    NSMutableArray* args = [[NSMutableArray alloc] initWithArray:uploadArguments];
    [args replaceObjectAtIndex:2 withObject:@"httpssss://exa mple.com"];

    STAssertNoThrow([fileTransferExt upload:args withDict:uploadOptions], nil);
}

@end
