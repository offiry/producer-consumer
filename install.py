import sys
import subprocess
from termcolor import colored

answer = input(colored("install rabbitmq configuration ? [enter] - yes, other - no", 'yellow'))
if answer is not None and answer == "":
    files = ['./rabbitmq.sh', './rabbitmq.ps1']

    for file in files:
        print(colored("running " + file, 'green'))
        p = subprocess.Popen(["powershell.exe" , file], stdout=sys.stdout)
        p.communicate()

answer = input(colored("install https configuration ? [enter] - yes, other - no", 'yellow'))
if answer is not None and answer == "":
    files = ['./https.sh', './https.ps1']

    for file in files:
        print(colored("running " + file, 'green'))
        p = subprocess.Popen(["powershell.exe" , file], stdout=sys.stdout)
        p.communicate()