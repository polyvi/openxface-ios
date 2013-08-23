
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
//  XUPPSecurityLogicTests.m
//  xFaceNSCBLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "RSAEncrypt.h"
#import "XConfiguration.h"
#import "XAppInfo.h"
#import "XApplicationFactory.h"
#import "XApplication.h"
#import "XUPPSecurityExt.h"
#import "XLogicTests.h"

@interface XUPPSecurityExt (test)
- (NSString *)getResMd5:(id)app;
@end

@interface XUPPSecurityLogicExtTests : XLogicTests

@end

@implementation XUPPSecurityLogicExtTests

-(void)testEncrypt
{
    NSString* publicKeyModulus = @"99569353584256793477342745310338678668314634051511874034736251415135625647741852843064472969835137636827236235622517954414978966142617412972216796668645034891724973340552719244779730752003196621833311369084871220930542051828326500483339060180456840906093649776847783423254615942934207027904373763132971228011";
    NSString* publicKeyExmod = @"65537";
    NSString* plainText = @"0123567987dshkjdsl一二三!@#$%^&*()_+{}[]";
    NSString* expectedOutStr = @"2D6C6A28EA5CB71E6C85AC400355EEAC5569C68D21AD06007A21B14E60093993506665BC8EBE998E3D1F7E83EEE91887EFADB8B95D25CCDC13656C6F82715B9315987743DADD9CA902BEA2E826C56A9705E9A859FF4D75798B209C377F698058897849870E358B98ABA0387878DA67A71DE3D3F865783B622904340C045D18F9";
    RSAEncrypt *tempRSAEncrypt = [[RSAEncrypt alloc] initWithMod:publicKeyModulus exmod:publicKeyExmod];
    NSString *outStr = [tempRSAEncrypt RSAPublicEncryptString:plainText length:[plainText length]];
    STAssertTrue([expectedOutStr isEqualToString:outStr], nil);
}

-(void)testGetClientChecksum
{
    XAppInfo *appInfo = [[XAppInfo alloc] init];
    [appInfo setAppId:@"app"];

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:@"www/xface/apps/app" ofType:nil];
    NSLog(@"%@", path);

    [appInfo setSrcRoot:path];
    id<XApplication> app = [XApplicationFactory create:appInfo];

    XUPPSecurityExt* security = [[XUPPSecurityExt alloc] init];

    NSString* expectedMd5 = @"b17ccbf3221c8bedfdfb95ed5a33b974";
    NSString* md5 = [security getResMd5:app];

    STAssertTrue([expectedMd5 isEqualToString:md5], nil);
    NSLog(@"%@", md5);
}

@end
