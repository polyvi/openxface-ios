
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
//  XLocalResourceIterator.m
//  xFaceLib
//
//

#import "XLocalResourceIterator.h"
#import "XSecurityResourceFilterFactory.h"

@implementation XLocalResourceIterator

- (id)initWithAppRoot:(NSString*)root
{
    self = [super init];
    if (self) {
        rootPath = root;
        dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:rootPath];
        self->filter = [XSecurityResourceFilterFactory createFilter];
    }
    return self;
}

- (NSData*)next
{
    NSString* file = [dirEnumerator nextObject];
    if (file == nil) {
        return nil;
    }
    NSString* path = [rootPath stringByAppendingPathComponent:file];

    BOOL isDir;
    if ((filter != nil && ![self->filter accept:path])
        //跳过目录
       || ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)) {
        return [self next];
    }
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

@end
