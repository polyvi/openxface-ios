
/*
 Copyright 2012-2013, Polyvi Inc. (http://www.xface3.com)
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


/**
 * ui模块提供系统原生控件，方便应用直接使用
 * @module ui
 */
var argscheck = require('xFace/argscheck'),
    exec = require('xFace/exec');

/**
 * 此类提供系统原生calendar控件支持.此类不能通过new来创建相应的对象,只能通过xFace.ui.Calendar
 * 对象来直接使用该类中定义的方法(Android,iOS,WP8)
 * @class Calendar
 * @static
 * @platform Android, iOS, WP8
 * @since 3.0.0
 */
function Calendar() {}

/**定义时间的一些常量*/
var MAX_YEARS    = 2100;
var MAX_MONTHS   = 12;
var MAX_DAYS     = 31;
var MAX_HOURS    = 23;
var MAX_MINUTES  = 59;
var MIN_YEARS    = 1900;
var MIN_MONTHS   = 1;
var MIN_DAYS     = 1;
var MIN_HOURS    = 0;
var MIN_MINUTES  = 0;

/**
 * 打开原生时间控件.可以指定控件显示的初始时间,如果用户不传入初始时间，则默认为当前系统时间.(Android,iOS,WP8)
 * 注意：初始时间要么不传，要么全传，否则会报错。
 * @example
        //通过Calendar控件获取用户选取的时间
        function getTime(){
            xFace.ui.Calendar.getTime(
                function(res){
                    alert(res.hour);
                    alert(res.minute);
                },
                function(){alert(" Calendar fail!");}
                );
        }
 * @method getTime
 * @param {Function} successCallback   成功的回调函数，返回用户设置的时间.
 * @param {Object}  successCallback.obj  回调函数的参数为一个带有hour,minute属性的Object对象
 * @param {Function} [errorCallback]     失败的回调函数
 * @param {Number} [hours]   初始小时值(iOS,WP8上不支持传参初始化Calendar控件,默认显示系统当前的时间)
 * @param {Number} [minutes] 初始分钟值(iOS,WP8上不支持传参初始化,不需要该参数）
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Calendar.prototype.getTime = function(successCallback, errorCallback, hours, minutes) {
    argscheck.checkArgs('fFNN', 'Calendar.getTime', arguments);
    if(arguments.length == 3){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback("The parameter length is invalid! ");
            return;
        }
    }
    var checkTime = function(hour, minute) {
        if((hour < MIN_HOURS) || (minute < MIN_MINUTES) ||
            (hour > MAX_HOURS) || (minute > MAX_MINUTES)){
            return false;
        }
        //实例一个Date对象
        var d = new Date();
        d.setHours(hour);
        d.setMinutes(minute);
        return (d.getHours() == hour &&
        d.getMinutes() == minute);
    };
    var newArguments = [];
    if(arguments.length == 4) {
        if(!checkTime(hours, minutes)){
            if(errorCallback && typeof errorCallback == "function") {
                errorCallback("The parameter value is invalid! ");
                return;
            }
        } else {
            newArguments = [hours, minutes];
        }
    }
    exec(successCallback, errorCallback, null, "Calendar", "getTime", newArguments);
}

/**
 * 打开原生日期控件。可以指定控件显示的初始日期,如果用户不传入初始日期，则默认为当前系统日期.(Android,iOS,WP8)
 * 注意：初始日期要么不传，要么全传，否则会报错。
 * @example
        //通过Calendar控件获取用户选取的日期
        function getDate(){
            xFace.ui.Calendar.getDate(
                function(res){
                    alert(res.year);
                    alert(res.month);
                    alert(res.day);
                },
                function(){alert(" Calendar fail!");}
                    2012,09,10 );
        }

 * @method getDate
 * @param {Function} successCallback   成功回调函数，返回用户设置的日期.
 * @param {Object}  successCallback.obj  回调函数的参数为一个带有year,month,day属性的Object对象
 * @param {Function} [errorCallback]      失败回调函数
 * @param {Number} [year]    初始年值(iOS,WP8上不支持传参初始化Calendar控件,默认显示系统当前的日期)
 * @param {Number} [month]   初始月份值(iOS,WP8上不支持传参初始化,不需要该参数)
 * @param {Number} [day]     初始日值(iOS,WP8上不支持传参初始化,不需要该参数)
 * @platform Android,iOS,WP8
 * @since 3.0.0
 */
Calendar.prototype.getDate = function(successCallback, errorCallback, year, month, day) {
    argscheck.checkArgs('fFNNN', 'Calendar.getDate', arguments);
    if(arguments.length != 5 && arguments.length != 2 && arguments.length != 1){
        if(errorCallback && typeof errorCallback == "function") {
            errorCallback("The parameter length is invalid! ");
            return;
        }
    }
    var checkDate = function(years, months, days) {
        if((years < MIN_YEARS) || (months < MIN_MONTHS) || (days < MIN_DAYS) ||
            (years > MAX_YEARS) || (months > MAX_MONTHS) || (days > MAX_DAYS) ){
            return false;
        }
        //实例一个Date对象并初始化各个属性值，注意月份是从0开始，因此减1
        var d = new Date(years, months-1, days);
        //判断输入时期是否合法 ，同样月份需要加1
        return (d.getFullYear() == years
           && d.getMonth()+1 == months
           && d.getDate()== days);
    };
    var newArguments = [];
    if(arguments.length == 5) {
        if(!checkDate(year,month,day)){
            if(errorCallback && typeof errorCallback == "function") {
                errorCallback("The parameter value is invalid! ");
                return;
            }
        } else {
            newArguments = [year, month, day];
        }
    }

    exec(successCallback, errorCallback, null, "Calendar", "getDate",newArguments);
}

module.exports = new Calendar();
