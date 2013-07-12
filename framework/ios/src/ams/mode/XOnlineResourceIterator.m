
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
//  XOnlineResourceIterator.m
//  xFaceLib
//
//

#import "XOnlineResourceIterator.h"
#import "XOnlineResourceInfo.h"
#import "XSecurityResourceFilterFactory.h"

@implementation XOnlineResourceIterator

- (id)initWithResource:(XOnlineResourceInfo*)info
{
    self = [super init];
    if (self) {
        self->resourceInfo = info;
        self->idEnumerator = self->resourceInfo.index.keyEnumerator;
        self->filter = [XSecurityResourceFilterFactory createFilter];
    }
    return self;
}

- (NSData*)next
{
    NSString* URLId = self->idEnumerator.nextObject;
    if (nil == URLId)
    {
        return nil;
    }

    NSString* path = [self->resourceInfo.index objectForKey:URLId];
    if (filter != nil && ![self->filter accept:path]) {
        return [self next];
    }

    NSString* sqlCommand =[NSString stringWithFormat:@"select * from CacheResourceData where id = \' %@\'", URLId];
    const char *query_stmt = [sqlCommand UTF8String];
    sqlite3_stmt *statement;
    NSData *data;
    if ((sqlite3_prepare_v2(resourceInfo.database, query_stmt, -1, &statement, NULL) == SQLITE_OK) &&
        (sqlite3_step(statement) == SQLITE_ROW))
    {
        data = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 1)
                                      length:sqlite3_column_bytes(statement, 1)];
        sqlite3_finalize(statement);
    }
    return data != nil ? data : [self next];
}

@end
