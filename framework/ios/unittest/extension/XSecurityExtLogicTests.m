
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
//  XSecurityExtLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XJavaScriptEvaluator.h"
#import "XApplication.h"
#import "XBase64Data.h"
#import "XSecurityExt.h"
#import "XSecurityExt_Privates.h"
#import "XJsCallback.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XCipher.h"

@interface XSecurityExt (TEST)

-(id)getCiphers;

@end

@implementation XSecurityExt (TEST)

-(id)getCiphers
{
    return self->ciphers;
}

@end

@interface XSecurityExtLogicTests : SenTestCase
{
    XSecurityExt *securityExt;
}

@end

@implementation XSecurityExtLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->securityExt = [[XSecurityExt alloc] initWithMsgHandler:[[XJavaScriptEvaluator alloc] init]];

    STAssertNotNil(self->securityExt, @"Failed to create security extension instance");
}

- (void) testInitWithMsgHandler
{
    XJavaScriptEvaluator *msgHandler = [[XJavaScriptEvaluator alloc] init];
    XSecurityExt *security = [[XSecurityExt alloc] initWithMsgHandler:msgHandler];
    STAssertNotNil(security, nil);
}

- (void) testEncryptThrows
{
    NSString* keyString     = @"67845";
    NSString* plainText     = @"";

    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    [arguments addObject:keyString];
    [arguments addObject:plainText];
    [arguments addObject:[NSNull null]];

    NSString *callbackId = @"Security0";
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self->securityExt class]) withMethod:@"encrypt"];
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    nil, APPLICATION_KEY, nil];
    // 测试前检查
    STAssertThrows([callback genCallbackScript], nil);

    // 执行测试
    STAssertThrows([self->securityExt encrypt:arguments withDict:options], nil);
}

- (void) testEncrypt
{
    NSString* keyString     = @"6789012345";
    NSString* plainText     = @"Test Security";

    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    [arguments addObject:keyString];
    [arguments addObject:plainText];
    [arguments addObject:[NSNull null]];

    NSString *callbackId = @"Security0";
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self->securityExt class]) withMethod:@"encrypt"];
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    nil, APPLICATION_KEY, nil];
    // 测试前检查
    STAssertThrows([callback genCallbackScript], nil);

    // 执行测试
    STAssertNoThrow([self->securityExt encrypt:arguments withDict:options], nil);

    // 测试后检查
    NSString *result = nil;
    STAssertNoThrow((result = [callback genCallbackScript]), nil);
    STAssertEqualObjects(@"xFace.require('xFace/exec').nativeCallback('Security0',2,\"KxwSbPgHo3be2x8WGXCU4A==\",0)", result, @"Failed encrypt!");
}

- (void) testDecrypt
{
    NSString* keyString     = @"6789012345";
    NSString* encryptedText = @"KxwSbPgHo3be2x8WGXCU4A==";

    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:3];
    [arguments addObject:keyString];
    [arguments addObject:encryptedText];
    [arguments addObject:[NSNull null]];

    NSString *callbackId = @"Security0";
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self->securityExt class]) withMethod:@"decrypt"];
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    nil, APPLICATION_KEY, nil];
    // 测试前检查
    STAssertThrows([callback genCallbackScript], nil);

    // 执行测试
    STAssertNoThrow([self->securityExt decrypt:arguments withDict:options], nil);

    // 测试后检查
    NSString *result = nil;
    STAssertNoThrow((result = [callback genCallbackScript]), nil);
    STAssertEqualObjects(@"xFace.require('xFace/exec').nativeCallback('Security0',2,\"Test Security\",0)", result, @"Failed encrypt!");
}

- (void) testDecryptThrows
{
    NSString* keyString     = @"";
    NSString* encryptedText = @"KxwSbPgHo3be2x8WGXCU4A==";

    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:2];
    [arguments addObject:keyString];
    [arguments addObject:encryptedText];
    [arguments addObject:[NSNull null]];

    NSString *callbackId = @"Security0";
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:NSStringFromClass([self->securityExt class]) withMethod:@"decrypt"];
    XJsCallback *callback = [[XJsCallback alloc] initWithCallbackId:callbackId withCallbackKey:callbackKey];

    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:callback, JS_CALLBACK_KEY,
                                    nil, APPLICATION_KEY, nil];
    // 执行测试
    STAssertThrows([self->securityExt decrypt:arguments withDict:options], nil);
}

-(void) testGetCipher
{
    NSDictionary* ciphers = [securityExt getCiphers];

    XCipher* cipher = [ciphers cipherForKey:kKeyForDES];
    STAssertTrue([cipher algorithm] == kCCAlgorithmDES,nil);

    cipher =[ciphers cipherForKey:kKeyFor3DES];
    STAssertTrue([cipher algorithm] == kCCAlgorithm3DES,nil);

    cipher = [ciphers cipherForKey:@"unkown"];
    STAssertTrue([cipher algorithm] == kCCAlgorithmDES,nil);
}

@end
