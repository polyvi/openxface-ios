import os
import subprocess
import sys
#run command and return the status code
GENERATEFILENAME = "GenerateXFaceJs.py"
PLATFORM = "ios"
def runCommand(command_str):
    output = subprocess.Popen(command_str, shell= True , stdout=subprocess.PIPE)
    while True:
        str = output.stdout.read()
        if not len(str): break
        print str
    output.wait()
    return output.returncode

def generateXFaceJs():
    commonFilePath = os.path.normpath(os.path.join(os.path.dirname(os.path.realpath(__file__)),r"../../../xface/js/generater",GENERATEFILENAME))
    destFilePath = os.path.join(os.path.dirname(os.path.realpath(__file__)),"xface.js")
    projectPath = os.path.dirname(os.path.realpath(__file__))
    appsDir =  os.path.join(projectPath,os.path.basename(projectPath),"www","preinstalledApps")
    runCommand("python " + commonFilePath + " " + destFilePath + " " + appsDir + " " + PLATFORM)
if __name__=="__main__":
    generateXFaceJs()
