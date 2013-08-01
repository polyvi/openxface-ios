//
//  XCredentialManagerLogicTests.m
//  xFaceLib
//
//  Created by huanghf on 13-7-16.
//  Copyright (c) 2013年 Polyvi Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "XCredentialManager.h"

@interface XCredentialManagerLogicTests : SenTestCase

@end

@implementation XCredentialManagerLogicTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testGetPasswordFromFile
{
    NSString* expectedPassword = @"password";
    NSBundle* main = [NSBundle bundleForClass:[self class]];
    NSString* keyPath = [main pathForResource:@"CertificateKey" ofType:@"xml" inDirectory:@"assets"];;
    NSString* password = [XCredentialManager getPasswordFromFile:keyPath];
    STAssertTrue([password isEqualToString:expectedPassword], nil);
}

@end
