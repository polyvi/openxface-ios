
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
//  XOnlineResourceInfo.m
//  xFaceLib
//
//

#import "XOnlineResourceInfo.h"

@implementation XOnlineResourceInfo

@synthesize url;

@synthesize path;

@synthesize index;

@synthesize database;

-(id) initWithPath:(NSString*)pathStr URL:(NSString*)appURL
{
    self = [super init];
    if (self) {
        sqlite3_stmt *statement;

        NSString* sqlCommand = [NSString stringWithFormat:@"select * from CacheResources where id in ( select resource from CacheEntries where cache in( select cache from CacheEntries where resource in ( select id from CacheResources where url = \'%@\')))", appURL];
        const char *query_stmt = [sqlCommand UTF8String];
        XLogI(@"the sql is %@", sqlCommand);

        if ((sqlite3_open([pathStr UTF8String], &database) == SQLITE_OK) &&
            (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK))
        {
            self->index = [[NSMutableDictionary alloc] init];
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *key = @((const char*) sqlite3_column_text(statement, 0));
                NSString *resourceUrl = @((const char*) sqlite3_column_text(statement, 1));
                [self->index setObject:resourceUrl forKey:key];
            }
            sqlite3_finalize(statement);
        }

        if ([self->index count] == 0) {
            XLogE(@"failed to access database or no app cache");
            sqlite3_close(database);
            database = NULL;
            return nil;
        }
        self.path = pathStr;
        self.url = appURL;
    }
    return self;
}

- (void)dealloc
{
    if (database != NULL) {
        sqlite3_close(database);
        database = NULL;
    }
}
@end
