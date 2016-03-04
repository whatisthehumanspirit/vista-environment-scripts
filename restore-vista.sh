#!/bin/bash

# YOU SHOULD GRACEFULLY STOP TASKMAN BEFORE RUNNING THIS SCRIPT!
# You should also run check-running-processes.sh and stop any processes attached to the current user.

# This script will restore your OSEHRA VistA environment using the last backup. Make sure you have a backup.

echo "Restoring your OSEHRA VistA environment using the last backup."

echo "Deleting the current VistA environment."
shopt -s extglob
rm -rf /home/osehra/!(.bash_history|.gitconfig|.ssh|.viminfo|vista-environment-scripts)
shopt -u extglob

echo "Copying files."
rsync -a /tmp/osehra/ /home/osehra

echo "Restoring the GT.M database."
cd /home/osehra
mv backup/* g/

echo "Reloading environment variables."
. ".profile"
source etc/env

echo "Restarting Taskman."
mumps -dir <<< "S DUZ=1 D ^ZTMB H"
