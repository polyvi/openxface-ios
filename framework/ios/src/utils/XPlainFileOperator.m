
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
//  XPlainFileOperator.m
//  xFace
//
//

#import "XPlainFileOperator.h"
#import "APDocument.h"
#import "XUtils.h"

@implementation XPlainFileOperator

- (APDocument*)readAsDocFromFile:(NSString *)anFilePath;
{
    NSData* xmlData = [self readAsDataFromFile:anFilePath];
    NSString *xmlStr = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    return [APDocument documentWithXMLString:xmlStr];
}

- (NSData*)readAsDataFromFile:(NSString *)anFilePath;
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    return [fileMgr contentsAtPath:anFilePath];
}

- (BOOL) saveDoc:(APDocument *)doc toFile:(NSString *)anFilePath;
{
    return [XUtils saveDoc:doc toFile:anFilePath];
}

- (BOOL) saveData:(NSData*)data toFile:(NSString *)filePath
{
    return [data writeToFile:filePath atomically:YES];
}

- (BOOL) saveString:(NSString*)string toFile:(NSString *)filePath;
{
    return [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
