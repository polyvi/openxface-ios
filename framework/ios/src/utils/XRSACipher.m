
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
//  XRSACipher.m
//  xFaceLib
//
//

#import "XRSACipher.h"
#import "XSecKeyWrapper.h"
#import "XBase64Data.h"

@implementation XRSACipher

-(NSData*) cryptData:(NSData*)sourceData withOperation:(CCOperation)op
{
    //iOS只支持rsa公钥加密，不支持rsa私钥解密，因为私钥无法单独添加。
    if (op == kCCDecrypt) {
        XLogE(@"Error: rsa decrypt is not supported");
        return nil;
    }
    return [XSecKeyWrapper encrypt:sourceData publicKey:self.key];
}

@end
