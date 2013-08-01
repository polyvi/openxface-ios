
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
//  XCredentialManager.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kCredentialImportStatusCancelled,
    kCredentialImportStatusFailed,
    kCredentialImportStatusSucceeded
} CredentialImportStatus;

/**
    该类主要用于管理证书，包括导入和获取证书等。
 */
@interface XCredentialManager : NSObject

/**
    获取第一个证书
 */
+ (NSURLCredential*)firstCredential;

/**
    导入客户端证书
 */
+ (void)importPKCS12;

/**
    导入客户端证书
    @param data 证书数据
    @param pw   证书密码
    @returns 证书导入的状态
 */
+ (CredentialImportStatus)importPKCS12With:(NSData*)data password:(NSString*)pw
;

+ (NSString *)getPasswordFromFile:(NSString *)path;

@end
