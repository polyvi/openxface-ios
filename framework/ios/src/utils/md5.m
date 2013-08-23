
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
//  md5.m
//  xFaceLib
//
//

#import "md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5Extensions)

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithMd5:result];
}

+ (NSString *) stringWithMd5:(unsigned char*)md5
{
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            md5[0], md5[1], md5[2], md5[3],
            md5[4], md5[5], md5[6], md5[7],
            md5[8], md5[9], md5[10], md5[11],
            md5[12], md5[13], md5[14], md5[15]
            ];
}

@end

@implementation NSData (md5Extensions)

- (NSString*)md5
{
    unsigned char result[16];
    CC_MD5( self.bytes, self.length, result );
    return [NSString stringWithMd5:result];
}

@end
