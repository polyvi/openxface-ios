
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
//  XContactsExt.m
//  xFace
//
//

#ifdef __XContactsExt__

#import "XContactsExt.h"
#import "XContactsExt_Privates.h"
#import "XContact.h"
#import "XExtensionResult.h"
#import "XJavaScriptEvaluator.h"
#import "XExtendedDictionary.h"
#import "XJsCallback.h"
#import "XQueuedMutableArray.h"

@implementation XContactsPicker

@synthesize allowsEditing;
@synthesize jsCallback;
@synthesize options;
@synthesize pickedContactDictionary;

@end

@implementation XNewContactsController

@synthesize jsCallback;

@end

@implementation XContactsExt

- (void) save:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSMutableDictionary* contactDict = [arguments objectAtIndex:0];

    XAddressBookHelper* abHelper = [[XAddressBookHelper alloc] init];
    [abHelper createAddressBook: ^(ABAddressBookRef addrBook, XAddressBookAccessError * addressBookAccessError) {
        BOOL isError = NO;
        bool success = FALSE;
        BOOL update = NO;
        XContactError errCode = UNKNOWN_ERROR;
        CFErrorRef error;
        XExtensionResult* result = nil;

        if (addressBookAccessError)
        {
            [self handleCreatingAddressBookFailure:addressBookAccessError.errorCode with:callback];
            return;
        }

        NSNumber* contactId = [contactDict valueForKey:@"id"];
        XContact* contactWorker = nil;
        ABRecordRef record = nil;
        if (contactId && ![contactId isKindOfClass:[NSNull class]])
        {
            record = ABAddressBookGetPersonWithRecordID(addrBook, [contactId intValue]);
            if (record)
            {
                contactWorker = [[XContact alloc] initFromABRecord: record];
                update = YES;
            }
        }
        if (!contactWorker)
        {
            contactWorker = [[XContact alloc] init];
        }

        success = [contactWorker setABRecordFromContactDict: contactDict asUpdate: update];
        if (success)
        {
            if (!update)
            {
                success = ABAddressBookAddRecord(addrBook, [contactWorker record], &error);
            }
            if (success)
            {
                success = ABAddressBookSave(addrBook, &error);
            }
            if (!success)
            {
                isError = YES;
                errCode = IO_ERROR;
            }
            else
            {
                NSDictionary* newContact = [contactWorker toDictionary: [XContact defaultFields]];
                result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:newContact];
            }
        }
        else
        {
            isError = YES;
            errCode = IO_ERROR;
        }
        if (addrBook)
        {
            CFRelease(addrBook);
        }

        if (isError)
        {
            result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt: errCode];
        }

        [callback setExtensionResult:result];
        [self sendAsyncResult:callback];
    }];
}

- (void) remove: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSNumber* contactId = [arguments objectAtIndex:0];

    XAddressBookHelper* abHelper = [[XAddressBookHelper alloc] init];
    [abHelper createAddressBook: ^(ABAddressBookRef addrBook, XAddressBookAccessError * addressBookAccessError) {
        bool isError = FALSE;
        bool success = FALSE;
        XContactError errCode = UNKNOWN_ERROR;
        CFErrorRef error;
        ABRecordRef record = nil;
        XExtensionResult* result = nil;

        if (addressBookAccessError)
        {
            [self handleCreatingAddressBookFailure:addressBookAccessError.errorCode with:callback];
            return;
        }
        if (contactId && ![contactId isKindOfClass:[NSNull class]] && kABRecordInvalidID != [contactId intValue])
        {
            record = ABAddressBookGetPersonWithRecordID(addrBook, [contactId intValue]);
            if (record)
            {
                success = ABAddressBookRemoveRecord(addrBook, record, &error);
                if (!success)
                {
                    isError = TRUE;
                    errCode = IO_ERROR;
                }
                else
                {
                    success = ABAddressBookSave(addrBook, &error);
                    if(!success)
                    {
                        isError = TRUE;
                        errCode = IO_ERROR;
                    }
                    else
                    {
                        result = [XExtensionResult resultWithStatus:STATUS_OK];
                    }
                }
            }
            else
            {
                isError = TRUE;
                errCode = UNKNOWN_ERROR;
            }
        }
        else
        {
            isError = TRUE;
            errCode = INVALID_ARGUMENT_ERROR;
        }

        if (addrBook)
        {
            CFRelease(addrBook);
        }
        if (isError)
        {
            result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt: errCode];
        }
        [callback setExtensionResult:result];
        [self sendAsyncResult:callback];
    }];
}

- (void) search:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSArray* fields = [arguments objectAtIndex:0];
    NSDictionary* findOptions = [arguments objectAtIndex:1 withDefault:[NSNull null]];

    XAddressBookHelper* abHelper = [[XAddressBookHelper alloc] init];
    [abHelper createAddressBook: ^(ABAddressBookRef addrBook, XAddressBookAccessError * addressBookAccessError) {
        NSArray* foundRecords = nil;
        XExtensionResult* result = nil;

        if (addressBookAccessError)
        {
            [self handleCreatingAddressBookFailure:addressBookAccessError.errorCode with:callback];
            return;
        }

        // 获取findOptions的值
        BOOL multiple = NO; // 默认为false
        NSString* filter = nil;
        if (![findOptions isKindOfClass:[NSNull class]])
        {
            id value = nil;
            filter = (NSString*)[findOptions objectForKey:@"filter"];
            value = [findOptions objectForKey:@"multiple"];
            if ([value isKindOfClass:[NSNumber class]])
            {
                multiple = [(NSNumber*)value boolValue];
            }
        }

        NSDictionary* returnFields = [XContact calcReturnFields: fields];

        NSMutableArray* matches = nil;
        if (0 == [filter length])
        {
            // 获取所有的纪录
            foundRecords = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addrBook);
            if ([foundRecords count] > 0)
            {
                int foundCount = multiple == YES ? [foundRecords count] : 1;
                matches = [NSMutableArray arrayWithCapacity:foundCount];
                for(int index = 0; index < foundCount; index++)
                {
                    XContact* foundContact = [[XContact alloc] initFromABRecord:(__bridge ABRecordRef)[foundRecords objectAtIndex:index]];
                    [matches addObject:foundContact];
                }
            }
        }
        else
        {
            foundRecords = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addrBook);
            matches = [NSMutableArray arrayWithCapacity:1];
            BOOL isFound = NO;
            int foundCount = [foundRecords count];
            for(int index = 0; index < foundCount; index++)
            {
                XContact* findContact = [[XContact alloc] initFromABRecord: (__bridge ABRecordRef)[foundRecords objectAtIndex:index]];
                if (findContact)
                {
                    isFound = [findContact findValue:filter inFields:returnFields];
                    if(isFound)
                    {
                        [matches addObject:findContact];
                    }
                }
            }
        }

        NSMutableArray* returnContacts = [NSMutableArray arrayWithCapacity:1];

        if ([matches count] > 0)
        {
            int count = multiple == YES ? [matches count] : 1;
            for(int index = 0; index < count; index++)
            {
                XContact* newContact = [matches objectAtIndex:index];
                NSDictionary* aContact = [newContact toDictionary: returnFields];
                [returnContacts addObject:aContact];
            }
        }
        //array is empty if no contacts found
        result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:returnContacts];

        if(addrBook)
        {
            CFRelease(addrBook);
        }

        [callback setExtensionResult:result];
        [self sendAsyncResult:callback];
    }];
}

- (void) newPersonViewController:(ABNewPersonViewController*)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    ABRecordID recordId = kABRecordInvalidID;
    XNewContactsController* newContactCtl = (XNewContactsController*) newPersonViewController;
    XJsCallback* callback = newContactCtl.jsCallback;

    if (person)
    {
        //返回联系人id
        recordId = ABRecordGetRecordID(person);
    }

    [[newPersonViewController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsInt:recordId];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];
}

- (BOOL) personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return YES;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    XContactsPicker* picker = (XContactsPicker*)peoplePicker;
    NSNumber* pickedId = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
    if (picker.allowsEditing)
    {
        ABPersonViewController* personController = [[ABPersonViewController alloc] init];
        personController.displayedPerson = person;
        personController.personViewDelegate = self;
        personController.allowsEditing = picker.allowsEditing;
        // store id so can get info in peoplePickerNavigationControllerDidCancel
        picker.pickedContactDictionary = [NSDictionary dictionaryWithObjectsAndKeys:pickedId, kW3ContactId, nil];

        [peoplePicker pushViewController:personController animated:YES];
    }
    else
    {
        // 返回联系人对象
        XContact* pickedContact = [[XContact alloc] initFromABRecord:(ABRecordRef)person];
        NSArray* fields = [picker.options objectForKey:@"fields"];
        fields = fields == nil ? @[@"*"] : fields;
        NSDictionary* returnFields = [[XContact class] calcReturnFields:fields];
        picker.pickedContactDictionary = [pickedContact toDictionary:returnFields];

        XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_OK messageAsObject:picker.pickedContactDictionary];
        XJsCallback *callback = picker.jsCallback;
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];

        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    return NO;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    XContactsPicker* picker = (XContactsPicker*)peoplePicker;

    if (picker.allowsEditing) {
        // get the info after possible edit
        // if we got this far, user has already approved/ disapproved addressBook access
        ABAddressBookRef addrBook = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
        if (&ABAddressBookCreateWithOptions != NULL) {
            addrBook = ABAddressBookCreateWithOptions(NULL, NULL);
        } else
#endif
        {
            // iOS 4 & 5
            addrBook = ABAddressBookCreate();
        }
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addrBook, [[picker.pickedContactDictionary objectForKey:kW3ContactId] integerValue]);
        if (person) {
            XContact* pickedContact = [[XContact alloc] initFromABRecord:(ABRecordRef)person];
            NSArray* fields = [picker.options objectForKey:@"fields"];
            fields = fields == nil ? @[@"*"] : fields;
            NSDictionary* returnFields = [[XContact class] calcReturnFields:fields];
            picker.pickedContactDictionary = [pickedContact toDictionary:returnFields];
        }
        CFRelease(addrBook);
    }
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_OK messageAsObject:picker.pickedContactDictionary];
    XJsCallback *callback = [picker jsCallback];
    [callback setExtensionResult:result];
    [self->jsEvaluator eval:callback];

    [[peoplePicker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) newContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    XNewContactsController* newContactController = [[XNewContactsController alloc] init];

    XAddressBookAccessError* addressBookAccessError = nil;
    ABAddressBookRef addrBook = [XAddressBookHelper createAddressBook: &addressBookAccessError];
    if (addressBookAccessError)
    {
        [self handleCreatingAddressBookFailure:addressBookAccessError.errorCode with:callback];
        return;
    }
    newContactController.addressBook = addrBook;
    CFRelease(addrBook);

    newContactController.newPersonViewDelegate = self;
    newContactController.jsCallback = callback;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newContactController];

    [self.viewController presentViewController:navController animated:YES completion:nil];
}

- (void) displayContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    ABRecordID recordID = kABRecordInvalidID;
    XJsCallback* callback = [self getJsCallback:options];
    recordID = [[arguments objectAtIndex:0] intValue];
    NSDictionary *jsOptions = [arguments objectAtIndex:1 withDefault:[NSNull null]];

    BOOL allowEdit = [jsOptions isKindOfClass:[NSNull class]] ? NO : [jsOptions valueForKeyEquals:@"true" forKey:@"allowsEditing"];
    //FIXME: 操作读取联系人信息并在UI界面上显示 不能在ABAddressBookRequestAccessWithCompletion的handler 异步回调代码块里面处理。必须在主线程处理。故此处使用直接创建ABAddressBookRef
    XAddressBookAccessError* addressBookAccessError = nil;
    ABAddressBookRef addrBook = [XAddressBookHelper createAddressBook: &addressBookAccessError];
    if (addressBookAccessError)
    {
        [self handleCreatingAddressBookFailure:addressBookAccessError.errorCode with:callback];
        return;
    }
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(addrBook, recordID);
    if (record)
    {
        XDisplayContactViewController* personController = [[XDisplayContactViewController alloc] init];
        personController.displayedPerson = record;
        personController.personViewDelegate = self;
        personController.allowsEditing = NO;

        // 创建parentController使DisplayContactViewController有 "back" 键.
        UIViewController* parentController = [[UIViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:parentController];

        [navController pushViewController:personController animated:YES];

        [self.viewController presentViewController:navController animated:YES completion:nil];

        if (allowEdit)
        {
            // 创建editing controller
            ABPersonViewController* editPersonController = [[ABPersonViewController alloc] init];
            editPersonController.displayedPerson = record;
            editPersonController.personViewDelegate = self;
            editPersonController.allowsEditing = YES;
            [navController pushViewController:editPersonController animated:YES];
        }
    }
	else
	{
        // 没有指定的record, 返回 UNKNOWN_ERROR
        XExtensionResult* result = [XExtensionResult resultWithStatus: STATUS_ERROR messageAsInt:  UNKNOWN_ERROR];
        [callback setExtensionResult:result];
        [self->jsEvaluator eval:callback];
	}
    if (addrBook)
    {
        CFRelease(addrBook);
    }
}

- (void) chooseContact:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    XJsCallback* callback = [self getJsCallback:options];
    NSDictionary *jsOptions = [arguments objectAtIndex:0 withDefault:nil];

    XContactsPicker* pickerController = [[XContactsPicker alloc] init];
    pickerController.peoplePickerDelegate = self;
    pickerController.jsCallback = callback;
    pickerController.options = jsOptions;
    pickerController.pickedContactDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kABRecordInvalidID], kW3ContactId, nil];
    pickerController.allowsEditing = [jsOptions valueForKeyEquals:@"true" forKey:@"allowsEditing"];

    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

- (void) handleCreatingAddressBookFailure:(int)errorCode with:(XJsCallback*)callback
{
    XExtensionResult* result = [XExtensionResult resultWithStatus:STATUS_ERROR messageAsInt: errorCode];
    [callback setExtensionResult:result];
    [self sendAsyncResult:callback];
}

@end

@implementation XDisplayContactViewController

- (void)viewWillDisappear: (BOOL)animated
{
    [super viewWillDisappear: animated];

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation XAddressBookAccessError

@synthesize errorCode;

- (XAddressBookAccessError*)initWithCode:(XContactError)code
{
    self = [super init];
    if (self) {
        self.errorCode = code;
    }
    return self;
}

@end

@implementation XAddressBookHelper

+ (ABAddressBookRef)createAddressBook:(XAddressBookAccessError**) error
{
    // iOS 6.0 createAddressBook 使用 ABAddressBookCreateWithOptions 函数
    if (&ABAddressBookCreateWithOptions != NULL)
    {
        CFErrorRef err = nil;
        CFIndex status = ABAddressBookGetAuthorizationStatus();
        XLogI(@"addressBook access: %lu", status);

        if ( kABAuthorizationStatusAuthorized == ABAddressBookGetAuthorizationStatus() )
        {
            ABAddressBookRef  addressBook = ABAddressBookCreateWithOptions(NULL, &err);
            if (err)//有错误的情况,ABAddressBookCreateWithOptions 返回NULL
            {
                *error = [[XAddressBookAccessError alloc] initWithCode:UNKNOWN_ERROR];
                XLogE(@" createAddressBook occur error: %@ !!!!!!", err);
            }
            return addressBook;
        }
        else
        {
            *error = [[XAddressBookAccessError alloc] initWithCode:PERMISSION_DENIED_ERROR];
            XLogE(@" permission denied error : addressBook access: not permissions !!!");
            return NULL;
        }
    }
    else
    {
        *error = nil;
        // iOS 4 or 5 no checks needed  Deprecated in iOS 6.0.
        return ABAddressBookCreate ();
    }
}

- (void)createAddressBook:(XAddressBookWorkerBlock)workerBlock
{
    // !! caller is responsible for releasing AddressBook!!
    ABAddressBookRef addressBook;
    if (&ABAddressBookCreateWithOptions != NULL)
    {
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (error)
                {
                    XLogE(@" createAddressBook occur error: %@ !!!!!!", error);
                    workerBlock (NULL, [[XAddressBookAccessError alloc] initWithCode:UNKNOWN_ERROR]);
                }
                else if (!granted)
                {
                    XLogE(@" permission denied error : addressBook access: not permissions !!!");
                    workerBlock (NULL, [[XAddressBookAccessError alloc] initWithCode:PERMISSION_DENIED_ERROR]);
                }
                else
                {
                    //获得授权
                    workerBlock (addressBook, NULL);
                }
        });
    }
    else
    {
        // iOS 4 or 5 no checks needed
        addressBook = ABAddressBookCreate ();
        workerBlock (addressBook, NULL);
    }
}

@end
#endif
