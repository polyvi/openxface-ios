
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
//  NSDictionary+XExtendedDictionary.h
//  xFace
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (XExtendedDictionary)

/**
    判断指定的键值是不是NSNumber类型.
    @param key 键
    @returns 是NSNumber类型返回YES，否则返回NO
 */
- (BOOL) valueForKeyIsNumber:(NSString *)key;

/**
    判断指定的键值是不是NSArray类型.
    @param key 键
    @returns 是NSArray类型返回YES，否则返回NO
 */
- (BOOL) valueForKeyIsArray:(NSString *)key;

/**
    判断指定的键值是不是等于期望值.
    @param expectedValue 期望值
    @param key 键
    @returns 相等返回YES，否则返回NO
 */
- (BOOL) valueForKeyEquals:(NSString*)expectedValue forKey:(NSString*)key;

@end
