
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
//  XSecKeyWrapper.m
//  xFaceLib
//
//

#import "XSecKeyWrapper.h"
#import <Security/Security.h>
#import "XBase64Data.h"

#define MAX_BLOCK_SIZE 100

#if DEBUG
#define LOGGING_FACILITY(X, Y)    \
NSAssert(X, Y);

#define LOGGING_FACILITY1(X, Y, Z)    \
NSAssert1(X, Y, Z);
#else
#define LOGGING_FACILITY(X, Y)    \
if (!(X)) {            \
    XLogE(Y);        \
}

#define LOGGING_FACILITY1(X, Y, Z)    \
if (!(X)) {                \
    XLogE(Y, Z);        \
}
#endif

@implementation XSecKeyWrapper
+ (OSStatus)rsaVerifyWithSignature:(NSData*)sig withDigist:(NSData *)dig
{

    NSString* p_keyPath = [[NSBundle mainBundle] pathForResource: @"server_pkey" ofType : @""];
    NSData* certificateData = [NSData dataWithContentsOfFile:(p_keyPath)];

    NSString *keyName = @"server_pkey";

    NSData *serverPublicKey = [self stripPublicKeyHeader:certificateData];

    NSLog(@"serverPublicKey:%@", serverPublicKey);

    SecKeyRef key = [self addPublicKey:keyName keyBits:serverPublicKey];
    const uint8_t *digData = (const uint8_t*)[dig bytes];
    size_t digLen = [dig length];
    const uint8_t *sigData = (const uint8_t*)[sig bytes];
    size_t sigLen = [sig length];

    OSStatus status = SecKeyRawVerify(key,
                                      kSecPaddingPKCS1SHA1,
                                      digData,
                                      digLen,
                                      sigData,
                                      sigLen);
    if (status == errSecSuccess) {
        NSLog(@"Valid Signature");
    } else {
        NSLog(@"Invalid Signature");
    }

    return status;

}


+ (SecKeyRef)addPublicKey:(NSString*)keyName keyString:(NSString*)keyString
{
    NSData* publicKey = [XSecKeyWrapper stripPublicKeyHeader:[NSData dataFromBase64String:keyString]];

    return [XSecKeyWrapper addPublicKey:keyName keyBits:publicKey];

}

+ (NSData *)stripPublicKeyHeader:(NSData *)keyData
{
    // Skip ASN.1 public key header
    if (0 == [keyData length]) {
        return nil;
    }

    unsigned char *keyBytes = (unsigned char *)[keyData bytes];
    unsigned int  index    = 0;

    if (keyBytes[index++] != 0x30) return nil;

    if (keyBytes[index] > 0x80) index += keyBytes[index] - 0x80 + 1;
    else index++;

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&keyBytes[index], seqiod, 15)) return nil;

    index += 15;

    if (keyBytes[index++] != 0x03) return nil;

    if (keyBytes[index] > 0x80) index += keyBytes[index] - 0x80 + 1;
    else index++;

    if (keyBytes[index++] != '\0') return nil;

    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&keyBytes[index] length:[keyData length] - index]);
}

+ (SecKeyRef)addPublicKey:(NSString *)keyName keyBits:(NSData *)publicKey
{
    OSStatus sanityCheck = noErr;
    SecKeyRef peerKeyRef = NULL;
    CFTypeRef persistPeer = NULL;
    NSAssert( keyName != nil, @"Key name parameter is nil." );
    NSAssert( publicKey != nil, @"Public key parameter is nil." );

    NSData * keyTag = [[NSData alloc] initWithBytes:(const void *)[keyName UTF8String] length:[keyName length]];
    NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];

    [peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerPublicKeyAttr setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [peerPublicKeyAttr setObject:publicKey forKey:(__bridge id)kSecValueData];
    [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];

    sanityCheck = SecItemAdd((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&persistPeer);

    LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecDuplicateItem, @"Problem adding the app public key to the keychain, OSStatus == %ld.", sanityCheck );

    if (persistPeer) {
        peerKeyRef = [XSecKeyWrapper getKeyRefWithPersistentKeyRef:persistPeer];
    } else {
        [peerPublicKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
        [peerPublicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
        // Let's retry a different way.
        sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);
    }

    LOGGING_FACILITY1( sanityCheck == noErr && peerKeyRef != NULL, @"Problem acquiring reference to the public key, OSStatus == %ld.", sanityCheck );

    if (persistPeer) CFRelease(persistPeer);
    return peerKeyRef;
}

+ (SecKeyRef)getKeyRefWithPersistentKeyRef:(CFTypeRef)persistentRef
{
    OSStatus sanityCheck = noErr;
    SecKeyRef keyRef = NULL;

    LOGGING_FACILITY(persistentRef != NULL, @"persistentRef object cannot be NULL." );

    NSMutableDictionary * queryKey = [[NSMutableDictionary alloc] init];

    // Set the SecKeyRef query dictionary.
    [queryKey setObject:(__bridge id)persistentRef forKey:(__bridge id)kSecValuePersistentRef];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];

    // Get the persistent key reference.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&keyRef);

    return keyRef;
}

+ (BOOL)verifyAppConfigAtPath:(NSString*)path withKey:(NSString*)key
{
    NSString * keyName = path;
    BOOL verified = NO;
    SecKeyRef publicKeyRef = NULL;

    NSString* xmlPath = path;
    NSString* appDir = [path stringByDeletingLastPathComponent];
    NSString* signaturePath = [appDir stringByAppendingPathComponent:@"appd"];

    NSData * plainText = [NSData dataWithContentsOfFile:xmlPath];
    NSData* signature = [NSData dataWithContentsOfFile:signaturePath];
    if (nil == plainText || nil == signature ) {
        return NO;
    }

    publicKeyRef = [XSecKeyWrapper addPublicKey:keyName keyString:key];
    if (NULL == publicKeyRef) {
        return NO;
    }

    // Verify the signature.
    verified = [XSecKeyWrapper verifySignature:plainText
                                    secKeyRef:publicKeyRef
                                    signature:signature];

    // Clean up by removing the public key.
    [XSecKeyWrapper removePublicKey:keyName];

    return verified;
}

+ (BOOL)verifySignature:(NSData *)plainText secKeyRef:(SecKeyRef)publicKey signature:(NSData *)sig
{
    size_t signedHashBytesSize = 0;
    OSStatus sanityCheck = noErr;

    // Get the size of the assymetric block.
    signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    sanityCheck = SecKeyRawVerify(    publicKey,
                                  kTypeOfSigPadding,
                                  (const uint8_t *)[[XSecKeyWrapper getHashBytes:plainText] bytes],
                                  kChosenDigestLength,
                                  (const uint8_t *)[sig bytes],
                                  signedHashBytesSize
                                  );

    return (sanityCheck == noErr) ? YES : NO;
}

+ (NSData*)encrypt:(NSData*)plainText publicKey:(NSData*)key
{
    NSString* keyName = @"RSACipherPublicKey";
    OSStatus sanityCheck = noErr;
    SecKeyRef publicKeyRef = NULL;
    NSMutableData* cipherData = [NSMutableData data];

    publicKeyRef = [XSecKeyWrapper addPublicKey:keyName keyBits:[XSecKeyWrapper stripPublicKeyHeader:key]];
    if (NULL == publicKeyRef) {
        return nil;
    }

    size_t cipherLen = SecKeyGetBlockSize(publicKeyRef);
    void *blockBuf = malloc(sizeof(uint8_t) * MAX_BLOCK_SIZE);
    void *cipherTextBuf = malloc(sizeof(uint8_t) * cipherLen);
    int plainTextLen = [plainText length];

    for (int i = 0 ; i < plainTextLen; i += MAX_BLOCK_SIZE) {
        int blockSize = MIN(MAX_BLOCK_SIZE, plainTextLen - i);
        memset(blockBuf, 0, MAX_BLOCK_SIZE);
        memset(cipherTextBuf, 0, cipherLen);
        [plainText getBytes:blockBuf range:NSMakeRange(i, blockSize)];
        sanityCheck = SecKeyEncrypt(publicKeyRef,
                                    kSecPaddingNone,
                                    blockBuf,
                                    blockSize,
                                    cipherTextBuf,
                                    &cipherLen);

        if(sanityCheck == noErr) {
            [cipherData appendBytes:cipherTextBuf length:cipherLen];
        } else {
            cipherData = nil;
            break;
        }
    }

    free(blockBuf);
    free(cipherTextBuf);
    CFRelease(publicKeyRef);
    [XSecKeyWrapper removePublicKey:keyName];

    return cipherData;
}

+ (NSData *)getHashBytes:(NSData *)plainText
{
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;

    // Malloc a buffer to hold hash.
    hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, kChosenDigestLength);

    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);

    // Build up the SHA1 hash.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];

    if (hashBytes) free(hashBytes);

    return hash;
}

+ (void)removePublicKey:(NSString *)keyName
{
    OSStatus sanityCheck = noErr;

    NSAssert( keyName != nil, @"Peer name parameter is nil." );

    NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[keyName UTF8String] length:[keyName length]];
    NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];

    [peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [peerPublicKeyAttr setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];

    sanityCheck = SecItemDelete((__bridge CFDictionaryRef) peerPublicKeyAttr);

    LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Problem deleting the peer public key to the keychain, OSStatus == %ld.", sanityCheck );

}

@end
