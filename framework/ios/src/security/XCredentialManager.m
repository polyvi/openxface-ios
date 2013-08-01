
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
//  XCredentialManager.m
//  xFaceLib
//
//

#import "XCredentialManager.h"
#import "Credentials.h"
#import "APDocument.h"
#import "APDocument+XAPDocument.h"
#import "APElement.h"
#import "NSData+Encoding.h"

@implementation Credentials (OverwriteResetCredentials)

//覆盖此方法以解决iOS 7上的bug
- (void)_resetCredentials
{
    OSStatus    err;

    NSArray *items = @[(__bridge id)kSecClassIdentity,
                       (__bridge id)kSecClassCertificate,
                       (__bridge id)kSecClassKey,
                       (__bridge id)kSecClassInternetPassword,
                       (__bridge id)kSecClassGenericPassword];

    for (id item in items) {
        err = SecItemDelete((__bridge CFDictionaryRef)@{((__bridge id)kSecClass) : item});

        assert(err == noErr              //iOS 7之前的系统的返回值
            || err == errSecItemNotFound //iOS 7系统的返回值
               );
    }

}

@end

@implementation XCredentialManager

static BOOL imported = NO;

+ (NSURLCredential*)firstCredential
{
    NSArray *   identities;

    if (imported == NO) {
        [[Credentials sharedCredentials] resetCredentials];
        [self importPKCS12];
        imported = YES;
        [[Credentials sharedCredentials] refresh];
    }

    identities = [Credentials sharedCredentials].identities;
    assert(identities != nil);
    //TODO:如果有多个证书，应该由用户选择
    if(identities.count > 0) {
        SecIdentityRef              identity;
        // If there's only one available identity, that's gotta be the right one.
        identity = (__bridge SecIdentityRef) [identities objectAtIndex:0];
        assert( (identity != NULL) && (CFGetTypeID(identity) == SecIdentityGetTypeID()) );
        return [self getCredentialByIdentity:identity];
    }
    return nil;
}

+ (NSString *)getPasswordFromFile:(NSString *)path
{
    NSData* xmlData = [NSData dataWithContentsOfFile:path];
    NSString* xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    APDocument* doc  = [APDocument documentWithXMLString:xmlStr];
    APElement *rootElem = [doc rootElement];
    APElement *passwordElem = [rootElem firstChildElementNamed:@"password"];
    NSString* password = [passwordElem value];
    return password;
}

+ (void)importPKCS12
{
    NSBundle* main = [NSBundle mainBundle];
    NSString* path = [main pathForResource:@"client" ofType:@"p12" inDirectory:@"assets"];
    NSString* keyPath = [main pathForResource:@"CertificateKey" ofType:@"xml" inDirectory:@"assets"];

    if (path == nil || keyPath == nil) {
        return;
    }

    NSData* fileData = [NSData dataWithContentsOfFile:path];
    NSString *password = [XCredentialManager getPasswordFromFile:keyPath];

    [self importPKCS12With:fileData password:password];

}

+ (CredentialImportStatus)importPKCS12With:(NSData*)data password:(NSString*)pw
{
    OSStatus                err;
    CredentialImportStatus  status;
    CFArrayRef              importedItems;

    status = kCredentialImportStatusFailed;
    if ([data length] == 0) {
        return status;
    }

    importedItems = NULL;

    err = SecPKCS12Import(
                          (__bridge CFDataRef) data,
                          (__bridge CFDictionaryRef) @{(__bridge id )kSecImportExportPassphrase : pw},
                          &importedItems
                          );
    if (err == noErr) {
        // +++ If there are multiple identities in the PKCS#12, and adding a non-first
        // one fails, we end up with partial results.  Right now that's not an issue
        // in practice, but I might want to revisit this.

        for (NSDictionary * itemDict in (__bridge id) importedItems) {
            SecIdentityRef  identity;

            assert([itemDict isKindOfClass:[NSDictionary class]]);

            identity = (__bridge SecIdentityRef) [itemDict objectForKey:(__bridge NSString *) kSecImportItemIdentity];
            assert(identity != NULL);
            assert( CFGetTypeID(identity) == SecIdentityGetTypeID() );

            err = SecItemAdd(
                             (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
                                                         (__bridge id) identity,              kSecValueRef,
                                                         nil
                                                         ],
                             NULL
                             );
            if (err == errSecDuplicateItem) {
                err = noErr;
            }
            if (err != noErr) {
                break;
            }
        }
        if (err == noErr) {
            status = kCredentialImportStatusSucceeded;
        }
    } else if (err == errSecAuthFailed) {
        status = kCredentialImportStatusCancelled;
    }

    if (importedItems != NULL) {
        CFRelease(importedItems);
    }
    return status;
}

#pragma mark - Private API

// 根据证书标识获取证书
+ (NSURLCredential*)getCredentialByIdentity:(SecIdentityRef)identity
{
    // identity may be NULL
    NSURLCredential *           credential;

    // If we got an identity, create a credential for that identity.

    credential = nil;
    if (identity != NULL) {
        NSURLCredentialPersistence  persistence;
        persistence = [[NSUserDefaults standardUserDefaults] integerForKey:@"CredentialPersistence"];
        if (persistence > NSURLCredentialPersistencePermanent) {
            persistence = NSURLCredentialPersistenceNone;
        }
        assert(persistence <= NSURLCredentialPersistencePermanent);

        credential = [NSURLCredential credentialWithIdentity:identity certificates:nil persistence:persistence];
        assert(credential != nil);
    }
    return credential;
}

@end
