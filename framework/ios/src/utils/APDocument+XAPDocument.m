
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
//  APDocument+XAPDocument.m
//  xFace
//
//

#import "APDocument+XAPDocument.h"

@implementation APDocument (XAPDocument)

+ (id)documentWithFilePath:(NSString *)anFilePath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:anFilePath])
    {
        return nil;
    }

    NSData *xmlData = [fileMgr contentsAtPath:anFilePath];
    NSString *xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    return [APDocument documentWithXMLString:xmlStr];
}

+ (id)documentWithData:(NSData *)xmlData
{
    if(nil == xmlData)
    {
        return nil;
    }
    NSString *xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    return [APDocument documentWithXMLString:xmlStr];
}

- (NSData*) prettyXMLData
{
    NSString *xmlStr = [self prettyXML];
    return [xmlStr dataUsingEncoding:NSUTF8StringEncoding];
}
@end
