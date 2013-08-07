#openxface for iOS

This is iOS port for openxface. 

openxface was inspired by Apache Cordova project and also by our legacy xFace. It offers a flexible hybrid app runtime, app management system, and rich extensions. We're truly appreciated the great work of Apache Cordova.

##Get started with the source
####Requirement
* Xcode 4.3 or higher
* iOS SDK 5.0 or higher
* [Jake](https://github.com/mde/jake) (to build js, better install it globally)
* Python 2.7.x

####Step by Step
1. Clone a local copy
2. Open the xFace player project with Xcode
3. Prepare application (with app.xml)
	* Put application source under **www/xface/apps/app**
4. Execute js.py to generate xface.js
5. Run with your app in the emulator or in the device

####Directory Structure

    ├── framework
	|   ├── ios
	|	|   ├── extlibs
	|	|   ├── inc
	|	|   ├── src
	|	|   └── unittest
	├── project
	|   ├── engine
	|	|   ├── xface
	|	|	|   ├── ios
	|	|	|	|   └── xFacePlayer
	|	|	|   └── js
	├── .gitignore
	├── COPYING
	├── NOTICE
	└── README.md

An overview of the main directories:

| FILE / DIRECTORY         | DESCRIPTION                                             |
| -------------------------| :-------------------------------------------------------|
| framework/ios            | This is where the openxface iOS source code resides.    |
| project/engine/xface/ios/xFacePlayer | Project files for xFacePlayer.              |
| project/engine/xface/js  | These are the JavaScript source codes which will be used to generate xface.js

##Further Reading
* Please visit [openxface](http://polyvi.github.io/openxface)

##License
All source related to Apache Cordova is still following Apache License, Version 2.0, while all others is distributed under the terms of the GNU General Public License.

----

#openxface
openxface是基于xface的开源项目，一个灵活的hybrid app runtime
##如何使用源码
####开发环境
* Xcode 4.3或更高版本
* iOS SDK 5.0或更高版本
* [Jake](https://github.com/mde/jake) (用来生成xface.js，最好安装为全局命令)
* Python 2.7.x

####开发步骤
1. 使用git克隆一份本地代码
2. 用Xcode打开xFace player工程
3. 准备好应用源码
	* 请把应用源码放到 **www/xface/apps/app** 下面
4. 执行js.py生成xface.js
5. 在模拟器或设备上运行

####目录结构

    ├── framework
	|   ├── ios
	|	|   ├── extlibs
	|	|   ├── inc
	|	|   ├── src
	|	|   └── unittest
	├── project
	|   ├── engine
	|	|   ├── xface
	|	|	|   ├── ios
	|	|	|	|   └── xFacePlayer
	|	|	|   └── js
	├── .gitignore
	├── COPYING
	├── NOTICE
	└── README.md

主要目录说明:

| FILE / DIRECTORY                     | DESCRIPTION                         |
| -------------------------            | :-----------------------------------|
| framework/ios                        | 所有 openxface iOS 源码所在目录.       |
| project/engine/xface/ios/xFacePlayer | xFacePlayer 工程文件所在目录.          |
| project/engine/xface/js              | 用于生成 xface.js 的 JavaScript 源码.  |

##更多参考
* 请访问 [openxface](http://polyvi.github.io/openxface)

---

xFace dev team, 2013 Polyvi Inc.

mail to: opensource@polyvi.com
