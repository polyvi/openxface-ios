
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
//  NSDictionary+XExtendedDictionary.m
//  xFace
//
//

#import "XExtendedDictionary.h"

@implementation NSDictionary (XExtendedDictionary)

- (BOOL) valueForKeyIsNumber:(NSString *)key
{
    NSObject* value = [self objectForKey: key];
    return [value isKindOfClass: [NSNumber class]];
}

- (BOOL) valueForKeyIsArray:(NSString *)key
{
    NSObject* value = [self objectForKey: key];
    return [value isKindOfClass: [NSArray class]];
}

- (BOOL) valueForKeyEquals:(NSString*)expectedValue forKey:(NSString*)key
{
    id value = [self valueForKey:key];
    BOOL exists = NO;
    if(value)
    {
        exists = ([(NSString*)value compare:expectedValue options:NSCaseInsensitiveSearch] == 0);
    }
    return exists;
}

@end
