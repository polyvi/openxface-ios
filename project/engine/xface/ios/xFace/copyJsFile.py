import os
import subprocess
import sys
#run command and return the status code
COPYFILENAME = "copyJsFile.py"
def runCommand(command_str):
    output = subprocess.Popen(command_str, shell= True , stdout=subprocess.PIPE)
    while True:
        str = output.stdout.read()
        if not len(str): break
        print str
    output.wait()
    return output.returncode

def copyXFaceJsToAppsDir():
    commonFilePath = os.path.normpath(os.path.join(os.path.dirname(os.path.realpath(__file__)),r"../../../../../tools/scripts/xfaceJsManager",COPYFILENAME))
    destFilePath = os.path.join(os.path.dirname(os.path.realpath(__file__)),"xface.js")
    projectPath = os.path.dirname(os.path.realpath(__file__))
    appsDir =  os.path.join(projectPath,os.path.basename(projectPath),"www","preinstalledApps")
    runCommand("python " + commonFilePath + " " + destFilePath + " " + appsDir)
if __name__=="__main__":
    copyXFaceJsToAppsDir()