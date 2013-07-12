
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
//  NSData+Encoding.m
//  xFaceLib
//
//

#import "NSData+Encoding.h"
#import "XBase64Data.h"
#import "XHexData.h"

@implementation NSData (Encoding)

+ (NSData*) dataWithString:(NSString*)string usingEncoding:(XDataEncoding)encoding
{
    switch (encoding)
    {
        case XDataBase64Encoding:
            return [NSData dataFromBase64String:string];
        case XDataHexEncoding:
            return [NSData dataWithHexString:string];
        default:
            return [string dataUsingEncoding:NSUTF8StringEncoding];
    }
}

- (NSString*) stringUsingEncoding:(XDataEncoding)encoding
{
    switch (encoding)
    {
        case XDataBase64Encoding:
            return [self base64EncodedString];
        case XDataHexEncoding:
            return [self hexString];
        default:
            return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    }
}

@end
