#!/bin/bash

# This script will backup your OSEHRA VistA environment. It will delete any previous backup.

# This step ensures .mje and .mjo files will be created in /home/osehra
cd /home/osehra

echo "Deleting VistA repositories. You can always git them back."
rm -rf Dashboard/VistA
rm -rf Dashboard/VistA-M

echo "Backing up your OSEHRA VistA environment."

echo "Backing up the GT.M database."
rm backup/*
mupip backup "*" backup/
cp g/osehra.gld backup/

echo "Killing all MUMPS processes."
test_list=$(ps -aux | grep '[m]umps' | awk '{print $2}')
for process in $test_list
do
  mupip stop $process
done

echo "Deleting any previous backup."
rm -rf /tmp/osehra

echo "Copying files."
rsync -a --exclude "/.bash_history" --exclude="/g/*" --exclude="/.gitconfig" --exclude="/.ssh" --exclude "/.viminfo" --exclude "/vista-environment-scripts" /home/osehra/ /tmp/osehra

echo "Cleaning up."
rm backup/*

echo "Restarting Taskman."
mumps -dir <<< "S DUZ=1 D ^ZTMB H"

