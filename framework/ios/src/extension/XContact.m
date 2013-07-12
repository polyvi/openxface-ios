
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
//  XContact.m
//  xFace
//
//

#ifdef __XContactsExt__

#import "XContact.h"
#import "XExtendedDictionary.h"
#import <AddressBook/ABAddressBook.h>

@interface XContact()

/**
    将本地的AdreessBook(AB)属性转换成W3C标识符
    @return W3C标识符
 */
+(NSDictionary*) defaultABtoW3C;

/**
    将W3C标识符转换成本地的AdreessBook(AB)属性
    @return 本地的AdreessBook(AB)属性
 */
+(NSDictionary*) defaultW3CtoAB;

/**
    处理本地不支持或者还没有实现的W3C联系人属性
    @return
 */
+(NSSet*) defaultW3CtoNull;

/**
    产生W3C联系人对象
    @return 包含了所有W3C形式的联系人对象
 */
+(NSDictionary*) defaultObjectAndProperties;

/**
    将js端的cantact属性转换成本地对应的label
    @param label js端的cantact属性名
    @return 本地对应的label
    phone:  work, home, other, mobile, fax, pager -->
    kABWorkLabel, kABHomeLabel, kABOtherLabel, kABPersonPhoneMobileLabel, kABPersonHomeFAXLabel ||kABPersonHomeFAXLabel, kABPersonPhonePagerLabel
    emails:  work, home, other ---> kABWorkLabel, kABHomeLabel, kABOtherLabel
    ims: aim, gtalk, icq, xmpp, msn, skype, qq, yahoo --> kABPersonInstantMessageService + (AIM, ICG, MSN, Yahoo).不支持gtalk, xmpp, skype, qq
    addresses: work, home, other --> kABWorkLabel, kABHomeLabel, kABOtherLabel
 */
+(CFStringRef) convertContactTypeToPropertyLabel:(NSString*)label;

/**
    将本地的通讯录label转换成js端对应的cantact属性
    @param label 本地的通讯录label
    @return js端对应的cantact属性
 */
+(NSString*) convertPropertyLabelToContactType: (NSString*)label;

/*
    判断W3C属性标签是否需要转换
    kW3ContactFieldType和kW3ContactImType需要转换
 */
+(bool) needConversion: (NSString*)w3cLabel;

/**
    判断输入的标签是不是合法的W3C ContactField类型，用于查找
 */
+(bool) isValidW3CContactType: (NSString*)label;

/**
    从指定数组中产生ABMultiValueRef数据
    @param array 指定数组
    @return ABMultiValueRef数据
 */
-(ABMultiValueRef) allocStringMultiValueFromArray:(NSArray*)array;

/**
    从指定数组中产生ABMultiValueRef数据(用于ims和addresses)
    @param array 指定数组
    @param prop  ABPropertyID
    @return ABMultiValueRef数据
 */
-(ABMultiValueRef) allocDictMultiValueFromArray:(NSArray*) array forProperty: (ABPropertyID) prop;

/**
    将多值string属性设置成一个通讯录记录
    @param fieldArray   包含多值string属性的Array
    @param prop    多值dictionary的属性ID( phones and emails)
    @param person  要设置的对象
    @param update  标识是更新纪录还是创建新的纪录
        YES代表更新，如果是更新:
            array为空表示删除整个属性
            value/label == "" 表示删除整个属性
            value/label == [NSNull null] 表示不做修改
    @return  true表示设置成功,false表示设置失败
 */
-(bool) setMultiValueStrings:(NSArray*)fieldArray forProperty:(ABPropertyID)prop inRecord:(ABRecordRef)person asUpdate:(BOOL)update;

/**
    将多值dictionary属性设置成一个通讯录记录
    @param array   包含多值dictionary属性的Array
    @param prop    多值dictionary的属性ID(addresses 和 ims)
    @param person  要设置的对象
    @param update  标识是更新纪录还是创建新的纪录
        YES代表更新，如果是更新:
            array为空表示删除整个属性
            value/label == "" 表示删除整个属性
            value/label == [NSNull null] 表示不做修改
    @return  true表示设置成功,false表示设置失败
 */
-(bool) setMultiValueDictionary: (NSArray*)array forProperty:(ABPropertyID)prop inRecord:(ABRecordRef)person asUpdate:(BOOL)update;

/**
    设置项目到指定属性的通讯录记录中.
    @param aValue 要设置的项目值
    @param aProperty AddressBook属性ID
    @param aRecord 要更新的纪录
    @param update  标识是更新纪录还是创建新的纪录
    @return  true表示设置成功,false表示设置失败
 */
-(bool) setValue: (id)aValue forProperty: (ABPropertyID) aProperty inRecord: (ABRecordRef) aRecord asUpdate: (BOOL)update;

/**
    W3C联系人支持很多图片，但是现在ios的实现只支持一张
    将图片数据保存在tmp目录下并返回FileURI，tmp会在应用退出时被删除
 */
-(NSObject*) extractPhotos;

/**
    产生字典数组来对应JavaScript层的ContactOrganization对象
 */
-(NSObject*) extractOrganizations;

/**
    产生字典数组来对应JavaScript层的ContactField对象(用于ims)
    ios IMs是多值属性标签，value = dictionary of IM details (service, username), and id
 */
-(NSObject*) extractIms;

/**
    产生字典数组来对应JavaScript层的ContactName对象
 */
-(NSObject*) extractName;

/**
    产生MultiValue对象来匹配JavaScript层的ContactField对象(用于简单的多值属性如phoneNumbers, emails)
    @param propertyId W3C联系人属性名
 */
-(NSObject*) extractMultiValue: (NSString*)propertyId;

/**
    产生字典数组来对应JavaScript层的ContactAddress对象
    ios addresses是多值属性标签，value = dictionary of address info, and id
 */
-(NSObject*) extractAddresses;

/**
    获取时间信息(单位毫秒)
    @param datePropId ios层的联系人属性id
 */
-(NSNumber*)getDateAsNumber: (ABPropertyID) datePropId;

/**
    查找property对应的值是不是等于value(大小写不敏感)
    @param value 要查找的值
    @param property W3C联系人属性在本地中对应的值
    @return 查找到了返回YES,否则返回NO
 */
-(BOOL) findStringValue: (NSString*)value forW3CProperty: (NSString*) property;

/**
    查找property对应的值是不是等于value(大小写不敏感，用于Data类型的数据查找)
    @param value 要查找的值
    @param property W3C联系人属性在本地中对应的值
    @return 查找到了返回YES,否则返回NO
 */
-(BOOL) findDateValue: (NSString*)value forW3CProperty: (NSString*) property;

/**
    在指定的fields中查找propId对应的值是不是等于value(大小写不敏感，用于multivalue string类型的数据查找)
    @param fields 指定的fields
    @param propId 要查找的属性对应的ABPropertyID
    @param value 要查找的值
    @return 查找到了返回YES,否则返回NO
 */
-(BOOL) findContactFields: (NSArray*) fields forMVStringProperty: (ABPropertyID) propId withValue: (NSString*)value;

/**
    在指定的fields中查找propId对应的值是不是等于value(大小写不敏感，用于multivalue Dictionary类型的数据查找)
    @param fields 指定的fields
    @param propId 要查找的属性对应的ABPropertyID
    @param value 要查找的值
    @return 查找到了返回YES,否则返回NO
 */
-(BOOL) findContactFields: (NSArray*) fields forMVDictionaryProperty: (ABPropertyID) propId withValue: (NSString*)value;

/**
    在指定type下查找propId对应的值是不是等于value(大小写不敏感，用于multiString类型的数据查找)
    @param value 要查找的值
    @param propId 要查找的属性对应的ABPropertyID
    @param type 指定type
    @return 查找到了返回YES,否则返回NO
 */
- (BOOL) findMultiValueStrings: (NSString*) value forProperty: (ABPropertyID) propId ofType: (NSString*) type;

/**
    从ABRecordRef中获取指定propId的NSArray类型的数据
    @param propId 要查找的属性对应的ABPropertyID
    @param aRecord ABRecordRef类型
    @return NSArray类型的数据
 */
- (NSArray*) valuesForProperty: (ABPropertyID) propId inRecord: (ABRecordRef) aRecord;

/**
    从ABRecordRef中获取指定propId的NSArray类型的标签
    @param propId 要查找的属性对应的ABPropertyID
    @param aRecord ABRecordRef类型
    @return NSArray类型的数据
 */
- (NSArray*) labelsForProperty: (ABPropertyID) propId inRecord: (ABRecordRef)aRecord;

@end

#define IS_VALID_VALUE(value) ((value != nil) && (![value isKindOfClass: [NSNull class]]))

static NSDictionary*    contactsW3CtoAB = nil;
static NSDictionary*    contactsABtoW3C = nil;
static NSSet*           contactsW3CtoNull = nil;
static NSDictionary*    contactsObjectAndProperties = nil;
static NSDictionary*    contactsDefaultFields = nil;

@implementation XContact

@synthesize returnFields;

- (id) init
{
    self = [super init];
    if (self)
    {
        ABRecordRef rec = ABPersonCreate();
        self.record = rec;
        CFRelease(rec);
    }
    return self;
}

- (id) initFromABRecord:(ABRecordRef)aRecord
{
    self = [super init];
    if (self)
    {
        self.record = aRecord;
    }
    return self;
}

/* synthesize 'record' ourselves to have retain properties for CF types */
- (void) setRecord:(ABRecordRef)aRecord
{
    ABRecordRef rec = nil;
    if (nil != aRecord)
    {
        rec = CFRetain(aRecord);
    }
    if (nil != record)
    {
        CFRelease(record);
    }
    record = rec;
}

- (ABRecordRef) record
{
    return record;
}

- (void) dealloc
{
    if (record)
    {
        CFRelease(record);
    }
}

-(bool) setABRecordFromContactDict:(NSMutableDictionary*) aContact asUpdate:(BOOL) update
{
    if (![aContact isKindOfClass:[NSDictionary class]])
    {
        return FALSE;
    }

    ABRecordRef person = self.record;
    bool success = TRUE;

    // 设置name信息
    // iOS没有displayName
    bool hasName = false;
    NSMutableDictionary* dict = [aContact valueForKey:kW3ContactName];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        hasName = true;
        NSArray* propArray = [[XContact defaultObjectAndProperties] objectForKey: kW3ContactName];
        for(id index in propArray)
        {
            if (![(NSString*)index isEqualToString:kW3ContactFormattedName])
            {  //kW3ContactFormattedName从ABRecordCopyCompositeName()中产生所以不需要设置
                [self setValue:[dict valueForKey:index] forProperty: (ABPropertyID)[(NSNumber*)[[XContact defaultW3CtoAB] objectForKey: index]intValue] inRecord: person asUpdate: update];
            }
        }
    }

    id nickName = [aContact valueForKey:kW3ContactNickname];
    if (![nickName isKindOfClass:[NSNull class]])
    {
        hasName = true;
        [self setValue: nickName forProperty: kABPersonNicknameProperty inRecord: person asUpdate: update];
    }
    if (!hasName)
    {
        // 如果没有 name 和 nickname - try and use displayName as W3Contact must have displayName or ContactName
        [self setValue:[aContact valueForKey:kW3ContactDisplayName] forProperty: kABPersonNicknameProperty
              inRecord: person asUpdate: update];
    }

    // 设置 phoneNumbers
    NSArray* array = [aContact valueForKey:kW3ContactPhoneNumbers];
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        [self setMultiValueStrings: array forProperty: kABPersonPhoneProperty inRecord: person asUpdate: update];
    }
    // 设置 Emails
    array = [aContact valueForKey:kW3ContactEmails];
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        [self setMultiValueStrings: array forProperty: kABPersonEmailProperty inRecord: person asUpdate: update];
    }
    // 设置 Urls
    array = [aContact valueForKey:kW3ContactUrls];
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        [self setMultiValueStrings: array forProperty: kABPersonURLProperty inRecord: person asUpdate: update];
    }

    // 设置多值dictionary属性（addresses和ims）
    // 设置 addresses:  streetAddress, locality, region, postalCode, country
    // 设置 ims:  value = username, type = servicetype
    CFErrorRef error = nil;
    array = [aContact valueForKey:kW3ContactAddresses];
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        [self setMultiValueDictionary: array forProperty: kABPersonAddressProperty inRecord: person asUpdate: update];
    }
    //ims
    array = [aContact valueForKey:kW3ContactIms];
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        [self setMultiValueDictionary: array forProperty: kABPersonInstantMessageProperty inRecord: person asUpdate: update];
    }

    // 设置organizations
    // W3C ContactOrganization有pref, type, name, title, department属性
    // iOS只支持name, title, department
    array = [aContact valueForKey:kW3ContactOrganizations];  // iOS 只支持一个organization - 如果有多个使用第一个
    if ([array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        NSDictionary* dict = [array objectAtIndex:0];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            [self setValue: [dict valueForKey:kW3ContactOrganizationName] forProperty:kABPersonOrganizationProperty inRecord:person asUpdate: update];
            [self setValue: [dict valueForKey:kW3ContactTitle] forProperty:kABPersonJobTitleProperty inRecord:person asUpdate:update];
            [self setValue: [dict valueForKey:kW3ContactDepartment] forProperty:kABPersonDepartmentProperty inRecord:person asUpdate:update];
        }
    }
    // 设置 dates（单位为milliseconds）
    id millisecond = [aContact valueForKey:kW3ContactBirthday];
    NSDate* aDate = nil;
    if (millisecond && [millisecond isKindOfClass:[NSNumber class]])
    {
        double msValue = [millisecond doubleValue];
        msValue = msValue / 1000;
        aDate = [NSDate dateWithTimeIntervalSince1970: msValue];
    }
    if (aDate != nil || [millisecond isKindOfClass:[NSString class]])
    {
        [self setValue: aDate != nil ? aDate : millisecond forProperty:kABPersonBirthdayProperty inRecord:person asUpdate:update];
    }

    // 设置note
    [self setValue: [aContact valueForKey:kW3ContactNote] forProperty: kABPersonNoteProperty inRecord: person asUpdate: update];

    // 设置photo
    array = [aContact valueForKey: kW3ContactPhotos];
    if ([array isKindOfClass:[NSArray class]])
    {
        if (update && 0 == [array count])
        {
            // remove photo
            update = ABPersonRemoveImageData(person, &error);
        }
        else if ([array count] > 0)
        {
            NSDictionary* dict = [array objectAtIndex:0]; // 目前只支持一张图片
            if ([dict isKindOfClass:[NSDictionary class]])
            {
                id value = [dict objectForKey:kW3ContactFieldValue];
                if ([value isKindOfClass:[NSString class]])
                {
                    if (update && 0 == [value length])
                    {
                        // 删除当前图片
                        success = ABPersonRemoveImageData(person, &error);
                    }
                    else
                    {
                        NSString* cleanPath = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL* photoUrl = [NSURL URLWithString: [cleanPath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
                        NSError* __autoreleasing err = nil;
                        NSData* data = nil;
                        if (photoUrl)
                        {
                            data = [NSData dataWithContentsOfURL:photoUrl options: NSDataReadingUncached error:&err];
                        }
                        if(data && [data length] > 0)
                        {
                            success = ABPersonSetImageData(person, (__bridge CFDataRef)data, &error);
                        }
                        if (!data || !success)
                        {
                            XLogE(@"error setting contact image: %@", (err != nil ? [err localizedDescription] : @""));
                        }
                    }
                }
            }
        }
    }

    // TODO 设置WebURLs和timezone

    return success;
}

-(NSDictionary*) toDictionary: (NSDictionary*) fields
{
    if (kABPersonType != ABRecordGetRecordType(self.record))
    {
        return nil;
    }
    id value = nil;
    //FIXME:多个线程同时访问可能会存在覆写的情况（以目前ios执行js的流程是不会存在覆写的）
    self.returnFields = fields;

    NSMutableDictionary* newContact = [NSMutableDictionary dictionaryWithCapacity:1];
	// 设置id
	[newContact setObject: [NSNumber numberWithInt:ABRecordGetRecordID(self.record)] forKey:kW3ContactId];
    if (nil == self.returnFields)
    {
        //如果没有指定returnFields，W3C返回空联系人，但是我们最少会返回id
        return newContact;
    }
    if ([self.returnFields objectForKey:kW3ContactDisplayName])
    {
        // ios不支持diplayname所以返回null
        [newContact setObject: [NSNull null] forKey:kW3ContactDisplayName];
    }
    // 设置nickname
    if ([self.returnFields valueForKey:kW3ContactNickname])
    {
        value = (__bridge_transfer NSString*)ABRecordCopyValue(self.record, kABPersonNicknameProperty);
        [newContact setObject: (value != nil) ? value : [NSNull null] forKey:kW3ContactNickname];
	}

    // 设置name
    NSObject* data = [self extractName];
    if (data)
    {
        [newContact setObject:data forKey:kW3ContactName];
    }
    if ([self.returnFields objectForKey:kW3ContactDisplayName] && (nil == data || [NSNull null] == [(NSDictionary*)data objectForKey: kW3ContactFormattedName]))
    {
        //用户请求displayName，而ios不支持displayName，但是这里又没有其他的名字数据，此时这里采取使用Composite Name
        id compositeName = (__bridge_transfer NSString*)ABRecordCopyCompositeName(self.record);
        if (compositeName)
        {
            [newContact setObject:compositeName forKey:kW3ContactDisplayName];
        }
        else
        {
            // 如果没有Composite Name，则使用nickname或者空串
            value = (__bridge_transfer NSString*)ABRecordCopyValue(self.record, kABPersonNicknameProperty);
            [newContact setObject:(value != nil) ? value : @"" forKey:kW3ContactDisplayName];
        }
    }

    // 设置phoneNumbers
    value = [self extractMultiValue:kW3ContactPhoneNumbers];
    if (value)
    {
        [newContact setObject: value forKey: kW3ContactPhoneNumbers];
    }
    // 设置emails
    value = [self extractMultiValue:kW3ContactEmails];
    if (value)
    {
        [newContact setObject: value forKey: kW3ContactEmails];
    }
    // 设置urls
    value = [self extractMultiValue:kW3ContactUrls];
    if (value)
    {
        [newContact setObject: value forKey: kW3ContactUrls];
    }
    // 设置addresses
    value = [self extractAddresses];
    if (value)
    {
        [newContact setObject:value forKey: kW3ContactAddresses];
    }
    // 设置im
    value = [self extractIms];
    if (value)
    {
        [newContact setObject: value forKey: kW3ContactIms];
    }
    // 设置organization (ios只支持一个organization)
    value = [self extractOrganizations];
    if (value)
    {
        [newContact setObject:value forKey:kW3ContactOrganizations];
    }
    // 设置 dates（毫秒）
    if ([self.returnFields valueForKey:kW3ContactBirthday])
    {
        NSNumber *milliSec = [self getDateAsNumber: kABPersonBirthdayProperty];
        if(milliSec)
        {
            [newContact setObject: milliSec forKey: kW3ContactBirthday];
        }
    }
    // 设置note
    if ([self.returnFields valueForKey:kW3ContactNote])
    {
        value = (__bridge_transfer NSString*)ABRecordCopyValue(self.record, kABPersonNoteProperty);
        [newContact setObject: (value != nil) ? value : [NSNull null] forKey:kW3ContactNote];
    }
    // 设置photo
    if ([self.returnFields valueForKey:kW3ContactPhotos])
    {
        value = [self extractPhotos];
        [newContact setObject: (value != nil) ? value : [NSNull null] forKey:kW3ContactPhotos];
    }

    return newContact;
}

+(NSDictionary*) defaultFields
{
    if (!contactsDefaultFields)
    {
        contactsDefaultFields = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactName], kW3ContactName,
                                 [NSNull null], kW3ContactNickname,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactAddresses], kW3ContactAddresses,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactOrganizations], kW3ContactOrganizations,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactPhoneNumbers], kW3ContactPhoneNumbers,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactEmails], kW3ContactEmails,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactIms], kW3ContactIms,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactPhotos], kW3ContactPhotos,
                                 [[XContact defaultObjectAndProperties] objectForKey:kW3ContactUrls], kW3ContactUrls,
                                 [NSNull null],kW3ContactBirthday,
                                 [NSNull null],kW3ContactNote,
                                 nil];
    }
    return contactsDefaultFields;
}

+(NSDictionary*) calcReturnFields: (NSArray*)fieldsArray
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (fieldsArray && [fieldsArray isKindOfClass:[NSArray class]])
    {
        if (1 == [fieldsArray count] && [[fieldsArray objectAtIndex:0] isEqualToString:@"*"])
        {
            return [XContact defaultFields];  // 返回所有的字段
        }
        for (id key in fieldsArray)
        {
            NSMutableArray* keys = nil;
            NSString* fieldStr = nil;
            if ([key isKindOfClass: [NSNumber class]])
            {
                fieldStr = [key stringValue];
            }
            else
            {
                fieldStr = key;
            }

            NSArray* parts = [fieldStr componentsSeparatedByString:@"."];
            NSString* name = [parts objectAtIndex:0];
            NSString* property = nil;
            if ([parts count] > 1)
            {
                property = [parts objectAtIndex:1];
            }

            id fields = [[XContact defaultObjectAndProperties] objectForKey:name];

            if (fields && !property)
            {
                keys = [NSMutableArray arrayWithArray: fields];
                if(keys)
                {
                    [dict setObject:keys forKey:name];
                }
            }
            else if (fields && property)
            {
                id abEquiv = [[XContact defaultW3CtoAB] objectForKey:property];
                if (abEquiv || [[XContact defaultW3CtoNull] containsObject:property])
                {
                    if(nil != (keys = [dict objectForKey:name]))
                    {
                        [keys addObject:property];
                    }
                    else
                    {
                        keys = [NSMutableArray arrayWithObject:property];
                        [dict setObject: keys forKey:name];
                    }
                }
                else
                {
                    XLogW(@"Contacts.find -- request for invalid property ignored: %@.%@", name, property);
                }
            }
            else
            {
                id valid = [[XContact defaultW3CtoAB] objectForKey:name];
                if (valid || [[XContact defaultW3CtoNull] containsObject:name])
                {
                    [dict setObject:[NSNull null] forKey: name];
                }
            }
        }
    }
    if (0 == [dict count])
    {
        return nil;
    }
    return dict;
}

-(BOOL) findValue: (NSString*)value inFields: (NSDictionary*) searchFields
{
    BOOL isFound = NO;

    if (![value isKindOfClass: [NSString class]] || 0 == [value length])
    {
        return NO;
    }
    NSInteger valueAsInt = [value intValue];
    int recordId = ABRecordGetRecordID(self.record);
    if (valueAsInt && recordId == valueAsInt)
    {
        return YES;
    }

    if (!searchFields)
    {
        return NO;
    }
    //查找nickname是否等于指定的value值
    if ([searchFields valueForKey:kW3ContactNickname])
    {
        isFound = [self findStringValue:value forW3CProperty:kW3ContactNickname];
        if (isFound)
        {
            return isFound;
        }
    }
    //在ContactName对象中查找是否有属性的值等于指定的value的值
    if ([searchFields valueForKeyIsArray:kW3ContactName])
    {
        NSArray* fields = [searchFields valueForKey:kW3ContactName];
        for (NSString* item in fields)
        {
            if ([item isEqualToString:kW3ContactFormattedName])
            {
                NSString* propValue = (__bridge_transfer NSString*)ABRecordCopyCompositeName(self.record);
                if (propValue && [propValue length] > 0)
                {
                    NSRange range = [propValue rangeOfString:value options: NSCaseInsensitiveSearch];
                    isFound = (range.location != NSNotFound);
                }
            }
            else
            {
                isFound = [self findStringValue:value forW3CProperty:item];
            }

            if (isFound)
            {
                break;
            }
        }
    }
    //在phoneNumbers对象中查找是否有属性的值等于指定的value的值
    if (!isFound && [searchFields valueForKeyIsArray:kW3ContactPhoneNumbers])
    {
        isFound = [self findContactFields: (NSArray*) [searchFields valueForKey: kW3ContactPhoneNumbers] forMVStringProperty: kABPersonPhoneProperty withValue: value];
    }
    //在Emails对象中查找是否有属性的值等于指定的value的值
    if (!isFound && [searchFields valueForKeyIsArray: kW3ContactEmails])
    {
        isFound = [self findContactFields: (NSArray*) [searchFields valueForKey: kW3ContactEmails] forMVStringProperty: kABPersonEmailProperty withValue: value];
	}
    //在ContactAddresses对象中查找是否有属性的值等于指定的value的值
    if (!isFound && [searchFields valueForKeyIsArray: kW3ContactAddresses])
    {
        isFound = [self findContactFields: [searchFields valueForKey:kW3ContactAddresses] forMVDictionaryProperty: kABPersonAddressProperty withValue: value];
	}
    //在Ims对象中查找是否有属性的值等于指定的value的值
    if (!isFound && [searchFields valueForKeyIsArray: kW3ContactIms])
    {
        isFound = [self findContactFields: [searchFields valueForKey:kW3ContactIms] forMVDictionaryProperty: kABPersonInstantMessageProperty withValue: value];
	}
    //在ContactOrganizations对象中查找是否有属性的值等于指定的value的值
    if (!isFound && [searchFields valueForKeyIsArray: kW3ContactOrganizations])
    {
		NSArray* fields = [searchFields valueForKey: kW3ContactOrganizations];
        for (NSString* item in fields)
        {
            isFound = [self findStringValue:value forW3CProperty:item];
            if (isFound)
            {
                break;
            }
        }
    }
    //查找note是否等于指定的value值
    if (!isFound && [searchFields valueForKey:kW3ContactNote])
    {
        isFound = [self findStringValue:value forW3CProperty:kW3ContactNote];
    }

    //查找Birthday是否等于指定的value值
    if (!isFound && [searchFields valueForKey:kW3ContactBirthday])
    {
        isFound = [self findDateValue: value forW3CProperty: kW3ContactBirthday];
    }
    //在urls对象中查找是否有属性的值等于指定的value的值
    if (!isFound && [searchFields valueForKeyIsArray: kW3ContactUrls])
    {
        isFound = [self findContactFields: (NSArray*) [searchFields valueForKey: kW3ContactUrls] forMVStringProperty: kABPersonURLProperty withValue: value];
    }

    return isFound;
}

-(BOOL) findStringValue: (NSString*)value forW3CProperty: (NSString*) property
{
    BOOL isFound = NO;

    if ([[XContact defaultW3CtoAB] valueForKeyIsNumber: property ])
    {
        ABPropertyID propId = [[[XContact defaultW3CtoAB] objectForKey: property] intValue];
        if(kABStringPropertyType == ABPersonGetTypeOfProperty(propId))
        {
            NSString* propValue = (__bridge_transfer NSString*)ABRecordCopyValue(self.record, propId);
            if (propValue && [propValue length] > 0)
            {
                NSPredicate *containPred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", value];
                isFound = [containPred evaluateWithObject:propValue];
            }
        }
    }
    return isFound;
}

-(BOOL) findDateValue: (NSString*)value forW3CProperty: (NSString*) property
{
    BOOL isFound = NO;

    if ([[XContact defaultW3CtoAB] valueForKeyIsNumber: property ])
    {
        ABPropertyID propId = [[[XContact defaultW3CtoAB] objectForKey: property] intValue];
        if(kABDateTimePropertyType == ABPersonGetTypeOfProperty(propId))
        {
            NSDate* date = (__bridge_transfer NSDate*)ABRecordCopyValue(self.record, propId);
            if (date)
            {
                NSString* dateString = [date descriptionWithLocale:[NSLocale currentLocale]];
                NSPredicate *containPred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", value];
                isFound = [containPred evaluateWithObject:dateString];
            }
        }
    }
    return isFound;
}

-(BOOL) findContactFields: (NSArray*) fields forMVStringProperty: (ABPropertyID) propId withValue: value
{
    BOOL isFound = NO;
    for (NSString* type in fields)
    {
        NSString* stringValue = nil;
        if ([type isEqualToString: kW3ContactFieldType])
        {
            if ([XContact isValidW3CContactType: value])
            {
                stringValue = (NSString*)[XContact convertContactTypeToPropertyLabel:value];
            }
        }
        else
        {
            stringValue = value;
        }
        if (stringValue)
        {
            isFound = [self findMultiValueStrings:stringValue forProperty: propId ofType: type];
		}
        if (isFound)
        {
            break;
        }
    }
    return isFound;
}

- (BOOL) findMultiValueStrings: (NSString*) value forProperty: (ABPropertyID) propId ofType: (NSString*) type
{
    BOOL isFound = NO;

    if(kABMultiStringPropertyType == ABPersonGetTypeOfProperty(propId))
    {
        NSArray* valueArray = nil;
        if ([type isEqualToString:kW3ContactFieldType])
        {
            valueArray = [self labelsForProperty: propId inRecord: self.record];
        }
        else if ([type isEqualToString:kW3ContactFieldValue])
        {
            valueArray = [self valuesForProperty: propId inRecord: self.record];
        }
        if (valueArray)
        {
            NSString* valuesAsString = [valueArray componentsJoinedByString:@" "];
            NSPredicate *containPred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", value];
            isFound = [containPred evaluateWithObject:valuesAsString];
        }
    }
    return isFound;
}

- (NSArray *) valuesForProperty: (ABPropertyID) propId inRecord: (ABRecordRef) aRecord
{
    ABMultiValueRef multi = ABRecordCopyValue(aRecord, propId);
    NSArray *values = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multi);
    CFRelease(multi);
    return values;
}

- (NSArray *) labelsForProperty: (ABPropertyID) propId inRecord: (ABRecordRef)aRecord
{
    ABMultiValueRef multi = ABRecordCopyValue(aRecord, propId);
    CFIndex count = ABMultiValueGetCount(multi);
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:count];
    for (int index = 0; index < count; index++)
    {
        NSString *label = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(multi, index);
        if (label)
        {
            [labels addObject:label];
        }
    }
    CFRelease(multi);
    return labels;
}

-(BOOL) findContactFields: (NSArray*) fields forMVDictionaryProperty: (ABPropertyID) propId withValue: (NSString*)value
{
    BOOL isFound = NO;

    NSArray* values = [self valuesForProperty:propId inRecord:self.record];
    for(id dict in values)
    {
        for(NSString* member in fields)
        {
            NSString* abKey = [[XContact defaultW3CtoAB] valueForKey:member];
            NSString* abValue = nil;
            if (abKey)
            {
                NSString* stringValue = nil;
                if ([member isEqualToString:kW3ContactImType])
                {
                    if ([XContact isValidW3CContactType: value])
                    {
                        stringValue = (NSString*)[XContact convertContactTypeToPropertyLabel:value];
                    }
                }
                else
                {
                    stringValue = value;
                }
                if(stringValue)
                {
                    BOOL exists = CFDictionaryGetValueIfPresent((__bridge CFDictionaryRef)dict, (__bridge const void *)abKey, (void *)&abValue);
                    if(exists)
                    {
                        NSPredicate *containPred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", stringValue];
                        isFound = [containPred evaluateWithObject:abValue];
                    }
                }
            }
            if (isFound)
            {
                break;
            }
        }
        if (isFound)
        {
            break;
        }
    }
    return isFound;
}

#pragma mark private implementations

+(NSDictionary*) defaultABtoW3C
{
    if (!contactsABtoW3C)
    {
        contactsABtoW3C = [NSDictionary dictionaryWithObjectsAndKeys:
                                kW3ContactNickname, [NSNumber numberWithInt:kABPersonNicknameProperty],
                                kW3ContactGivenName, [NSNumber numberWithInt:kABPersonFirstNameProperty],
                                kW3ContactFamilyName, [NSNumber numberWithInt:kABPersonLastNameProperty],
                                kW3ContactMiddleName, [NSNumber numberWithInt:kABPersonMiddleNameProperty],
                                kW3ContactHonorificPrefix, [NSNumber numberWithInt:kABPersonPrefixProperty],
                                kW3ContactHonorificSuffix, [NSNumber numberWithInt:kABPersonSuffixProperty],
                                kW3ContactPhoneNumbers, [NSNumber numberWithInt:kABPersonPhoneProperty],
                                kW3ContactAddresses, [NSNumber numberWithInt:kABPersonAddressProperty],
                                kW3ContactStreetAddress, kABPersonAddressStreetKey,
                                kW3ContactLocality, kABPersonAddressCityKey,
                                kW3ContactRegion, kABPersonAddressStateKey,
                                kW3ContactPostalCode, kABPersonAddressZIPKey,
                                kW3ContactCountry, kABPersonAddressCountryKey,
                                kW3ContactEmails, [NSNumber numberWithInt: kABPersonEmailProperty],
                                kW3ContactIms, [NSNumber numberWithInt: kABPersonInstantMessageProperty],
                                kW3ContactOrganizations, [NSNumber numberWithInt: kABPersonOrganizationProperty],
                                kW3ContactOrganizationName, [NSNumber numberWithInt: kABPersonOrganizationProperty],
                                kW3ContactTitle, [NSNumber numberWithInt: kABPersonJobTitleProperty],
                                kW3ContactDepartment, [NSNumber numberWithInt:kABPersonDepartmentProperty],
                                kW3ContactBirthday, [NSNumber numberWithInt: kABPersonBirthdayProperty],
                                kW3ContactUrls, [NSNumber numberWithInt: kABPersonURLProperty],
                                kW3ContactNote, [NSNumber numberWithInt: kABPersonNoteProperty],
                                nil];
    }

    return contactsABtoW3C;
}

+(NSDictionary*) defaultW3CtoAB
{
    if (!contactsW3CtoAB)
    {
        contactsW3CtoAB = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt: kABPersonNicknameProperty], kW3ContactNickname,
                                [NSNumber numberWithInt: kABPersonFirstNameProperty], kW3ContactGivenName,
                                [NSNumber numberWithInt: kABPersonLastNameProperty], kW3ContactFamilyName,
                                [NSNumber numberWithInt: kABPersonMiddleNameProperty], kW3ContactMiddleName,
                                [NSNumber numberWithInt: kABPersonPrefixProperty], kW3ContactHonorificPrefix,
                                [NSNumber numberWithInt: kABPersonSuffixProperty], kW3ContactHonorificSuffix,
                                [NSNumber numberWithInt: kABPersonPhoneProperty], kW3ContactPhoneNumbers,
                                [NSNumber numberWithInt: kABPersonAddressProperty], kW3ContactAddresses,
                                kABPersonAddressStreetKey, kW3ContactStreetAddress,
                                kABPersonAddressCityKey, kW3ContactLocality,
                                kABPersonAddressStateKey, kW3ContactRegion,
                                kABPersonAddressZIPKey, kW3ContactPostalCode,
                                kABPersonAddressCountryKey, kW3ContactCountry,
                                [NSNumber numberWithInt: kABPersonEmailProperty], kW3ContactEmails,
                                [NSNumber numberWithInt: kABPersonInstantMessageProperty], kW3ContactIms,
                                [NSNumber numberWithInt: kABPersonOrganizationProperty], kW3ContactOrganizations,
                                [NSNumber numberWithInt: kABPersonJobTitleProperty], kW3ContactTitle,
                                [NSNumber numberWithInt:kABPersonDepartmentProperty], kW3ContactDepartment,
                                [NSNumber numberWithInt: kABPersonBirthdayProperty], kW3ContactBirthday,
                                [NSNumber numberWithInt: kABPersonNoteProperty], kW3ContactNote,
                                [NSNumber numberWithInt: kABPersonURLProperty], kW3ContactUrls,
                                kABPersonInstantMessageUsernameKey, kW3ContactImValue,
                                kABPersonInstantMessageServiceKey, kW3ContactImType,
                                [NSNull null], kW3ContactFieldType,
                                [NSNull null], kW3ContactFieldValue,
                                [NSNull null], kW3ContactFieldPrimary,
                                [NSNull null], kW3ContactFieldId,
                                [NSNumber numberWithInt: kABPersonOrganizationProperty], kW3ContactOrganizationName,
                                nil];
    }
    return contactsW3CtoAB;
}

+(NSSet*) defaultW3CtoNull
{
	// these are values that have no AddressBook Equivalent or have not been implemented yet
    if (!contactsW3CtoNull)
    {
        contactsW3CtoNull = [NSSet setWithObjects: kW3ContactDisplayName,
                                                kW3ContactCategories, kW3ContactFormattedName, nil];
    }
    return contactsW3CtoNull;
}

+(NSDictionary*) defaultObjectAndProperties
{
    if (!contactsObjectAndProperties)
    {
        contactsObjectAndProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSArray arrayWithObjects:kW3ContactGivenName,kW3ContactFamilyName,
                                                kW3ContactMiddleName, kW3ContactHonorificPrefix, kW3ContactHonorificSuffix, kW3ContactFormattedName, nil], kW3ContactName,
                                            [NSArray arrayWithObjects:kW3ContactStreetAddress, kW3ContactLocality,kW3ContactRegion, kW3ContactPostalCode, kW3ContactCountry, nil], kW3ContactAddresses,
                                            [NSArray arrayWithObjects:kW3ContactOrganizationName, kW3ContactTitle, kW3ContactDepartment, nil], kW3ContactOrganizations,
                                            [NSArray arrayWithObjects:kW3ContactFieldType, kW3ContactFieldValue, kW3ContactFieldPrimary,nil], kW3ContactPhoneNumbers,
                                            [NSArray arrayWithObjects:kW3ContactFieldType, kW3ContactFieldValue, kW3ContactFieldPrimary,nil], kW3ContactEmails,
                                            [NSArray arrayWithObjects:kW3ContactFieldType, kW3ContactFieldValue, kW3ContactFieldPrimary,nil], kW3ContactPhotos,
                                            [NSArray arrayWithObjects:kW3ContactFieldType, kW3ContactFieldValue, kW3ContactFieldPrimary,nil], kW3ContactUrls,
                                            [NSArray arrayWithObjects:kW3ContactImValue, kW3ContactImType, nil], kW3ContactIms,
                                            nil];
    }
    return contactsObjectAndProperties;
}

- (bool) setValue: (id)aValue forProperty: (ABPropertyID) aProperty inRecord: (ABRecordRef) aRecord asUpdate: (BOOL) update
{
    bool success = true;  // 如果属性为空，直接忽略并返回成功
    CFErrorRef error = nil;
    if (aValue && ![aValue isKindOfClass:[NSNull class]])
    {
        if (update && ([aValue isKindOfClass:[NSString class]] && 0 == [aValue length]))
        { // 如果是更新, 空串意味着删除
            aValue = nil;
        }
        success = ABRecordSetValue(aRecord, aProperty, (__bridge CFTypeRef)aValue, &error);
        if (!success)
        {
            XLogE(@"error setting %d property", aProperty);
        }
    }

    return success;
}

-(bool) removeProperty: (ABPropertyID) aProperty inRecord: (ABRecordRef) aRecord
{
    CFErrorRef err = nil;
    bool success = ABRecordRemoveValue(aRecord, aProperty, &err);
    if(!success)
    {
        CFStringRef errDescription = CFErrorCopyDescription(err);
        XLogE(@"Unable to remove property %d: %@", aProperty, errDescription );
        CFRelease(errDescription);
    }
    return success;
}

-(bool) addToMultiValue: (ABMultiValueRef) multi fromDictionary:dict
{
    bool success = FALSE;
    id value = [dict valueForKey:kW3ContactFieldValue];
    if (IS_VALID_VALUE(value))
    {
        NSString* label = (NSString*)[XContact convertContactTypeToPropertyLabel:[dict valueForKey:kW3ContactFieldType]];
        success = ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)value,(__bridge CFStringRef)label, nil);
        if (!success)
        {
            XLogE(@"Error setting Value: %@ and label: %@", value, label);
        }
    }
    return success;
}

-(ABMultiValueRef) allocStringMultiValueFromArray:(NSArray*)array
{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for (NSDictionary *dict in array)
    {
        [self addToMultiValue: multi fromDictionary: dict];
    }
    return multi;
}

-(bool) setValue: (CFTypeRef) value forProperty:(ABPropertyID)prop inRecord:(ABRecordRef)person
{
    CFErrorRef error = nil;
    bool success = ABRecordSetValue(person, prop,  value, &error);
    if (!success)
    {
        XLogE(@"Error setting value for property: %d", prop);
    }
    return success;
}

+(bool) needConversion: (NSString*)w3cLabel
{
    return ([w3cLabel isEqualToString:kW3ContactFieldType] || [w3cLabel isEqualToString:kW3ContactImType]);
}

+(CFStringRef) convertContactTypeToPropertyLabel:(NSString*)label
{
    CFStringRef type = nil;

    if ([label isKindOfClass:[NSNull class]] || ![label isKindOfClass:[NSString class]])
    {
        type = nil;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare: kW3ContactWorkLabel])
    {
        type = kABWorkLabel;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare: kW3ContactHomeLabel])
    {
        type = kABHomeLabel;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare: kW3ContactOtherLabel])
    {
        type = kABOtherLabel;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactPhoneMobileLabel])
    {
        type = kABPersonPhoneMobileLabel;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactPhonePagerLabel])
    {
        type = kABPersonPhonePagerLabel;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImAIMLabel])
    {
        type = kABPersonInstantMessageServiceAIM;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImICQLabel])
    {
        type = kABPersonInstantMessageServiceICQ;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImMSNLabel])
    {
        type = kABPersonInstantMessageServiceMSN;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImYahooLabel])
    {
        type = kABPersonInstantMessageServiceYahoo;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactUrlProfile])
    {
        type = kABPersonHomePageLabel;
    }
    else
    {
        type = kABOtherLabel;
    }

    return type;
}

+(NSString*) convertPropertyLabelToContactType: (NSString*)label
{
    NSString* type = nil;
    if (label)
    {
        if ([label isEqualToString:(NSString*)kABPersonPhoneMobileLabel])
        {
            type = kW3ContactPhoneMobileLabel;
        }
        else if ([label isEqualToString: (NSString*)kABPersonPhoneHomeFAXLabel] ||
				  [label isEqualToString: (NSString*)kABPersonPhoneWorkFAXLabel])
        {
            type=kW3ContactPhoneFaxLabel;
        }
        else if ([label isEqualToString:(NSString*)kABPersonPhonePagerLabel])
        {
            type = kW3ContactPhonePagerLabel;
        }
        else if ([label isEqualToString:(NSString*)kABHomeLabel])
        {
            type = kW3ContactHomeLabel;
        }
        else if ([label isEqualToString:(NSString*)kABWorkLabel])
        {
            type = kW3ContactWorkLabel;
        }
        else if ([label isEqualToString:(NSString*)kABOtherLabel])
        {
            type = kW3ContactOtherLabel;
        }
        else if ([label isEqualToString:(NSString*)kABPersonInstantMessageServiceAIM])
        {
            type = kW3ContactImAIMLabel;
        }
        else if ([label isEqualToString: (NSString*)kABPersonInstantMessageServiceICQ])
        {
            type=kW3ContactImICQLabel;
        }
        else if ([label isEqualToString:(NSString*)kABPersonInstantMessageServiceJabber])
        {
            type = kW3ContactOtherLabel;
        }
        else if ([label isEqualToString:(NSString*)kABPersonInstantMessageServiceMSN])
        {
            type = kW3ContactImMSNLabel;
        }
        else if ([label isEqualToString:(NSString*)kABPersonInstantMessageServiceYahoo])
        {
            type = kW3ContactImYahooLabel;
        }
        else if ([label isEqualToString:(NSString*)kABPersonHomePageLabel])
        {
            type = kW3ContactUrlProfile;
        }
        else
        {
            type = kW3ContactOtherLabel;
        }
    }
    return type;
}

+(bool) isValidW3CContactType: (NSString*) label
{
    bool isValid = FALSE;
    if ([label isKindOfClass:[NSNull class]] || ![label isKindOfClass:[NSString class]])
    {
        isValid = FALSE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare: kW3ContactWorkLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare: kW3ContactHomeLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare: kW3ContactOtherLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactPhoneMobileLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactPhonePagerLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImAIMLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImICQLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImMSNLabel])
    {
        isValid = TRUE;
    }
    else if (NSOrderedSame == [label caseInsensitiveCompare:kW3ContactImYahooLabel])
    {
        isValid = TRUE;
    }
    else
    {
        isValid = FALSE;
    }

    return isValid;
}

-(bool) setMultiValueStrings: (NSArray*)fieldArray forProperty: (ABPropertyID) prop inRecord: (ABRecordRef)person asUpdate: (BOOL)update
{
    bool success = TRUE;
    ABMutableMultiValueRef multi = nil;

    if (!update)
    {
        multi = [self allocStringMultiValueFromArray: fieldArray];
        success = [self setValue: multi forProperty:prop inRecord: person];
    }
    else if (update && 0 == [fieldArray count])
    {
        // 删除所有属性
        success = [self removeProperty: prop inRecord: person];
    }
    else
    {
        ABMultiValueRef copy = ABRecordCopyValue(person, prop);
        if (copy != nil)
        {
            multi = ABMultiValueCreateMutableCopy(copy);
            CFRelease(copy);
            for(NSDictionary* dict in fieldArray)
            {
                id val;
                NSString* label = nil;
                val = [dict valueForKey:kW3ContactFieldValue];
                label = (NSString*)[XContact convertContactTypeToPropertyLabel:[dict valueForKey:kW3ContactFieldType]];
                if (IS_VALID_VALUE(val))
                {
                    // 如果是更新，找到匹配的id，如果值不同就执行更新.
                    id idValue = [dict valueForKey: kW3ContactFieldId];
                    int identifier = [idValue isKindOfClass:[NSNumber class]] ? [idValue intValue] : -1;
                    CFIndex index = identifier >= 0 ? ABMultiValueGetIndexForIdentifier(multi, identifier) : kCFNotFound;
                    if (kCFNotFound != index)
                    {
                        if (0 == [val length])
                        {
                            // 删除value和label
                            ABMultiValueRemoveValueAndLabelAtIndex(multi, index);
                        }
                        else
                        {
                            NSString* valueAB = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(multi, index);
                            NSString* labelAB = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(multi, index);
                            if (!valueAB || ![val isEqualToString: valueAB])
                            {
                                ABMultiValueReplaceValueAtIndex(multi, (__bridge CFTypeRef)val, index);
                            }
                            if (!labelAB || ![label isEqualToString:labelAB])
                            {
                                ABMultiValueReplaceLabelAtIndex(multi, (__bridge CFStringRef)label, index);
                            }
                        }
                    }
                    else
                    {
                        // 如果是新的值就执行添加
                        [self addToMultiValue: multi fromDictionary: dict];
                    }
                }
            }
        }
        else
        { // 不是更新，添加所有的值
            multi = [self allocStringMultiValueFromArray: fieldArray];
        }

        success = [self setValue: multi forProperty:prop inRecord: person];
    }

    if (multi)
    {
        CFRelease(multi);
    }

    return success;
}

/**
    将存储W3C联系人的dictionary转换成存储AB的Dictionary（用于ims和addresses）
 */
-(NSMutableDictionary*) translateW3CDict: (NSDictionary*) dict forProperty: (ABPropertyID) prop
{
    NSArray* propArray = [[XContact defaultObjectAndProperties] valueForKey:[[XContact defaultABtoW3C] objectForKey:[NSNumber numberWithInt:prop]]];

    NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithCapacity:1];
    id value;
    for(NSString* key in propArray)
    {
        if ((value = [dict valueForKey:key]) != nil && ![value isKindOfClass:[NSNull class]])
        {
            NSString *newValue = value;
            if ([XContact needConversion: key])
            { // IM 类型必须转换
                newValue = (NSString*)[XContact convertContactTypeToPropertyLabel:value];
                if (kABPersonInstantMessageProperty == prop && [newValue isEqualToString: (NSString*)kABOtherLabel])
                {
                    newValue = @"";
                }
            }
            [newDict setObject:newValue forKey: (NSString*)[[XContact defaultW3CtoAB] valueForKey:(NSString*)key]];
        }
    }
    if (0 == [newDict count])
    {
        newDict = nil;
    }
    return newDict;
}

-(ABMultiValueRef) allocDictMultiValueFromArray: array forProperty: (ABPropertyID) prop
{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary* newDict = nil;
    NSMutableDictionary* addDict = nil;
    for (NSDictionary *dict in array)
    {
        newDict = [self translateW3CDict: dict forProperty: prop];
        addDict = [NSMutableDictionary dictionaryWithCapacity: 2];
        if (newDict)
        {
            NSString* addrType = (NSString*)[dict valueForKey: kW3ContactFieldType];
            if (!addrType)
            {
                addrType =  (NSString*) kABOtherLabel;
            }
            NSObject* typeValue = ((kABPersonInstantMessageProperty == prop) ? (NSObject*)kABOtherLabel : addrType);
            [addDict setObject: typeValue forKey: kW3ContactFieldType];
            [addDict setObject: newDict forKey:kW3ContactFieldValue];
            [self addToMultiValue: multi fromDictionary: addDict];
        }
    }
    return multi;
}

-(bool) setMultiValueDictionary: (NSArray*)array forProperty: (ABPropertyID) prop inRecord: (ABRecordRef)person asUpdate: (BOOL)update
{
    bool success = FALSE;
    ABMutableMultiValueRef multi = nil;
    if (!update)
    {
        multi = [self allocDictMultiValueFromArray: array forProperty: prop];
        success = [self setValue: multi forProperty:prop inRecord: person];
    }
    else if (update && 0 == [array count])
    {
        // 删除属性
        success = [self removeProperty: prop inRecord: person];
    }
    else
    {
        ABMultiValueRef copy = ABRecordCopyValue(person, prop);
        if (copy)
        {
            multi = ABMultiValueCreateMutableCopy(copy);
            CFRelease(copy);
            NSArray* propArray = [[XContact defaultObjectAndProperties] valueForKey: [[XContact defaultABtoW3C] objectForKey:[NSNumber numberWithInt: prop]]];
            id value;
            id valueAB;
            for (NSDictionary* field in array)
            {
                NSMutableDictionary* dict;
                id idValue = [field valueForKey: kW3ContactFieldId];
                int identifier = [idValue isKindOfClass:[NSNumber class]] ? [idValue intValue] : -1;
                CFIndex index = identifier >= 0 ? ABMultiValueGetIndexForIdentifier(multi, identifier) : kCFNotFound;
                BOOL updateLabel = NO;
                if (kCFNotFound != index)
                {
                    dict = [NSMutableDictionary dictionaryWithCapacity:1];
                    NSDictionary* existingDictionary = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(multi, index);
                    NSString* existingABLabel = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(multi, index);
                    NSString* testLabel = [field valueForKey:kW3ContactFieldType];
                    if (testLabel && [testLabel isKindOfClass:[NSString class]] && [testLabel length] > 0)
                    {
                        CFStringRef w3cLabel = [XContact convertContactTypeToPropertyLabel:testLabel];
                        if (w3cLabel && ![existingABLabel isEqualToString:(__bridge_transfer NSString*)w3cLabel])
                        {
                            ABMultiValueReplaceLabelAtIndex(multi, w3cLabel,index);
                            updateLabel = YES;
                        }
                    }
                    for (id key in propArray)
                    {
                        value = [field valueForKey:key];
                        bool needSet = (value != nil && ![value isKindOfClass:[NSNull class]] && ([value isKindOfClass:[NSString class]] && [value length] > 0));
                        if (needSet)
                        {
                            NSString* setValue = [XContact needConversion:(NSString*)key] ? (NSString*)[XContact convertContactTypeToPropertyLabel:value] : value;
                            [dict setObject:setValue forKey: (NSString*)[[XContact defaultW3CtoAB] valueForKey:(NSString*)key]];
                        }
                        else if (!value || ([value isKindOfClass:[NSString class]] && [value length] != 0))
                        {
                            valueAB = [existingDictionary valueForKey:[[XContact defaultW3CtoAB] valueForKey:key]];
                            if (valueAB)
                            {
                                [dict setValue:valueAB forKey:[[XContact defaultW3CtoAB] valueForKey:key]];
                            }
                        }
                    }
                    if ([dict count] > 0)
                    {
                        ABMultiValueReplaceValueAtIndex(multi, (__bridge CFTypeRef)dict, index);
                    }
                    else if (!updateLabel)
                    {
                        ABMultiValueRemoveValueAndLabelAtIndex(multi, index);
                    }
                }
                else
                {
                    dict = [self translateW3CDict:field forProperty:prop];
                    if (dict)
                    {
                        NSMutableDictionary* addDict = [NSMutableDictionary dictionaryWithCapacity:2];
                        NSObject* typeValue = ((kABPersonInstantMessageProperty == prop) ? (NSObject*)kABOtherLabel : (NSString*)[field valueForKey: kW3ContactFieldType]);
                        XLogI(@"typeValue: %@", typeValue);
                        [addDict setObject: typeValue forKey: kW3ContactFieldType];
                        [addDict setObject: dict forKey:kW3ContactFieldValue];
                        [self addToMultiValue: multi fromDictionary: addDict];
                    }
                }
            }
            success = [self setValue: multi forProperty:prop inRecord: person];
        }
    }
    if (multi)
    {
        CFRelease(multi);
    }
    return success;
}

-(NSNumber*) getDateAsNumber: (ABPropertyID) datePropId
{
    NSNumber* msDate = nil;
    NSDate* aDate = nil;
    CFTypeRef cfDate = ABRecordCopyValue(self.record, datePropId);
    if (cfDate)
    {
        aDate = (__bridge_transfer NSDate*) cfDate;
        msDate = [NSNumber numberWithDouble:([aDate timeIntervalSince1970] * 1000)];
    }
    return msDate;
}

-(NSObject*) extractName
{
    NSArray* fields = [self.returnFields objectForKey:kW3ContactName];
    if (!fields)
    {
        return nil;
    }
    NSMutableDictionary* newName = [NSMutableDictionary dictionaryWithCapacity:6];
    id value = nil;
    for (NSString* key in fields)
    {
        if ([key isEqualToString:kW3ContactFormattedName])
        {
            value = (__bridge_transfer NSString*)ABRecordCopyCompositeName(self.record);
            [newName setObject: (value != nil) ? value : [NSNull null] forKey: kW3ContactFormattedName];
        }
        else
        {
            value = (__bridge_transfer NSString*)ABRecordCopyValue(self.record, (ABPropertyID)[[[XContact defaultW3CtoAB] valueForKey:key] intValue]);
            [newName setObject: (value != nil) ? value : [NSNull null] forKey:key];
        }
    }

    return newName;
}

-(NSObject*) extractMultiValue: (NSString*)propertyId
{
    NSArray* fields = [self.returnFields objectForKey:propertyId];
    if (!fields)
    {
        return nil;
    }
    ABMultiValueRef multi = nil;
    NSObject* valuesArray = nil;
    NSNumber* propNumber = [[XContact defaultW3CtoAB] valueForKey:propertyId];
    ABPropertyID propId = [propNumber intValue];
    multi = ABRecordCopyValue(self.record, propId);
    CFIndex count =  multi != nil ? ABMultiValueGetCount(multi):0;
    id value = nil;
    if (count)
    {
        valuesArray = [NSMutableArray arrayWithCapacity:count];
        for (CFIndex index = 0; index < count; index++)
        {
            NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithCapacity:4];
            if ([fields containsObject:kW3ContactFieldType])
            {
                NSString* label = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(multi, index);
                value = [XContact convertPropertyLabelToContactType: label];
                [newDict setObject: (value != nil) ? value : [NSNull null] forKey: kW3ContactFieldType];
            }
            if ([fields containsObject:kW3ContactFieldValue])
            {
                value = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(multi, index);
                [newDict setObject: (value != nil) ? value : [NSNull null] forKey: kW3ContactFieldValue];
            }
            if ([fields containsObject:kW3ContactFieldPrimary])
            {
                // iOS 不支持Primary，所以设置为false
                [newDict setObject: [NSNumber numberWithBool:(BOOL)NO] forKey: kW3ContactFieldPrimary];
            }
            // 设置id
            value = [NSNumber numberWithUnsignedInt: ABMultiValueGetIdentifierAtIndex(multi,index)];
            [newDict setObject: (value !=nil) ? value : [NSNull null] forKey:kW3ContactFieldId];
            [(NSMutableArray*)valuesArray addObject:newDict];
        }
    }
    else
    {
        valuesArray = [NSNull null];
    }
    if (multi)
    {
        CFRelease(multi);
    }

    return valuesArray;
}

-(NSObject*) extractAddresses
{
    NSArray* fields = [self.returnFields objectForKey:kW3ContactAddresses];
    if (!fields)
    {
        return nil;
    }
    CFStringRef value = NULL;
    NSObject* addresses = nil;
    ABMultiValueRef multi = ABRecordCopyValue(self.record, kABPersonAddressProperty);
    CFIndex count = multi ? ABMultiValueGetCount(multi) : 0;
    if (count)
    {
        addresses = [NSMutableArray arrayWithCapacity:count];
        for (CFIndex index = 0; index < count; index++)
        {
            NSMutableDictionary* newAddress = [NSMutableDictionary dictionaryWithCapacity:7];
            // 设置id
            id identifier = [NSNumber numberWithUnsignedInt: ABMultiValueGetIdentifierAtIndex(multi,index)];
            [newAddress setObject: (identifier != nil) ? identifier : [NSNull null] forKey:kW3ContactFieldId];

            // 设置type
            NSString* label = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(multi, index);
            [newAddress setObject: (label != nil) ? (NSObject*) [[XContact class] convertPropertyLabelToContactType:label] : [NSNull null] forKey:kW3ContactFieldType];

            // 设置pref，iOS 不支持，默认设置为false
            [newAddress setObject:@"false" forKey:kW3ContactFieldPrimary];

            CFDictionaryRef dict = (CFDictionaryRef) ABMultiValueCopyValueAtIndex(multi, index);
            for(id key in fields)
            {
                bool isFound;
                id newKey = [[XContact defaultW3CtoAB] valueForKey:key];
                if (newKey && ![key isKindOfClass:[NSNull class]])
                {
                    isFound = CFDictionaryGetValueIfPresent(dict, (__bridge const void *)newKey, (void *)&value);
                    if(isFound && value != NULL)
                    {
                        CFRetain(value);
                        [newAddress setObject:(__bridge_transfer id)value forKey: key];
                    }
                    else
                    {
                        [newAddress setObject:[NSNull null] forKey:key];
                    }

                }
                else
                {
                    // 如果是ios不支持的属性
                    [newAddress setObject:[NSNull null] forKey:key];
                }
            }
            if ([newAddress count] > 0)
            {
                [(NSMutableArray*)addresses addObject:newAddress];
            }
            CFRelease(dict);
        }
    }
    else
    {
        addresses = [NSNull null];
    }
    if (multi)
    {
        CFRelease(multi);
    }

    return addresses;
}

-(NSObject*) extractIms
{
    NSArray* fields = [self.returnFields objectForKey:kW3ContactIms];
    if (!fields)
    {
        return nil;
    }
    NSObject* imArray = nil;
    ABMultiValueRef multi = ABRecordCopyValue(self.record, kABPersonInstantMessageProperty);
    CFIndex count = multi ? ABMultiValueGetCount(multi) : 0;
    if (count)
    {
        imArray = [NSMutableArray arrayWithCapacity:count];
        for (CFIndex index = 0; index < ABMultiValueGetCount(multi); index++)
        {
            NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithCapacity:3];
            CFDictionaryRef dict = (CFDictionaryRef) ABMultiValueCopyValueAtIndex(multi, index);
            CFStringRef value = NULL;
            bool isFound = FALSE;
            if ([fields containsObject: kW3ContactFieldValue])
            {
                isFound = CFDictionaryGetValueIfPresent(dict, kABPersonInstantMessageUsernameKey, (void *)&value);
                if(isFound && value != NULL)
                {
                    CFRetain(value);
                    [newDict setObject:(__bridge_transfer NSString*)value forKey: kW3ContactFieldValue];
                }
                else
                {
                    [newDict setObject:[NSNull null] forKey:kW3ContactFieldValue];
                }
            }
            if ([fields containsObject: kW3ContactFieldType])
            {
                isFound = CFDictionaryGetValueIfPresent(dict, kABPersonInstantMessageServiceKey, (void *)&value);
                if(isFound && value != NULL)
                {
                    CFRetain(value);
                    [newDict setObject:(id)[[XContact class ]convertPropertyLabelToContactType: (__bridge_transfer NSString*)value] forKey: kW3ContactFieldType];
                }
                else
                {
                    [newDict setObject:[NSNull null] forKey:kW3ContactFieldType];
                }
            }
            id identifier = [NSNumber numberWithUnsignedInt: ABMultiValueGetIdentifierAtIndex(multi,index)];
            [newDict setObject: (identifier != nil) ? identifier : [NSNull null] forKey:kW3ContactFieldId];

            [(NSMutableArray*)imArray addObject:newDict];
            CFRelease(dict);
        }
    }
    else
    {
        imArray = [NSNull null];
    }

    if (multi)
    {
        CFRelease(multi);
    }

    return imArray;
}

-(NSObject*) extractOrganizations
{
    NSArray* fields = [self.returnFields objectForKey:kW3ContactOrganizations];
    if (!fields)
    {
        return nil;
    }
    NSObject* array = nil;
    NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithCapacity:5];
    id value = nil;
    int validValueCount = 0;
    for (id index in fields)
    {
        id key = [[XContact defaultW3CtoAB] valueForKey:index];
        if (key && [key isKindOfClass:[NSNumber class]])
        {
            value = (__bridge_transfer NSString *)ABRecordCopyValue(self.record, (ABPropertyID)[[[XContact defaultW3CtoAB] valueForKey:index] intValue]);
            if (value)
            {
                validValueCount++;
            }
            [newDict setObject:(value != nil) ? value : [NSNull null] forKey:index];
        }
        else
        {
            [newDict setObject:[NSNull null] forKey:index];
        }
    }
    if ([newDict count] > 0 && validValueCount > 0)
    {
        // 添加 pref和type属性，ios不支持pref和type属性，所以不会发生变化
        [newDict setObject: @"false" forKey:kW3ContactFieldPrimary];
        [newDict setObject: [NSNull null] forKey: kW3ContactFieldType];
        array = [NSMutableArray arrayWithCapacity:1];
        [(NSMutableArray*)array addObject:newDict];
    }
    else
    {
        array = [NSNull null];
    }
    return array;
}

-(NSObject*) extractPhotos
{
    NSMutableArray* photos = nil;
    if (ABPersonHasImageData(self.record))
    {
        NSData* data = (__bridge_transfer NSData*)ABPersonCopyImageData(self.record);
        NSString* docsPath = [NSTemporaryDirectory() stringByStandardizingPath];
        __autoreleasing NSError* err = nil;
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        // 产生唯一的文件名
        NSString* filePath = nil;
        int index = 1;
        do {
            filePath = [NSString stringWithFormat:@"%@/photo_%03d.jpg", docsPath, index++];
        } while([fileMgr fileExistsAtPath: filePath]);
        // 保存文件
        if ([data writeToFile: filePath options: NSAtomicWrite error: &err])
        {
            photos = [NSMutableArray arrayWithCapacity:1];
            NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [newDict setObject:filePath forKey:kW3ContactFieldValue];
            [newDict setObject:@"url" forKey:kW3ContactFieldType];
            [newDict setObject:@"false" forKey:kW3ContactFieldPrimary];
            [photos addObject:newDict];
        }
    }
    return photos;
}

@end

#endif
