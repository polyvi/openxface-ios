
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
//  XConstantsLogicTests.h
//  xFace
//
//

#define XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_STR               @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\
                                                                    <config>\n\
                                                                        <pre_install_packages>\n\
                                                                            <app_package>app.zip</app_package>\n\
                                                                            <app_package>app1.zip</app_package>\n\
                                                                        </pre_install_packages>\n\
                                                                        <extensions>\n\
                                                                            <extension name=\"File\" />\n\
                                                                        </extensions>\n\
                                                                    </config>"

#define XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_NO_EXTS_STR       @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\
                                                                    <config>\n\
                                                                        <pre_install_packages>\n\
                                                                            <app_package>app.zip</app_package>\n\
                                                                            <app_package>app1.zip</app_package>\n\
                                                                        </pre_install_packages>\n\
                                                                    </config>"

#define XCONSTANTS_LOGIC_TESTS_ORIGINAL_SYSTEM_CONFIG_FILE_STR      @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\
                                                                    <config>\n\
                                                                        <pre_install_packages>\n\
                                                                            <app_package>app.zip</app_package>\n\
                                                                            <app_package>app1.zip</app_package>\n\
                                                                        </pre_install_packages>\n\
                                                                        <extensions>\n\
                                                                            <extension name=\"File\" />\n\
                                                                        </extensions>\n\
                                                                        <applications defaultAppId=\"3\">\n\
                                                                            <app id=\"3\" />\n\
                                                                            <app id=\"4\" />\n\
                                                                        </applications>\n\
                                                                    </config>"
#define XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_WITH_APP_ID_STR   @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\
                                                                    <config>\n\
                                                                        <pre_install_packages>\n\
                                                                            <app_package id=\"appId1\">appSrcDirName1</app_package>\n\
                                                                            <app_package id=\"appId2\">appSrcDirName2</app_package>\n\
                                                                        </pre_install_packages>\n\
                                                                        <extensions>\n\
                                                                            <extension name=\"File\" />\n\
                                                                        </extensions>\n\
                                                                        <applications defaultAppId=\"3\">\n\
                                                                            <app id=\"3\" />\n\
                                                                            <app id=\"4\" />\n\
                                                                        </applications>\n\
                                                                    </config>"
#define XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_WITH_DEFAULT_EXTS_STR \
@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\
<config>\n\
    <pre_install_packages>\n\
        <app_package>app.zip</app_package>\n\
        <app_package>app1.zip</app_package>\n\
    </pre_install_packages>\n\
    <extensions>\n\
        <extension name=\"File\" />\n\
        <extension name=\"NetworkConnection\" />\n\
        <extension name=\"Console\" />\n\
    </extensions>\n\
</config>"

#define XCONSTANTS_LOGIC_TESTS_DOWNLOAD_INFO_CONFIG_FILE_STR      @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n\
                                                                    <download_info>\n\
                                                                        <url id=\"testId1\" totalSize=\"10000\" />\n\
                                                                        <url id=\"testId2\" totalSize=\"20000\" />\n\
                                                                    </download_info>"

#define XCONSTANTS_LOGIC_TESTS_TEMP_CONFIG_FILE_NAME               @"tempConfig.xml"

#define INVALID_CALLBACK_ID                                        @"INVALID"
