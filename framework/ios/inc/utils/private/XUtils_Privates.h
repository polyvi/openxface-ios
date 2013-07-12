
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
//  XUtils_Privates.h
//  xFaceLib
//
//

#import "XUtils.h"

#define KEY_TARGET      @"target"
#define KEY_SELECTOR    @"selector"
#define KEY_OBJECT      @"object"


@interface XUtils ()

/**
 执行Selector.
 @param args 执行Selecotr的target，sel，参数均存放在输入的dictionary中
 */
- (void) performWithArgs:(NSDictionary *)args;

@end
