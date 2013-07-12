
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
//  XContact.h
//  xFace
//
//

#ifdef __XContactsExt__

#import <Foundation/Foundation.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface XContact : NSObject
{
    ABRecordRef record;
    NSDictionary *returnFields;
}

@property (nonatomic) ABRecordRef record;
@property (nonatomic, strong) NSDictionary* returnFields;

/**
    初始化方法
 */
-(id)init;

/**
    初始化方法
    根据ABRecordRef初始化record
 */
-(id)initFromABRecord: (ABRecordRef) aRecord;

/**
    支持的所有W3C联系人属性
    @return 所有W3C联系人属性
 */
+(NSDictionary*) defaultFields;

/**
    转换W3C联系人数据并将数据设置到ABRecordRef对象中
    @param aContact 存储着要设置的W3C联系人数据
    @param update   YES代表这是保存一个已存在的纪录
    @return         true表示操作成功，false表示操作失败
 */
-(bool) setABRecordFromContactDict:(NSMutableDictionary*)aContact asUpdate:(BOOL)update;

/**
    由ABRecordRef创建一个对应JavaScript层的新的联系人字典对象，
    @param fields 包含要设置到联系人对象中的联系人信息
 */
-(NSDictionary*) toDictionary: (NSDictionary*) fields;

/**
    根据js端传过来的W3C联系人field的名字产生对应的字典类型的field.
    如果field的名字是一个对象就返回这个对象的所有属性（如“name”返回所有ContactName的属性，“address”返回所有ContactAddress的属性）.
    如果field的名字是一个明确的属性就仅仅返回这个属性（如“name.givenName”就返回ContactName中的givenName）.
    如果field中只有["*"]则返回所有field
    @param fieldsArray js端传过来的W3C联系人field
    @return 字典类型的field
 */
+(NSDictionary*) calcReturnFields: (NSArray*)fieldsArray;

/**
    在searchFields中查找指定value的数据
    @param value 要查找的值
    @param searchFields 查找范围
    @return YES表示在searchFields中有值为value的field，反之表示NO
 */
-(BOOL) findValue: (NSString*)value inFields:(NSDictionary*) searchFields;

@end

//ContactField对象
#define kW3ContactFieldType    @"type"
#define kW3ContactFieldValue   @"value"
#define kW3ContactFieldPrimary @"pref"

// ContactField的type属性可能的取值
#define kW3ContactWorkLabel        @"work"
#define kW3ContactHomeLabel        @"home"
#define kW3ContactOtherLabel       @"other"
#define kW3ContactPhoneFaxLabel    @"fax"
#define kW3ContactPhoneMobileLabel @"mobile"
#define kW3ContactPhonePagerLabel  @"pager"
#define kW3ContactUrlBlog          @"blog"
#define kW3ContactUrlProfile       @"profile"
#define kW3ContactImAIMLabel       @"aim"
#define kW3ContactImICQLabel       @"icq"
#define kW3ContactImMSNLabel       @"msn"
#define kW3ContactImYahooLabel     @"yahoo"
#define kW3ContactFieldId          @"id"

// IM字段的属性
#define kW3ContactImType  @"type"
#define kW3ContactImValue @"value"

// Contact对象
#define kW3ContactId               @"id"
#define kW3ContactName             @"name"
#define kW3ContactFormattedName    @"formatted"
#define kW3ContactGivenName        @"givenName"
#define kW3ContactFamilyName       @"familyName"
#define kW3ContactMiddleName       @"middleName"
#define kW3ContactHonorificPrefix  @"honorificPrefix"
#define kW3ContactHonorificSuffix  @"honorificSuffix"
#define kW3ContactDisplayName      @"displayName"
#define kW3ContactNickname         @"nickname"
#define kW3ContactPhoneNumbers     @"phoneNumbers"
#define kW3ContactAddresses        @"addresses"
#define kW3ContactAddressFormatted @"formatted"
#define kW3ContactStreetAddress    @"streetAddress"
#define kW3ContactLocality         @"locality"
#define kW3ContactRegion           @"region"
#define kW3ContactPostalCode       @"postalCode"
#define kW3ContactCountry          @"country"
#define kW3ContactEmails           @"emails"
#define kW3ContactIms              @"ims"
#define kW3ContactOrganizations    @"organizations"
#define kW3ContactOrganizationName @"name"
#define kW3ContactTitle            @"title"
#define kW3ContactDepartment       @"department"
#define kW3ContactBirthday         @"birthday"
#define kW3ContactNote             @"note"
#define kW3ContactPhotos           @"photos"
#define kW3ContactCategories       @"categories"
#define kW3ContactUrls             @"urls"

#endif
