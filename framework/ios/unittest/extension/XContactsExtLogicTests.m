
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
//  XContactsExtLogicTests.m
//  xFaceLib
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XContactsExt.h"
#import "XContactsExt_Privates.h"
#import "XContact.h"

@interface XAddressBookHelperLogicTests : SenTestCase

@end

@implementation XAddressBookHelperLogicTests

-(void) testCreateAddressBook
{
    XAddressBookAccessError* addressBookAccessError = nil;
    ABAddressBookRef addrBook = [XAddressBookHelper createAddressBook: &addressBookAccessError];

    //6.0的系统
    if (&ABAddressBookCreateWithOptions != NULL)
    {
        if(!addressBookAccessError)
        {
            //成功创建addrBook
            STAssertTrue(addrBook != NULL, nil);
        }
        else
        {
            //创建addrBook 失败
            STAssertTrue(addrBook == NULL, nil);
        }
    }
    else
    {
        //6.0 以前的 成功创建addrBook
        STAssertTrue(addrBook != NULL, nil);
    }
}

@end

@interface XContactsExtLogicTests : SenTestCase

@end

@implementation XContactsExtLogicTests

@end
