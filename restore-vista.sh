#!/bin/bash

# This script restores a specially configured OSEHRA VistA environment. Future versions will be more generalized and include options.
# 
# Journals are not restored.

echo "Restoring your OSEHRA VistA environment using this backup."

echo "Killing all MUMPS processes."
proc_list=$(pgrep mumps)
for process in $proc_list
do
  mupip stop $process
done

echo "Killing all MUPIP processes."
proc_list=$(pgrep mupip)
for process in $proc_list
do
  mupip stop $process
done

echo "Killing all GTMSECSHR processes."
proc_list=$(pgrep gtmsecshr)
for process in $proc_list
do
  mupip stop $process
done

echo "Deleting the current VistA environment."
shopt -s extglob
rm -rf /home/osehra/!(.bash_history|data|lib|.ssh|.viminfo|vista-environment-scripts)
shopt -u extglob
rm /home/osehra/data/globals/*
rm /home/oshera/data/journals/*

echo "Copying files."
rsync -a . /home/osehra

echo "Restoring the GT.M database."
cd /home/osehra
mv backup/* g/

echo "Reloading environment variables."
. ".profile"
source etc/env

echo "Enabling journaling."
./bin/enableJournal.sh

echo "Restarting Taskman."
mumps -dir <<< "S DUZ=1 D ^ZTMB H"
