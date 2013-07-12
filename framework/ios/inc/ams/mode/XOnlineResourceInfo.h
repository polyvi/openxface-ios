
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
//  XOnlineResourceInfo.h
//  xFaceLib
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/**
    XOnlineResourceInfo主要用于记录online模式中app在缓存数据库中的资源的信息,
    遍历资源时, 通过这些信息, 再去查询数据, 可得到资源的数据.
 */

@interface XOnlineResourceInfo : NSObject

/**
    app的url
 */
@property NSString* url;

/**
    缓存数据库的路径
 */
@property NSString* path;

/**
    资源索引信息，通过查询数据库得到
    信息格式形如：
    key = id     value = URL
     1           http://polyvi.com/logo.jpg
     2           http://polyvi.com/xface.js
         ....
 */
@property NSMutableDictionary* index;

/**
    数据库实例，用于查询资源的数据
 */
@property sqlite3* database;

/**
   初始化函数
   @param path    缓存路径
   @param appURL  app的入口地址，作为app在缓存数据库中的唯一标识符
   @returns 返回XOnlineResourceInfo对象实例
 */
- (id)initWithPath:(NSString*)path URL:(NSString*)appURL;

@end
