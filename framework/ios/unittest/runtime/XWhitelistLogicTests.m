
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XWhitelistLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XWhitelist.h"
#import "XWhitelist_Privates.h"

@interface XWhitelistLogicTests : SenTestCase

@end

@implementation XWhitelistLogicTests

- (void)setUp
{
    [super setUp];

    // setup code here
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testAllowedSchemes
{
    STAssertTrue([XWhitelist isSchemeAllowed:@"http"], nil);
    STAssertTrue([XWhitelist isSchemeAllowed:@"https"], nil);
    STAssertTrue([XWhitelist isSchemeAllowed:@"ftp"], nil);
    STAssertTrue([XWhitelist isSchemeAllowed:@"ftps"], nil);
    STAssertFalse([XWhitelist isSchemeAllowed:@"gopher"], nil);
}

- (void)testSubdomainWildcard
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"*.wikipedia.org",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://en.wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://sub1.sub0.en.wikipedia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org.ca"]], nil);
}

- (void)testWildcardInTLD
{
    // NOTE: if the user chooses to do this (a wildcard in the TLD, not a wildcard as the TLD), we allow it because we assume they know what they are doing! We don't replace it with known TLDs
    // This might be applicable for custom TLDs on a local network DNS

    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"wikipedia.o*g",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.ogg"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.foo"]], nil);
}

- (void)testTLDWildcard
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"wikipedia.*",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    NSString* hostname = @"wikipedia";

    NSArray* knownTLDs = [NSArray arrayWithObjects:
                          @"aero", @"asia", @"arpa", @"biz", @"cat",
                          @"com", @"coop", @"edu", @"gov", @"info",
                          @"int", @"jobs", @"mil", @"mobi", @"museum",
                          @"name", @"net", @"org", @"pro", @"tel",
                          @"travel", @"xxx",
                          nil];

    // 26*26 combos
    NSMutableArray* twoCharCountryCodes = [NSMutableArray arrayWithCapacity:(26 * 26)];

    for (char c0 = 'a'; c0 <= 'z'; ++c0)
    {
        for (char c1 = 'a'; c1 <= 'z'; ++c1)
        {
            [twoCharCountryCodes addObject:[NSString stringWithFormat:@"%c%c", c0, c1]];
        }
    }

    NSMutableArray* shouldPass = [NSMutableArray arrayWithCapacity:[knownTLDs count] + [twoCharCountryCodes count]];

    NSEnumerator* knownTLDEnumerator = [knownTLDs objectEnumerator];
    NSString* tld = nil;

    while (tld = [knownTLDEnumerator nextObject])
    {
        [shouldPass addObject:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.%@", hostname, tld]]];
    }

    NSEnumerator* twoCharCountryCodesEnumerator = [twoCharCountryCodes objectEnumerator];
    NSString* cc = nil;

    while (cc = [twoCharCountryCodesEnumerator nextObject])
    {
        [shouldPass addObject:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.%@", hostname, cc]]];
    }

    NSEnumerator* shouldPassEnumerator = [shouldPass objectEnumerator];
    NSURL* url = nil;

    while (url = [shouldPassEnumerator nextObject])
    {
        STAssertTrue([whitelist isUrlAllowed:url], @"Url tested :%@", [url description]);
    }

    STAssertFalse(([whitelist isUrlAllowed:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.%@", hostname, @"faketld"]]]), nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://unknownhostname.faketld"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://unknownhostname.com"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.wikipedia.org"]], nil);
}

- (void)testCatchallWildcardOnly
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"*",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://build.wikipedia.prg"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://MyDangerousSite.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org.SuspiciousSite.com"]], nil);
}

- (void)testWildcardInHostname
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"www.*wikipe*dia.org",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.wikipeMAdia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.MACwikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.MACwikipeMAdia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
}

- (void)testExactMatch
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"www.wikipedia.org",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.wikipedia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://en.wikipedia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.en.wikipedia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
}

- (void)testNoMatchInQueryParam
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"www.wikipedia.org",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"www.malicious-site.org?url=http://www.wikipedia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"www.malicious-site.org?url=www.wikipedia.org"]], nil);
}

- (void)testWildcardMix
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"*.wikipe*dia.*",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://www.wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipeMAdia.ca"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipeMAdia.museum"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://blahMAdia.museum"]], nil);
}

- (void)testIpExactMatch
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"192.168.1.1",
                             @"192.168.2.1",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.1.1"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.2.1"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.3.1"]], nil);
}

- (void)testIpWildcardMatch
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"192.168.1.*",
                             @"192.168.2.*",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.1.1"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.1.2"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.2.1"]], nil);
    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.2.2"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://192.168.3.1"]], nil);
}

- (void)testHostnameExtraction
{
    NSArray* allowedHosts = [NSArray arrayWithObjects:
                             @"http://wikipedia.org/",
                             @"http://wikipedia.org/foo/bar?x=y",
                             @"ftp://wikipedia.org/foo/bar?x=y",
                             @"ftps://wikipedia.org/foo/bar?x=y",
                             @"http://wikipedia.*/foo/bar?x=y",
                             nil];

    XWhitelist* whitelist = [[XWhitelist alloc] initWithArray:allowedHosts];

    STAssertTrue([whitelist isUrlAllowed:[NSURL URLWithString:@"http://wikipedia.org"]], nil);
    STAssertFalse([whitelist isUrlAllowed:[NSURL URLWithString:@"http://google.com"]], nil);
}

- (void)testWhitelistRejectionString
{
    NSURL* testUrl = [NSURL URLWithString:@"http://www/google.com"];
    NSString* errorString = [XWhitelist errorStringForUrl:testUrl];
    NSString* expectedErrorString = [NSString stringWithFormat:XDefaultWhitelistRejectionString, [testUrl absoluteString]];

    STAssertTrue([expectedErrorString isEqualToString:errorString], @"Default error string has an unexpected value.");
}

@end

