
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
//  XCalendarExt_Privates.h
//  xFaceLib
//
//

#ifdef __XCalendarExt__

#import <Foundation/Foundation.h>
#import "XCalendarExt.h"

@interface XCalendarExt ()
{
    UIView *datePickerView;
    UIActionSheet *action;
    UIDatePicker *datePicker;
    XJsCallback *callback;
}

@property (strong) UIPopoverController* popoverController;

/**
    创建DatePickerView.
 */
- (void) createDatePickerView;

/**
    显示DatePickerView.
 */
- (void) showDatePikcer;

/**
    获取Date的各组成部分,year,month,day等.
    @param date 被分解的date对象
    @return 返回一个year,month,day等组成的NSDictionary对象
 */
-(NSDictionary*) getDateComponentsFrom:(NSDate*)date;

@end

#endif
