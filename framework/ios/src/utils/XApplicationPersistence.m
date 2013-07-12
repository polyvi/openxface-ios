
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
//  XApplicationPersistence.m
//  xFace
//
//

#import "XApplicationPersistence.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "APXML.h"
#import "XAPElement.h"
#import "XAppList.h"
#import "XUtils.h"
#import "XUtils+Additions.h"
#import "XApplication.h"
#import "APDocument+XAPDocument.h"
#import "XAppXMLParser.h"
#import "XAppXMLParserFactory.h"
#import "XApplicationPersistence_Privates.h"
#import "XFileOperatorFactory.h"
#import "XFileOperator.h"
#import "XApplicationFactory.h"
#import "XAppInfo.h"

#define TAG_APPLICATIONS               @"applications"
#define TAG_APP                        @"app"

#define ATTR_DEFAULT_APP_ID            @"defaultAppId"
#define ATTR_ID                        @"id"
#define ATTR_SOURCE_ROOT               @"srcRoot"

@implementation XApplicationPersistence

- (id) init
{
    self = [super init];
    if (self)
    {
        self->userAppsFileOperator = [XFileOperatorFactory create];

        NSString *appsFilePath = [[XConfiguration getInstance] userAppsFilePath];
        self->document = [self->userAppsFileOperator readAsDocFromFile:appsFilePath];
        NSAssert(self->document, @"Error:Failed to init XApplicationPersistence, please verify that 'userApps.xml' exists!");
    }
    return self;
}

- (BOOL) readAppsFromConfig:(XAppList *)appList
{
    BOOL ret = NO;

    NSString *defaultAppId = [self getDefaultAppId];
    [appList markAsDefaultApp:defaultAppId];

    NSMutableDictionary *appDict = [self getAppsDict];
    for (NSString *appId in [appDict allKeys])
    {
        NSString *appConfigFilePath = [XUtils buildConfigFilePathWithAppId:appId];
        XAppInfo *appInfo = [XUtils getAppInfoFromConfigFileAtPath:appConfigFilePath];
        if (!appInfo)
        {
            ret = NO;
            break;
        }
        [appInfo setSrcRoot:CAST_TO_NIL_IF_NSNULL([appDict objectForKey:appId])];
        id<XApplication> app = [XApplicationFactory create:appInfo];
        [appList add:app];
        ret = YES;
    }
    return ret;
}

- (void) addAppToConfig:(id<XApplication>) app
{
    /* 调整后的文件内容形如：
        <applications>
            <app id="appId" source_dir="<Application_Home>/Documents/xface3/apps/appId/" />
        </applications>
     */
    NSString *appId = [app getAppId];
    NSAssert(([appId length] > 0), nil);

    NSString *srcRoot = [[app appInfo] srcRoot];
    NSAssert(([srcRoot length] > 0), nil);

    APElement *rootElem = [self->document rootElement];
    APElement *applicationsElem = [rootElem firstChildElementNamed:TAG_APPLICATIONS];
    if(nil == applicationsElem)
    {
        applicationsElem = [APElement elementWithName:TAG_APPLICATIONS];
        NSAssert(nil != applicationsElem, nil);
        [applicationsElem setParent:rootElem];
        [rootElem addChild:applicationsElem];
    }

    NSAssert(nil == [applicationsElem firstChildElementNamed:TAG_APP withAttribute:[APAttribute attributeWithName:ATTR_ID value:appId]], @"Should not add app element with duplicate app id!");

    APElement *appElem = [APElement elementWithName:TAG_APP];
    NSAssert(nil != appElem, nil);

    [appElem addAttributeNamed:ATTR_ID withValue:appId];
    [appElem addAttributeNamed:ATTR_SOURCE_ROOT withValue:srcRoot];
    [appElem setParent:applicationsElem];
    [applicationsElem addChild:appElem];

    [self->userAppsFileOperator saveDoc:self->document toFile:[[XConfiguration getInstance] userAppsFilePath]];
    return;
}

- (void) updateAppToConfig:(id<XApplication>) app
{
    /* 调整前文件内容形如：
         <applications>
             <app id="appId" source_dir="<Application_Home>/Documents/xface3/apps/appId/" />
         </applications>
       调整后文件内容形如：
         <applications>
             <app id="appId" source_dir="<Application_Home>/xFace.app/www/preinstalledApps/appSrcDirName/" />
         </applications>
     */
    NSString *appId = [app getAppId];
    NSAssert(([appId length] > 0), nil);

    NSString *srcRoot = [[app appInfo] srcRoot];
    NSAssert(([srcRoot length] > 0), nil);

    APElement *rootElem = [self->document rootElement];
    APElement *applicationsElem = [rootElem firstChildElementNamed:TAG_APPLICATIONS];
    NSAssert(applicationsElem, nil);

    APElement *appElem = [applicationsElem firstChildElementNamed:TAG_APP withAttribute:[APAttribute attributeWithName:ATTR_ID value:appId]];
    NSAssert(nil != appElem, nil);

    [appElem addAttributeNamed:ATTR_SOURCE_ROOT withValue:srcRoot];

    [self->userAppsFileOperator saveDoc:self->document toFile:[[XConfiguration getInstance] userAppsFilePath]];
    return;
}

- (void) removeAppFromConfig:(NSString *)appId
{
    NSAssert(([appId length] > 0), nil);
    APElement *rootElem = [self->document rootElement];
    APElement *applicationsElem = [rootElem firstChildElementNamed:TAG_APPLICATIONS];
    APElement *appElem = [applicationsElem firstChildElementNamed:TAG_APP withAttribute:[APAttribute attributeWithName:ATTR_ID value:appId]];

    if (appElem)
    {
        [[appElem parent] removeChild:appElem];
        [self->userAppsFileOperator saveDoc:self->document toFile:[[XConfiguration getInstance] userAppsFilePath]];
    }
    return;
}

- (void) markAsDefaultApp:(NSString *)appId
{
    /* 调整后的文件内容形如:
        <applications defaultAppId="appId">
        </applications>
    */
    NSAssert(([appId length] > 0), nil);
    APElement *rootElem = [self->document rootElement];
    APElement *applicationsElem = [rootElem firstChildElementNamed:TAG_APPLICATIONS];
    NSAssert(nil != applicationsElem, nil);

    [applicationsElem addAttributeNamed:ATTR_DEFAULT_APP_ID withValue:appId];
    [self->userAppsFileOperator saveDoc:self->document toFile:[[XConfiguration getInstance] userAppsFilePath]];
    return;
}

#pragma mark private methods

- (NSString *)getDefaultAppId
{
    APElement *rootElem = [self->document rootElement];
    APElement *applicationsElem = [rootElem firstChildElementNamed:TAG_APPLICATIONS];
    NSString *defaultAppId = [applicationsElem valueForAttributeNamed:ATTR_DEFAULT_APP_ID];
    return defaultAppId;
}

- (NSMutableDictionary *)getAppsDict
{
    APElement *rootElem = [self->document rootElement];
    APElement *applicationsElem = [rootElem firstChildElementNamed:TAG_APPLICATIONS];
    NSMutableArray *appElems = [applicationsElem childElements:TAG_APP];

    // 没有找到applications或者app节点
    if (!applicationsElem || (0 == [appElems count]))
    {
        return nil;
    }

    NSMutableDictionary *appDict = [[NSMutableDictionary alloc] init];
    for (APElement *appElem in appElems)
    {
        // 以appId为key,srcRoot为value
        NSString *appId = [appElem valueForAttributeNamed:ATTR_ID];
        NSAssert(([appId length] > 0), nil);

        NSString *srcRoot = [appElem valueForAttributeNamed:ATTR_SOURCE_ROOT];
        [appDict setObject:CAST_TO_NSNULL_IF_NIL(srcRoot) forKey:appId];
    }
    return appDict;
}

@end
