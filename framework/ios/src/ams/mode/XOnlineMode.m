
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
//  XOnlineMode.m
//  xFaceLib
//
//

#import "XOnlineMode.h"
#import <sqlite3.h>
#import "XOnlineResourceInfo.h"
#import "XOnlineResourceIterator.h"
#import "XOnlineMode_Privates.h"
#import "XUtils.h"

@implementation XOnlineMode

- (id)initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self)
    {
        NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* cacheFolder = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString* bundleId = [bundle bundleIdentifier];
        cacheFolder = [cacheFolder stringByAppendingPathComponent:bundleId];

        self->databasePath = [cacheFolder stringByAppendingPathComponent:@"ApplicationCache.db"];
        self.mode = ONLINE;
        XLogI(@"the database path is %@", databasePath);
    }
    return self;
}

- (id<XResourceIterator>)getResourceIterator:(id<XApplication>)app
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:self->databasePath])
    {
        return nil;
    }

    XOnlineResourceInfo* resources = [[XOnlineResourceInfo alloc] initWithPath:self->databasePath
                                                                           URL:[[app appInfo] entry]];
    return resources ? [[XOnlineResourceIterator alloc] initWithResource:resources] : nil;
}

- (void)loadApp:(id<XApplication>)app policy:(id<XSecurityPolicy>)policy
{
    if(NO == [policy checkAppStart:app])
    {
        [self clearCache:app];
    }
    [super loadApp:app policy:policy];
}

- (NSURL*)getURL:(id<XApplication>)app
{
    return [NSURL URLWithString:[[app appInfo] entry]];
}

- (NSString*)getIconURL:(XAppInfo*)appInfo
{
    NSString* relativeIconPath = [appInfo icon];
    if (0 == [relativeIconPath length])
    {
        return nil;
    }

    NSString* appId = appInfo.appId;
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:appId relativeIconPath:relativeIconPath];

    NSString *iconURL = (nil == iconPath) ? nil : [[NSURL fileURLWithPath:iconPath] absoluteString];
    return iconURL;
}


#pragma mark private methods

#pragma mark clearCache

/**
    Clears the cached resources associated to a cache group.
 */
- (void)clearCache:(id<XApplication>)app
{
    sqlite3 *newDBconnection;

    /*Check that the db is created, if not we return as sqlite3_open would create
     an empty database and webkit will crash on us when accessing this empty database*/
    if (![[NSFileManager defaultManager] fileExistsAtPath:self->databasePath])
    {
        XLogE(@"The cache manifest db has not been created by Webkit yet");
        return;
    }

    if (sqlite3_open([self->databasePath  UTF8String], &newDBconnection) == SQLITE_OK)
    {
        if (sqlite3_exec(newDBconnection, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0) == SQLITE_OK)
        {
            /*Get the cache group IDs associated to the cache manifests' URLs*/
            NSArray *cacheGroupIds = [self getCacheGroupIdForURLsIn:@[[[app appInfo] entry]] usingDBConnection:newDBconnection];
            /*Remove the corresponding entries in the Caches and CacheGroups tables*/
            [self deleteCacheResourcesInCacheGroups:cacheGroupIds usingDBConnection:newDBconnection];
            [self deleteCacheGroups:cacheGroupIds usingDBConnection:newDBconnection];
            if (sqlite3_exec(newDBconnection, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
            {
                XLogE(@"SQL Error: %s", sqlite3_errmsg(newDBconnection));
            }
        }
        else
        {
            XLogE(@"SQL Error: %s", sqlite3_errmsg(newDBconnection));
        }
        sqlite3_close(newDBconnection);
    }
    else
    {
        XLogE(@"Error opening the database located at: %@", self->databasePath);
        newDBconnection = NULL;
    }
}

/**
    Get the Cache group IDs associated to cache manifests URLs

    @param urls The URLs of the cache manifests.
    @param db The connection to the database.
 */
- (NSArray *)getCacheGroupIdForURLsIn:(NSArray *)urls usingDBConnection:(sqlite3 *)db
{
    NSString* queryString = [NSString stringWithFormat:@"%@%@ )", @"select cache from CacheEntries where resource in ( select id from CacheResources where url = ", [self commaSeparatedValuesFromArray:urls]];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    sqlite3_stmt    *statement;
    const char *query = [queryString UTF8String];

    if (sqlite3_prepare_v2(db, query, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int id = sqlite3_column_int(statement, 0);
            [result addObject:[NSNumber numberWithInt:id]];
        }
    }
    else
    {
        XLogE(@"SQL Error: %s",sqlite3_errmsg(db));
    }
    sqlite3_finalize(statement);
    return result;
}

/**
    Delete the rows in the CacheGroups table associated to the cache groups we want to delete.

    @param cacheGroupIds An array of `NSNumbers` corresponding to the cache groups you want cleared.
    @param db The connection to the database.
 */
- (void)deleteCacheGroups:(NSArray *)cacheGroupsIds usingDBConnection:(sqlite3 *)db
{
    sqlite3_stmt    *statement;
    NSString *queryString = [NSString stringWithFormat:@"DELETE FROM CacheGroups WHERE id IN (%@)", [self commaSeparatedValuesFromArray:cacheGroupsIds]];
    const char *query = [queryString UTF8String];
    if (sqlite3_prepare_v2(db, query, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_step(statement);
    }
    else
    {
        XLogE(@"SQL Error: %s",sqlite3_errmsg(db));
    }
    sqlite3_finalize(statement);
}

/**
    Delete the rows in the Caches table associated to the cache groups we want to delete.
    Deleting a row in the Caches table triggers a cascade delete in all the linked tables, most importantly
    it deletes the cached data associated to the cache group.

    @param cacheGroupIds An array of `NSNumbers` corresponding to the cache groups you want cleared.
    @param db The connection to the database
 */
- (void)deleteCacheResourcesInCacheGroups:(NSArray *)cacheGroupsIds usingDBConnection:(sqlite3 *)db {
    sqlite3_stmt    *statement;
    NSString *queryString = [NSString stringWithFormat:@"DELETE FROM Caches WHERE cacheGroup IN (%@)", [self commaSeparatedValuesFromArray:cacheGroupsIds]];
    const char *query = [queryString UTF8String];
    if (sqlite3_prepare_v2(db, query, -1, &statement, NULL) == SQLITE_OK)
    {
        sqlite3_step(statement);
    }
    else
    {
        XLogE(@"SQL Error: %s",sqlite3_errmsg(db));
    }
    sqlite3_finalize(statement);
}

/**
    Helper to transform an `NSArray` in a comma separated string we can use in our queries.

    @return The comma separated string
 */
- (NSString *)commaSeparatedValuesFromArray:(NSArray *)valuesArray
{
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    [valuesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[NSNumber class]])
        {
            [result appendFormat:@"%d", [(NSNumber *)obj intValue]];
        }
        else
        {
            [result appendFormat:@"'%@'", obj];
        }
        if (idx != valuesArray.count - 1)
        {
            [result appendString:@", "];
        }
    }];
    return result;
}

@end
