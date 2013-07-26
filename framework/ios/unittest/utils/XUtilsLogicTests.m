
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
//  XUtilsLogicTests.m
//  xFace
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "XUtils.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "APXML.h"
#import "APDocument+XAPDocument.h"
#import "XConstantsLogicTests.h"
#import "XAppInfo.h"
#import "XApplication.h"
#import "XAmsExt.h"
#import "XAmsImpl.h"
#import "XUtils_Privates.h"
#import "XLogicTests.h"
#import "XFileOperator.h"
#import "XFileOperatorFactory.h"
#import "XApplicationFactory.h"
#import "XPlainFileOperator.h"

#define XUTILS_LOGIC_TESTS_APP_ID                               @"appId"
#define XUTILS_LOGIC_TESTS_APP_PACKAGE_APP_ID                   @"testAppId"
#define XUTILS_LOGIC_TESTS_APP_VERSION                          @"2.0.20801"
#define XUTILS_LOGIC_TESTS_APP_NAME                             @"日期控件"
#define XUTILS_LOGIC_TESTS_APP_ENTRY                            @"index.html"
#define XUTILS_LOGIC_TESTS_APP_ICON                             @"//image/icon.png"
#define XUTILS_LOGIC_TESTS_APP_TYPE                             @"xapp"
#define XUTILS_LOGIC_TESTS_APP_ALLOW_EXT_NAME1                  @"Calendar"
#define XUTILS_LOGIC_TESTS_APP_ALLOW_EXT_NAME2                  @"AMS"

#define XUTILS_LOGIC_TESTS_INVALID_PACKAGE_PATH                 @"invalid package path"
#define XUTILS_LOGIC_TESTS_APP_CONFIG_FILE_NAME                 @"app.xml"
#define XUTILS_LOGIC_TESTS_APP_ENTRY_FILE_NAME                  @"index.html"
#define XUTILS_LOGIC_TESTS_INVALID_FILE_NAME                    @"invalid file name"
#define XUTILS_LOGIC_TESTS_APP_PACKAGE_FILE_NAME                @"app.zip"
#define UTILS_LOGIC_TESTS_APP_PACKAGE_FOLDER                    @"www"

// 对应于系统配置文件中的tag name与attribute name
#define XUTILS_LOGIC_TESTS_TAG_PRE_INSTALL_PACKAGES             @"pre_install_packages"
#define XUTILS_LOGIC_TESTS_TAG_APP_PACKAGE                      @"app_package"
#define XUTILS_LOGIC_TESTS_TAG_EXTENSIONS                       @"extensions"
#define XUTILS_LOGIC_TESTS_TAG_EXTENSION                        @"extension"
#define XUTILS_LOGIC_TESTS_TAG_APPLICATIONS                     @"applications"

#define XUTILS_LOGIC_TESTS_ATTR_NAME                            @"name"

#define XUTILS_LOGIC_CONFIG_KEY01                               @"key01"
#define XUTILS_LOGIC_CONFIG_VALUE01                             @"value01"
#define XUTILS_LOGIC_CONFIG_KEYNOTEXIST                         @"keyNotExist"

@interface MockClassForXUtilTest : NSObject

- (void) foo:(NSNumber*)arg;

@end

@implementation MockClassForXUtilTest

- (void) foo:(NSNumber*)arg
{
    [arg intValue];
    NSAssert(NO == [[NSThread currentThread] isMainThread], nil);
}

@end

@interface XMockXMLParserDelegateForXUtilsTest : NSObject <NSXMLParserDelegate>
{
    NSString             *currentElementName;
    NSString             *currentAppPackageName;
    BOOL                 shouldStoreAppPackageName;
}

@property (strong, nonatomic, readonly) NSMutableArray *prepackedApps;

@property (strong, nonatomic, readonly) NSMutableSet *systemAllowedExtensions;

@property (nonatomic) BOOL isParseErrorOccured;

@end

@implementation XMockXMLParserDelegateForXUtilsTest

@synthesize prepackedApps;
@synthesize systemAllowedExtensions;
@synthesize isParseErrorOccured;

#pragma mark NSXMLParser Parsing Callbacks

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self->currentElementName = elementName;
    if ([self->currentElementName isEqualToString:XUTILS_LOGIC_TESTS_TAG_PRE_INSTALL_PACKAGES])
    {
        self->prepackedApps = [[NSMutableArray alloc] init];
    }
    else if ([self->currentElementName isEqualToString:XUTILS_LOGIC_TESTS_TAG_EXTENSIONS])
    {
        self->systemAllowedExtensions = [[NSMutableSet alloc] init];
    }
    else if ([self->currentElementName isEqualToString:XUTILS_LOGIC_TESTS_TAG_EXTENSION])
    {
        NSAssert((nil != [self systemAllowedExtensions]), nil);
        [self->systemAllowedExtensions addObject:[attributeDict objectForKey:XUTILS_LOGIC_TESTS_ATTR_NAME]];
    }
    self->shouldStoreAppPackageName = YES;
    return;
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:XUTILS_LOGIC_TESTS_TAG_APP_PACKAGE])
    {
        NSAssert((nil != self->prepackedApps), nil);
        NSAssert((nil != self->currentAppPackageName), nil);
        [self->prepackedApps addObject:self->currentAppPackageName];
    }
    self->shouldStoreAppPackageName = NO;
    return;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self->currentElementName isEqualToString:XUTILS_LOGIC_TESTS_TAG_APP_PACKAGE])
    {
        if (self->shouldStoreAppPackageName)
        {
            self->currentAppPackageName = string;
        }
    }
    return;
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Parse Error:%@", [parseError localizedDescription]);
    self->isParseErrorOccured = YES;
}

@end

@interface XUtilsLogicTests : XLogicTests
{
@private
    NSString *configFilePath;
    NSString *plainConfigFilePath;
    NSString *appPackageFilePath;
    NSString *appInstalledPath;
    id<XFileOperator> fileOperator;
}

@end

@implementation XUtilsLogicTests

- (void)setUp
{
    [super setUp];

    NSLog(@"%@ setUp", self.name);

    XConfiguration *config = [XConfiguration getInstance];
    self->configFilePath = [[config systemWorkspace] stringByAppendingString:SYSTEM_CONFIG_FILE_NAME];
    STAssertTrue(([self->configFilePath length] > 0), nil);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    STAssertFalseNoThrow([fileManager fileExistsAtPath:self->configFilePath], nil);
    
    __autoreleasing NSError *error;
    BOOL ret = [XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_WITH_DEFAULT_EXTS_STR writeToFile:self->configFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(!ret)
    {
        NSLog(@"Failed to write content to system config: %@ and error is: %@!", self->configFilePath, [error localizedDescription]);
    }
    STAssertTrue(ret, nil);

    //准备明文的config文件
    NSString *workspace = [config systemWorkspace];
    self->plainConfigFilePath = [workspace stringByAppendingString:@"plainConfig.xml"];
    STAssertTrue([XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_NO_EXTS_STR writeToFile:plainConfigFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil], @"fail to write plainConfig.xml");

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self->appPackageFilePath = [bundle pathForResource:XUTILS_LOGIC_TESTS_APP_PACKAGE_FILE_NAME ofType:nil inDirectory:UTILS_LOGIC_TESTS_APP_PACKAGE_FOLDER];
    STAssertTrueNoThrow(([self->appPackageFilePath length] > 0), nil);

    self->appInstalledPath = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingFormat:@"%@%@", XUTILS_LOGIC_TESTS_APP_PACKAGE_APP_ID, FILE_SEPARATOR];
    STAssertTrueNoThrow(([self->appInstalledPath length] > 0), nil);

    fileOperator = [[XPlainFileOperator alloc] init];
    STAssertNotNil(fileOperator, @"fail to create XSystemConfigFileOperator");
}

-(void) tearDown
{
    [super tearDown];
    [[NSFileManager defaultManager] removeItemAtPath:self->plainConfigFilePath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:self->configFilePath error:nil];
}

- (void)testGenerateRandomId
{
    NSInteger generatedId = [XUtils generateRandomId];
    NSInteger anotherGeneratedId = [XUtils generateRandomId];

    BOOL isDifferent = (generatedId != anotherGeneratedId);
    STAssertTrue(isDifferent, @"got two identical ids");
}

- (void)testUnpackPackageAtPathWithFalseResult
{
    STAssertFalseNoThrow([XUtils unpackPackageAtPath:nil toPath:nil], nil);
    STAssertFalseNoThrow([XUtils unpackPackageAtPath:XUTILS_LOGIC_TESTS_INVALID_PACKAGE_PATH toPath:nil], nil);
    STAssertFalseNoThrow([XUtils unpackPackageAtPath:self->appPackageFilePath toPath:nil], nil);
    STAssertFalseNoThrow([XUtils unpackPackageAtPath:nil toPath:self->appInstalledPath], nil);
    STAssertFalseNoThrow([XUtils unpackPackageAtPath:XUTILS_LOGIC_TESTS_INVALID_PACKAGE_PATH toPath:self->appInstalledPath], nil);
}

- (void)testUnpackPackageAtPathWithTrueResult
{
    // 测试前检查
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL ret = [fileMgr fileExistsAtPath:self->appInstalledPath];
    STAssertFalse(ret, nil);

    STAssertTrueNoThrow([XUtils unpackPackageAtPath:self->appPackageFilePath toPath:self->appInstalledPath], nil);

    // 测试后检查
    ret = [fileMgr fileExistsAtPath:self->appInstalledPath];
    STAssertTrue(ret, nil);
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:self->appInstalledPath error:nil];
    STAssertTrue((0 < [files count]), nil);

    // 清理测试环境
    [fileMgr removeItemAtPath:self->appInstalledPath error:nil];
}

- (void)testParseXMLFileWithNilArgs
{
    STAssertFalseNoThrow([XUtils parseXMLFileAtPath:nil withDelegate:nil], nil);
}

- (void)testParseXMLFileWithNilDelegate
{
    STAssertTrueNoThrow([XUtils parseXMLFileAtPath:self->plainConfigFilePath withDelegate:nil], nil);
}

- (void)testParseXMLFileWithNilFilePath
{
    XMockXMLParserDelegateForXUtilsTest *mockDelegate = [[XMockXMLParserDelegateForXUtilsTest alloc] init];
    STAssertNotNil(mockDelegate, nil);

    // 测试前检查
    STAssertNil([mockDelegate systemAllowedExtensions], nil);
    STAssertNil([mockDelegate prepackedApps], nil);

    STAssertFalseNoThrow([XUtils parseXMLFileAtPath:nil withDelegate:mockDelegate], nil);

    // 测试后检查
    STAssertNil([mockDelegate systemAllowedExtensions], nil);
    STAssertNil([mockDelegate prepackedApps], nil);
}

- (void)testParseXMLFile
{
    XMockXMLParserDelegateForXUtilsTest *mockDelegate = [[XMockXMLParserDelegateForXUtilsTest alloc] init];
    STAssertNotNil(mockDelegate, nil);

    // 测试前检查
    STAssertNil([mockDelegate systemAllowedExtensions], nil);
    STAssertNil([mockDelegate prepackedApps], nil);

    STAssertTrueNoThrow([XUtils parseXMLFileAtPath:self->plainConfigFilePath withDelegate:mockDelegate], nil);

    // 测试后检查
    STAssertFalseNoThrow([mockDelegate isParseErrorOccured], nil);
    STAssertNil([mockDelegate systemAllowedExtensions], nil);
    STAssertTrueNoThrow((2 == [[mockDelegate prepackedApps] count]), nil);
}

- (void)testParseXMLDataWithNilArgs
{
    STAssertFalseNoThrow([XUtils parseXMLData:nil withDelegate:nil], nil);
}

- (void)testParseXMLDataWithNilDelegate
{
    NSData *xmlData = [fileOperator readAsDataFromFile:self->configFilePath];
    STAssertNotNil(xmlData, nil);

    STAssertTrueNoThrow([XUtils parseXMLData:xmlData withDelegate:nil], nil);
}

- (void)testParseXMLDataWithNilData
{
    XMockXMLParserDelegateForXUtilsTest *mockDelegate = [[XMockXMLParserDelegateForXUtilsTest alloc] init];
    STAssertNotNil(mockDelegate, nil);

    // 测试前检查
    STAssertFalseNoThrow([mockDelegate isParseErrorOccured], nil);

    // 执行测试
    STAssertFalseNoThrow([XUtils parseXMLData:nil withDelegate:mockDelegate], nil);

    // 测试后检查
    STAssertTrueNoThrow([mockDelegate isParseErrorOccured], nil);
}

- (void)testParseXMLData
{
    XMockXMLParserDelegateForXUtilsTest *mockDelegate = [[XMockXMLParserDelegateForXUtilsTest alloc] init];
    STAssertNotNil(mockDelegate, nil);
     NSData *xmlData = [fileOperator readAsDataFromFile:self->configFilePath];
    STAssertNotNil(xmlData, nil);

    // 测试前检查
    STAssertNil([mockDelegate systemAllowedExtensions], nil);
    STAssertNil([mockDelegate prepackedApps], nil);

    // 执行测试
    STAssertTrueNoThrow([XUtils parseXMLData:xmlData withDelegate:mockDelegate], nil);

    // 测试后检查
    STAssertFalseNoThrow([mockDelegate isParseErrorOccured], nil);
    STAssertNotNil([mockDelegate systemAllowedExtensions], nil);
    STAssertTrueNoThrow((2 == [[mockDelegate prepackedApps] count]), nil);
}

- (void)testReadFileInPackageWithNilResult
{
    STAssertNil([XUtils readFile:XUTILS_LOGIC_TESTS_INVALID_FILE_NAME inPackage:nil], nil);
    STAssertNil([XUtils readFile:XUTILS_LOGIC_TESTS_INVALID_FILE_NAME inPackage:XUTILS_LOGIC_TESTS_INVALID_PACKAGE_PATH], nil);
    STAssertNil([XUtils readFile:XUTILS_LOGIC_TESTS_INVALID_FILE_NAME inPackage:self->appPackageFilePath], nil);
}

- (void)testReadFileInPackage
{
    // 读取app.xml文件数据
    NSData *data = [XUtils readFile:XUTILS_LOGIC_TESTS_APP_CONFIG_FILE_NAME inPackage:self->appPackageFilePath];
    STAssertNotNil(data, nil);

    // 读取index.html文件数据
    data = [XUtils readFile:XUTILS_LOGIC_TESTS_APP_ENTRY_FILE_NAME inPackage:self->appPackageFilePath];
    STAssertNotNil(data, nil);
}

- (void)testGetAppInfoFromAppPackageWithNilArgs
{
    XAppInfo *appInfo = [XUtils getAppInfoFromAppPackage:nil];
    STAssertNil(appInfo, nil);
}

- (void)testGetAppInfoFromAppPackageWithInvalidPackagePath
{
    XAppInfo *appInfo = [XUtils getAppInfoFromAppPackage:XUTILS_LOGIC_TESTS_INVALID_PACKAGE_PATH];
    STAssertNil(appInfo, nil);
}

- (void)testGetAppInfoFromAppPackage
{
    // 执行测试
    XAppInfo *appInfo = [XUtils getAppInfoFromAppPackage:self->appPackageFilePath];
    STAssertNotNil(appInfo, nil);

    // 测试后检查
    STAssertTrueNoThrow([[appInfo appId] isEqualToString:XUTILS_LOGIC_TESTS_APP_PACKAGE_APP_ID], nil);
    STAssertTrueNoThrow([[appInfo version] isEqualToString:XUTILS_LOGIC_TESTS_APP_VERSION], nil);
    STAssertFalse([appInfo isEncrypted], nil);
    STAssertTrueNoThrow([[appInfo name] isEqualToString:XUTILS_LOGIC_TESTS_APP_NAME], nil);
    STAssertTrueNoThrow([[appInfo entry] isEqualToString:XUTILS_LOGIC_TESTS_APP_ENTRY], nil);
    STAssertTrueNoThrow([[appInfo icon] isEqualToString:XUTILS_LOGIC_TESTS_APP_ICON], nil);
    STAssertTrueNoThrow([[appInfo type] isEqualToString:XUTILS_LOGIC_TESTS_APP_TYPE], nil);
    STAssertTrueNoThrow([[appInfo version] isEqualToString:XUTILS_LOGIC_TESTS_APP_VERSION], nil);
}

- (void)testGetAppInfoFromAppXMLData
{
    //创建测试输入数据
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString* appXMLPath = [bundle pathForResource:@"appschema.xml" ofType:nil];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSData *xmlData = [fileMgr contentsAtPath:appXMLPath];

    XAppInfo  *appInfo = [XUtils getAppInfoFromAppXMLData:xmlData];
    STAssertNotNil(appInfo, nil);
}

- (void)testGetAppInfoFromConfigFileAtPathWithNilArgs
{
    XAppInfo *appInfo = [XUtils getAppInfoFromConfigFileAtPath:nil];
    STAssertNil(appInfo, nil);
}

- (void)testGetAppInfoFromConfigFileAtPathWithInvalidArgs
{
    XAppInfo *appInfo = [XUtils getAppInfoFromConfigFileAtPath:@"invalidPath"];
    STAssertNil(appInfo, nil);
}

- (void)testGetAppInfoFromConfigFileAtPathNormal
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *appConfigFilePath = [bundle pathForResource:@"app.xml" ofType:nil inDirectory:nil];
    STAssertTrueNoThrow(([appConfigFilePath length] > 0), nil);

    XAppInfo *appInfo = [XUtils getAppInfoFromConfigFileAtPath:appConfigFilePath];
    STAssertNotNil(appInfo, nil);
    STAssertNotNil([appInfo appId], nil);
}

- (void)testResolvePathWithNilResult
{
    NSString *workSpace = [[XConfiguration getInstance] systemWorkspace];
    NSString *path = @"../download/app.zip";

    NSString *actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertNil(actualPath, nil);

    path = @"/../download/app.zip";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertNil(actualPath, nil);

    XAppInfo* appInfo = [[XAppInfo alloc] init];
    id<XApplication> app = [XApplicationFactory create:appInfo];
    [[app appInfo] setAppId:XUTILS_LOGIC_TESTS_APP_ID];
    workSpace = [app getWorkspace];
    path = @"../workspaces";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertNil(actualPath, nil);
}

- (void)testResolvePath
{
    NSString *workSpace = [[XConfiguration getInstance] systemWorkspace];

    NSString *actualPath = [XUtils resolvePath:nil usingWorkspace:workSpace];
    STAssertEqualObjects(workSpace, actualPath, @"resolve path failed");

    actualPath = [XUtils resolvePath:@"" usingWorkspace:workSpace];
    STAssertEqualObjects(workSpace, actualPath, @"resolve path failed");

    NSString *path = @"download/app.zip";
    NSString *expectedPath = [workSpace stringByAppendingString:path];
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertEqualObjects(expectedPath, actualPath, @"resolve path failed");

    path = @"/download/app.zip";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertEqualObjects(expectedPath, actualPath, @"resolve path failed");

    path = @"///download/app.zip";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertEqualObjects(expectedPath, actualPath, @"resolve path failed");

    path = @"\\download/app.zip";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertEqualObjects(expectedPath, actualPath, @"resolve path failed");

    path = @"/temp/../download/app.zip";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertEqualObjects(expectedPath, actualPath, @"resolve path failed");

    path = @"\\temp/..\\download/app.zip";
    actualPath = [XUtils resolvePath:path usingWorkspace:workSpace];
    STAssertEqualObjects(expectedPath, actualPath, @"resolve path failed");
}

- (void)testGenerateAppIconPathWithNilResult
{
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:@"../icon.png"];
    STAssertNil(iconPath, @"generated icon path should be nil");

    iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:@"..\\icon.png"];
    STAssertNil(iconPath, @"generated icon path should be nil");
}

- (void)testGenerateAppIconPath
{
    NSString *iconsRoot = [[XConfiguration getInstance] appIconsDir];
    NSString *expectedIconPath = [iconsRoot stringByAppendingString:@"appId"];

    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:nil];
    STAssertEqualObjects(expectedIconPath, iconPath, @"generated icon path is incorrect");

    iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:@""];
    STAssertEqualObjects(expectedIconPath, iconPath, @"generated icon path is incorrect");

    expectedIconPath = [iconsRoot stringByAppendingString:@"appId/icon.png"];

    iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:@"icon.png"];
    STAssertEqualObjects(expectedIconPath, iconPath, @"generated icon path is incorrect");

    expectedIconPath = [iconsRoot stringByAppendingString:@"appId/img/icon.png"];

    iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:@"img/icon.png"];
    STAssertEqualObjects(expectedIconPath, iconPath, @"generated icon path is incorrect");

    iconPath = [XUtils generateAppIconPathUsingAppId:XUTILS_LOGIC_TESTS_APP_ID relativeIconPath:@"/img/icon.png"];
    STAssertEqualObjects(expectedIconPath, iconPath, @"generated icon path is incorrect");
}

- (void)testSaveDocToFileWithFalseResult
{
    BOOL ret = [XUtils saveDoc:nil toFile:nil];
    STAssertFalse(ret, nil);

    APDocument *doc = [[APDocument alloc] initWithString:XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_STR];

    ret = [XUtils saveDoc:doc toFile:nil];
    STAssertFalse(ret, nil);

    NSString *tempConfigFilePath = [[[XConfiguration getInstance] systemWorkspace] stringByAppendingFormat:@"%@", XCONSTANTS_LOGIC_TESTS_TEMP_CONFIG_FILE_NAME];
    STAssertNotNil(tempConfigFilePath, nil);

    ret = [XUtils saveDoc:nil toFile:tempConfigFilePath];
    STAssertFalse(ret, nil);

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    ret = [fileMgr fileExistsAtPath:tempConfigFilePath];
    STAssertFalse(ret, nil);
}

- (void)testSaveDocToFileWithTrueResult
{
    APDocument *doc = [[APDocument alloc] initWithString:XCONSTANTS_LOGIC_TESTS_SYSTEM_CONFIG_FILE_STR];
    NSString *tempConfigFilePath = [[[XConfiguration getInstance] systemWorkspace] stringByAppendingFormat:@"%@", XCONSTANTS_LOGIC_TESTS_TEMP_CONFIG_FILE_NAME];

    STAssertNotNil(doc, nil);
    STAssertNotNil(tempConfigFilePath, nil);

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL ret = [fileMgr fileExistsAtPath:tempConfigFilePath];
    STAssertFalse(ret, nil);

    ret = [XUtils saveDoc:doc toFile:tempConfigFilePath];
    STAssertTrue(ret, nil);

    ret = [fileMgr fileExistsAtPath:tempConfigFilePath];
    STAssertTrue(ret, nil);

    NSError * __autoreleasing error = nil;
    ret = [fileMgr removeItemAtPath:tempConfigFilePath error:&error];
    STAssertTrue(ret, nil);
}

- (void)testGenerateJsCallbackRegistryKey
{
    NSString *callbackKey = [XUtils generateJsCallbackRegistryKey:@"XAmsExt" withMethod:@"start:withDict:"];
    STAssertEqualObjects(@"XAmsExt_start:withDict:", callbackKey, nil);
    callbackKey = [XUtils generateJsCallbackRegistryKey:@"XAmsImpl" withMethod:@"start:withDict:"];
    STAssertNil(callbackKey, nil);
}

- (void)testPerformSelectorWithTarget
{
    MockClassForXUtilTest* target = [[MockClassForXUtilTest alloc] init];
    STAssertNotNil(target, nil);

    [XUtils performSelectorInBackgroundWithTarget:target selector:@selector(foo:) withObject:[NSNumber numberWithInt:1]];
}

- (void)testConvertNilToNSNullWhenObjNotNil
{
    NSString *str = @"";
    STAssertEqualObjects(str, CAST_TO_NSNULL_IF_NIL(str), nil);

    NSNumber *number = [NSNumber numberWithBool:YES];
    STAssertNotNil(CAST_TO_NSNULL_IF_NIL(number), nil);
    STAssertEqualObjects(number, CAST_TO_NSNULL_IF_NIL(number), nil);

    number = [NSNumber numberWithInt:0];
    STAssertNotNil(CAST_TO_NSNULL_IF_NIL(number), nil);
    STAssertEqualObjects(number, CAST_TO_NSNULL_IF_NIL(number), nil);
}

- (void)testConvertNilToNSNullWhenObjIsNil
{
    NSString *str = nil;
    STAssertEqualObjects([NSNull null], CAST_TO_NSNULL_IF_NIL(str), nil);

    NSNumber *number = nil;
    STAssertEqualObjects([NSNull null], CAST_TO_NSNULL_IF_NIL(number), nil);
}

- (void)testGetxFaceConfigForKeyWhenKeyNotExist
{
    STAssertNil([XUtils getValueFromDataForKey:XUTILS_LOGIC_CONFIG_KEYNOTEXIST], nil);
}

- (void)testSetxFaceConfigForKeyWhenAddAndGet
{
    [XUtils setValueToDataForKey:XUTILS_LOGIC_CONFIG_KEY01 value:XUTILS_LOGIC_CONFIG_VALUE01];

    NSString *systemWorkspace = [[XConfiguration getInstance] systemWorkspace];
    NSString *plistPath = [systemWorkspace stringByAppendingPathComponent:XFACE_DATA_PLIST_NAME];

    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:plistPath], nil);

    NSString *value = (NSString *)[XUtils getValueFromDataForKey:XUTILS_LOGIC_CONFIG_KEY01];
    STAssertNotNil(value, nil);
    STAssertTrue([value isEqualToString:XUTILS_LOGIC_CONFIG_VALUE01], nil);

    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
}

- (void)testCastToPointerToNSErrorIfNilMacro
{
    __autoreleasing NSError **obj = nil;
    STAssertTrue((nil == obj), nil);

    CAST_TO_POINTER_TO_NSERROR_IF_NIL(obj);

    STAssertTrue((nil != obj), nil);

    __autoreleasing NSError *err = nil;
    obj = &err;
    CAST_TO_POINTER_TO_NSERROR_IF_NIL(obj);

    STAssertEquals(obj, &err, nil);
}

- (void)testBuildConfigFilePathWithAppId
{
    // 执行测试
    NSString* appId1 = @"defaultAppId";
    NSString* appId2 = @"storage";

    NSString *path = [XUtils buildConfigFilePathWithAppId:appId2];

    NSString *pathPrefix = [[XConfiguration getInstance] appInstallationDir];
    NSString *pathSuffix = [NSString stringWithFormat:@"%@%@%@", appId2, FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];
    NSString *expectedPath = [NSString stringWithFormat:@"%@%@", pathPrefix, pathSuffix];

    // 测试后检查
    STAssertTrue([path hasPrefix:pathPrefix], nil);
    STAssertTrue([path hasSuffix:pathSuffix], nil);
    STAssertTrue([path isEqualToString:expectedPath], nil);

    // 执行测试
    path = [XUtils buildConfigFilePathWithAppId:appId1];

    // 测试后检查
    pathSuffix = [NSString stringWithFormat:@"%@%@%@", appId1, FILE_SEPARATOR, APPLICATION_CONFIG_FILE_NAME];
    expectedPath = [NSString stringWithFormat:@"%@%@", pathPrefix, pathSuffix];

    STAssertTrue([path hasPrefix:pathPrefix], nil);
    STAssertTrue([path hasSuffix:pathSuffix], nil);
    STAssertTrue([path isEqualToString:expectedPath], nil);
}

@end
