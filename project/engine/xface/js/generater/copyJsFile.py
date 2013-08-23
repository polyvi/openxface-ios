# -*- coding: UTF-8 -*-
import os
import shutil
import sys
import re
APP_XML_NAME = "app.xml"
    
def copyXFaceJsToAppDir():
    if not checkArgs():
        return False
    XFACE_JS_FILE_PATH = sys.argv[1]
    if not os.path.exists(XFACE_JS_FILE_PATH):
        return False
    appsDir = sys.argv[2]
    if os.path.isdir(appsDir):
        files = os.listdir(appsDir)
        for file in files:
            appDirPath = os.path.join(appsDir,file)
            if isCopyNeeded(appDirPath):
                if isNewFormatAppXml(os.path.join(appDirPath,APP_XML_NAME)):
                    targetDir = getIndexPageDirForNewFormat(os.path.join(appDirPath,APP_XML_NAME))
                else:
                    targetDir = getIndexPageDirForOldFormat(os.path.join(appDirPath,APP_XML_NAME))
                if targetDir is  None:
                    return False
                shutil.copy(XFACE_JS_FILE_PATH,targetDir)
    return True

def getIndexPageDirForOldFormat(appXmlPath):
    if not os.path.exists(appXmlPath):
        print "%s is not exist" % appXmlPath
        return None
    fileObj = open(appXmlPath,"r")
    fileContent = fileObj.read()
    fileObj.close()
    pattern = re.compile(r".*entry\s*src=\"(\S*)\s*\"",re.S)
    matches = re.match(pattern,fileContent)
    entryValue = ""
    if matches is not None:
        entryValue = matches.group(1)
    return os.path.dirname(os.path.join(os.path.dirname(appXmlPath),entryValue))

def isNewFormatAppXml(appXmlPath):
    if not os.path.exists(appXmlPath):
        print "%s is not exist" % appXmlPath
        return None
    fileObj = open(appXmlPath,"r")
    fileContent = fileObj.read()
    fileObj.close()
    pattern = re.compile(".*(</widget>)",re.S)
    matches = re.match(pattern,fileContent)
    return matches is not None

def getIndexPageDirForNewFormat(appXmlPath):
    if not os.path.exists(appXmlPath):
        print "%s is not exist" % appXmlPath
        return None
    fileObj = open(appXmlPath,"r")
    fileContent = fileObj.read()
    pattern = re.compile(".*<content\s* encoding=\"UTF-8\"\s*src=\"(\S*)\s*\"",re.S)
    matches = re.match(pattern,fileContent)
    entryValue = ""
    if matches is not None:
        entryValue = matches.group(1)
    return os.path.dirname(os.path.join(os.path.dirname(appXmlPath),entryValue))

def isCopyNeeded(appDirPath):
    if os.path.isdir(appDirPath):
        #判断文件夹内是否含有app.xml若含有则认为该文件夹为应用文件夹需要拷贝xface.js到该目录
        appXmlPath = os.path.join(appDirPath,APP_XML_NAME)
        return os.path.exists(appXmlPath)
    return False

def checkArgs():
    if sys.argv.__len__() != 3:
        print "args error,please check the argvs number"
        return False
    return True

if __name__ =="__main__":
    if not copyXFaceJsToAppDir():
        print "copy xface.js to app dir failed"
    else:
        print "copy xface.js to apps dir success"