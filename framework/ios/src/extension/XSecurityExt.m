
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
//  XSecurityExt.m
//  xFaceLib
//
//

#ifdef __XSecurityExt__

#include <CommonCrypto/CommonCryptor.h>
#import "XSecurityExt.h"
#import "XSecurityExt_Privates.h"
#import "XBase64Data.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XJsCallback.h"
#import "XApplication.h"
#import "XUtils.h"
#import "XCipher.h"
#import "XRSACipher.h"
#import "XQueuedMutableArray.h"
#import "NSData+Encoding.h"
#import "md5.h"

const NSDictionary* defaultJsOptions;

@implementation NSDictionary (XCiphers)

- (XCipher*) cipherForKey:(id)key
{
    XCipher* cipher = [self objectForKey:key];
    return cipher == nil ? [self objectForKey:kKeyForDES] : cipher;
}

@end

@implementation XSecurityExt

- (id) initWithMsgHandler:(XJavaScriptEvaluator *)msgHandler
{
    defaultJsOptions = @{kKeyForALG : kKeyForDES,
                         kKeyForEncodeDataType : @(XDataBase64Encoding),
                         kKeyForEncodeKeyType : @(XDataUTF8Encoding)};

    self = [super initWithMsgHandler:msgHandler];
    if (self)
    {
        XCipher* cipher1 = [[XCipher alloc] initWithAlgorithm:kCCAlgorithmDES]; //使用DES对称加密算法
        XCipher* cipher2 = [[XCipher alloc] initWithAlgorithm:kCCAlgorithm3DES]; //使用3DES对称加密算法
        XCipher* cipher3 = [[XRSACipher alloc] init]; //使用3DES对称加密算法

        ciphers = @{kKeyForDES:cipher1, kKeyFor3DES:cipher2, kKeyForRSA:cipher3};
    }
    return self;
}

- (void) encrypt:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString* keyString = [arguments objectAtIndex:0];
    NSString* sourceDataStr = [arguments objectAtIndex:1];
    NSDictionary* jsOptions = [arguments objectAtIndex:2 withDefault:defaultJsOptions];

    NSNumber* alg = [jsOptions objectForKey:kKeyForALG];
    NSNumber* dataEncoding = [jsOptions objectForKey:kKeyForEncodeDataType];
    NSNumber* keyEncoding = [jsOptions objectForKey:kKeyForEncodeKeyType];

    XCipher* cipher = [ciphers cipherForKey:alg];

    XExtensionResult* result    = nil;
    NSData* sourceData          = nil;//原数据
    NSData* resultData          = nil;//加密后的数据

    NSAssert((([keyString length] >= SECURITY_KEY_MIN_LENGTH) && [sourceDataStr length]), @"Input data invalid!");

    sourceData = [sourceDataStr dataUsingEncoding:NSUTF8StringEncoding];

    NSData* keyData = [NSData dataWithString:keyString usingEncoding:[keyEncoding unsignedIntValue]];

    [cipher setKey:keyData];
    resultData = [cipher encryptData:sourceData];

    if(resultData != nil)
    {
        result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: [resultData stringUsingEncoding:[dataEncoding unsignedIntValue]]];
    }
    else
    {
        XLogE(@"Encrypt failed！");
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: @"Encrypt failed！"];
    }
    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) decrypt:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString* keyString = [arguments objectAtIndex:0];
    NSString* sourceDataStr = [arguments objectAtIndex:1];
    NSDictionary* jsOptions = [arguments objectAtIndex:2 withDefault:defaultJsOptions];

    NSNumber* alg = [jsOptions objectForKey:kKeyForALG];
    NSNumber* dataEncoding = [jsOptions objectForKey:kKeyForEncodeDataType];
    NSNumber* keyEncoding = [jsOptions objectForKey:kKeyForEncodeKeyType];

    XCipher* cipher = [ciphers cipherForKey:alg];

    XExtensionResult* result    = nil;
    NSData* sourceData          = nil;//原数据
    NSData* resultData          = nil;//解密后的数据

    NSAssert((([keyString length] >= SECURITY_KEY_MIN_LENGTH) && [sourceDataStr length]), @"Input data invalid!");

    sourceData = [NSData dataWithString:sourceDataStr usingEncoding:[dataEncoding unsignedIntValue]];

    NSData* keyData = [NSData dataWithString:keyString usingEncoding:[keyEncoding unsignedIntValue]];
    [cipher setKey:keyData];
    resultData = [cipher decryptData:sourceData];

    if(resultData != nil)//return string
    {
        NSString* resultstr = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject: resultstr];
    }
    else
    {
        XLogE(@"Dencrypt failed！");
        result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsObject: @"Dencrypt failed！"];
    }
    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (void) encryptFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self doFileCrypt:arguments withDict:options useOperation:kCCEncrypt];
}

- (void) decryptFile:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    [self doFileCrypt:arguments withDict:options useOperation:kCCDecrypt];
}

- (void) doFileCrypt:(NSMutableArray*)arguments withDict:(NSMutableDictionary *)options useOperation:(CCOperation)op
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString* keyString = [arguments objectAtIndex:0];
    NSString* sourceFilePath = [arguments objectAtIndex:1];
    NSString* targetFilePath = [arguments objectAtIndex:2];
    NSDictionary* jsOptions = [arguments objectAtIndex:3 withDefault:defaultJsOptions];

    NSNumber* alg = [jsOptions objectForKey:kKeyForALG];

    XCipher* cipher = [ciphers cipherForKey:alg];

    id<XApplication> app = [self getApplication:options];
    if( ![self checkArguments:arguments withDict:options] )
    {
        [self sendErrorMessage:PATH_ERR byCalllBack:callback];
        return;
    }
    sourceFilePath = [XUtils resolvePath:sourceFilePath usingWorkspace:[app getWorkspace]];
    targetFilePath = [XUtils resolvePath:targetFilePath usingWorkspace:[app getWorkspace]];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if(![fileMgr fileExistsAtPath:sourceFilePath])
    {
        //sourceFile不存在
        [self sendErrorMessage:FILE_NOT_FOUND_ERR byCalllBack:callback];
        return;
    }
    NSData* sourceData          = nil;//原数据
    NSData* resultData          = nil;//解密后的数据
    sourceData = [[NSData alloc] initWithContentsOfFile:sourceFilePath];

    [cipher setKey:[keyString dataUsingEncoding:NSUTF8StringEncoding]];

    resultData = [cipher cryptData:sourceData withOperation:op];
    if(resultData != nil)
    {
        if([fileMgr createFileAtPath:targetFilePath contents:resultData attributes:nil])
        {
            XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject:targetFilePath];
            [callback setExtensionResult:result];
            [self sendAsyncResult:callback];
            return;
        }
    }
    [self sendErrorMessage:OPERATION_ERR byCalllBack:callback];
}

- (void) digest:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback *callback = [self getJsCallback:options];
    NSString* data = [arguments objectAtIndex:0];
    NSString* md5 = [data md5];
    XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject:md5];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (BOOL) checkArguments:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
    NSString* keyString = [arguments objectAtIndex:0];
    NSAssert(([keyString length] >= SECURITY_KEY_MIN_LENGTH), @"Input key invalid!");

    NSString* sourceFilePath = [arguments objectAtIndex:1];
    NSString* targetFilePath = [arguments objectAtIndex:2];
    id<XApplication> app = [self getApplication:options];
    //不能是空串
    if(0 == [sourceFilePath length] || 0 == [targetFilePath length])
    {
        return NO;
    }
    //都是相对workspace的相对路径，不能是 形如C:/a/bc 这种
    if( (NSNotFound !=[sourceFilePath rangeOfString:@":"].location) || (NSNotFound !=[targetFilePath rangeOfString:@":"].location) )
    {
        return NO;
    }
    sourceFilePath = [XUtils resolvePath:sourceFilePath usingWorkspace:[app getWorkspace]];
    targetFilePath = [XUtils resolvePath:targetFilePath usingWorkspace:[app getWorkspace]];
    if (!sourceFilePath || !targetFilePath)
    {
        //不在workspace下
        return NO;
    }
    return YES;
}

-(void) sendErrorMessage:(int)errorMessage byCalllBack:(XJsCallback *)callback
{
    XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsInt:errorMessage];
    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

- (BOOL) shouldExecuteInBackground:(NSString *)fullMethodName
{
    return YES;
}

@end

#endif
