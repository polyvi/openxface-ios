# -*- coding: utf-8 -*-
import os
import subprocess
import sys

#run command and return the status code
def runCommand(command_str):
    output = subprocess.Popen(command_str, shell= True , stdout=subprocess.PIPE)
    while True:
        str = output.stdout.read()
        if not len(str): break
        print str
    output.wait()
    return output.returncode

def generateXFaceJs():
    destPath = sys.argv[1]
    platform = sys.argv[3]
    if destPath is None:
        print "args error: dest path is none "
        return False
    print "Js file dest path: %s\n"%destPath
    old_cur = os.getcwd()
    commandDir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    os.chdir(commandDir)
    retCode =  runCommand("jake package-js platform=" + platform +" destPath=\"" + os.path.normpath(destPath) + "\"") == 0
    if not retCode:
        print "run jake command error"
    os.chdir(old_cur)
    return retCode

def copyJsFile():
    old_dir = os.getcwd()
    commandDir  = os.path.dirname(os.path.realpath(__file__))
    os.chdir(commandDir)
    retCode = runCommand("python copyJsFile.py" + " " + sys.argv[1] + " " +sys.argv[2]) == 0
    os.chdir(old_dir)
    if not retCode:
        print "copy xface.js failed"
        return False
    return True

def checkArgs():
    if sys.argv.__len__() != 4:
        print "args error,please check the argvs number"
        return False
    return True

def generate():
    if not checkArgs():
        return False
    if not generateXFaceJs():
        return False
    if not copyJsFile():
        return False
    return True

if __name__ == "__main__":
    if not generate():
        print "generate xface.js failed."
