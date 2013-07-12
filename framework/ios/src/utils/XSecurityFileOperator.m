
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
//  XSecurtiyFileOperator.h
//  xFace
//
//

#import "XSecurityFileOperator.h"
#import "XCipher.h"
#import "APDocument+XAPDocument.h"
#import "XUtils.h"
#import "XUtils+Additions.h"
#import "XConfiguration.h"

@implementation XSecurityFileOperator

- (id)init
{
    self = [super init];
    if (self) {
        self->cipher = [[XCipher alloc] initWithAlgorithm:kCCAlgorithmAES128];
        cipher.key = [[XUtils getMacAddress] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (APDocument*)readAsDocFromFile:(NSString *)filePath;
{
    NSData* xmlData = [self->cipher decryptFile:filePath];
    if (nil == xmlData)
    {
        return nil;
    }
    NSString *xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    return [APDocument documentWithXMLString:xmlStr];
}

- (NSData*)readAsDataFromFile:(NSString *)filePath;
{
     return [self->cipher decryptFile:filePath];
}

- (BOOL) saveDoc:(APDocument *)doc toFile:(NSString *)filePath;
{
    NSData *xmlData = [doc prettyXMLData];
    return [self->cipher encryptData:xmlData toFile:filePath];
}

- (BOOL) saveData:(NSData*)data toFile:(NSString *)filePath
{
     return [self->cipher encryptData:data toFile:filePath];
}

- (BOOL) saveString:(NSString*)string toFile:(NSString *)filePath;
{
    NSData *xmlData = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self->cipher encryptData:xmlData toFile:filePath];
}

@end
