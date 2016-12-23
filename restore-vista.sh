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
rm -rf /home/osehra/!(.bash_history|data|lib|.ssh|.viminfo)
shopt -u extglob
rm /home/osehra/data/globals/*
rm /home/osehra/data/journals/*

echo "Copying files."
rsync -a . /home/osehra/

echo "Reloading environment variables."
mupip rundown -relinkctl

echo "Enabling journaling."
./bin/enableJournal.sh

echo "Restarting Taskman."
mumps -dir <<< "D ^ZTMB H"
