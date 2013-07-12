
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
//  XAppUpdaterApplicationTests.m
//  xFace
//
//

#import "XAppUpdater.h"
#import "XAppUpdater_Privates.h"
#import "XConstants.h"
#import "XApplicationTests.h"
#import "XUtils.h"

@interface XAppUpdaterApplicationTests : XApplicationTests
{
@private
    XAppUpdater *appUpdater;
}

@end

@implementation XAppUpdaterApplicationTests

- (void) setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    self->appUpdater = [[XAppUpdater alloc] init];

    STAssertNotNil(self->appUpdater, @"Failed to create appUpdater extension instance");
}

- (void) tearDown
{
    NSLog(@"%@ tearDown", self.name);
    [super tearDown];
}

- (void)testRun
{
    [appUpdater run];

    STAssertNoThrow([appUpdater run], nil);
}

- (void) testCheckNewVersion
{
    BOOL willCheckUpdate = [[XUtils getPreferenceForKey:CHECK_UPDATE_PROP_NAME] boolValue];
    if (NO == willCheckUpdate)
    {
        return;
    }

    NSString* serverAddress = [XUtils getPreferenceForKey:UPDATE_ADDRESS_PROP_NAME];
    NSString *currentVersionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:BUNDLE_VERSION_KEY];

    STAssertNoThrow([appUpdater checkNewVersionWith:serverAddress  currentVersionCode:currentVersionCode], nil);
}

@end
