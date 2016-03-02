#!/bin/bash

# YOU SHOULD GRACEFULLY STOP TASKMAN BEFORE RUNNING THIS SCRIPT!

# This script will restore your OSEHRA VistA environment using the last backup. Make sure you have a backup.

echo "Restoring your OSEHRA VistA environment using the last backup."

echo "Killing all MUMPS processes."
test_list=$(ps -aux | grep '[m]umps' | awk '{print $2}')
for process in $test_list
do
  mupip stop $process
done

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
