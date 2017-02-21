#!/bin/bash

# YOU SHOULD GRACEFULLY STOP TASKMAN BEFORE RUNNING THIS SCRIPT!
# You should also run check-running-processes.sh and stop any processes
# attached to the current user.

# This script will backup your OSEHRA VistA environment. It will delete any
# previous backup.

# This step ensures .mje and .mjo files will be created in /home/osehra

# Configuration section:
# ---Directories:
HOME=/home/osehra
# ---Binaries:
AWK=/usr/bin/awk
BC=/usr/bin/bc
BZIP2=/bin/bzip2
CP=/bin/cp
DATE=/bin/date
DU=/usr/bin/du
FIND=/usr/bin/find
GREP=/bin/grep
HOSTNAME=/bin/hostname
LS=/bin/ls
MKDIR=/bin/mkdir
MUMPS=$HOME/lib/gtm/mumps
MUPIP=$HOME/lib/gtm/mupip
PRINTF=/usr/bin/printf
PS=/bin/ps
RM=/bin/rm
SCP=/usr/bin/scp
SED=/bin/sed
SSH=/usr/bin/ssh
SORT=/usr/bin/sort
TAIL=/usr/bin/tail
TAR=/bin/tar
TIME=/usr/bin/time
WC=/usr/bin/wc
WHOAMI=/usr/bin/whoami
# MUMPS commands
START_TASKMAN="set DUZ=1 do ^ZTMB halt"
# Taskman notes:
#
# Stopping Taskman:
#   do STOP^ZTMKU
# This gets two prompts:
#   Are you sure you want to stop TaskMan? NO// [answer YES]
#   Should active submanagers shut down after finishing their current tasks? NO// [answer YES]
# Then you monitor Taskman
#   do ^ZTMON
# to ensure the tasks are shut down. The run node and status lists
# should show shutdown within a few seconds.
# Likewise, the number of free submanagers should drop to zero.
#
# At the Taskman monitor's main prompt, "??" will allow you to inspect
# its various lists of tasks, including the main Task List, to get the
# task numbers of anything that needs to be asked to stop.
#
# Rick wants to overhaul Taskman to make it cleaner, but that's not
# going to happen for a while.
#
# ^%ZTSCH("TASK") has the lists of tasks running.
#
# If you can successfully
#   lock ^%ZTSCH("TASK",n)
# then n is a zombie task that needs to be axed.
#   set task=0 for  set task=$order(^%ZTSCH("TASK",task)) quit:'task write !,task
#
# In any case, we don't have to shut down or start up Taskman for the
# backup script. It will become important for the restore script.
#
# End of configuration section.

NOW=`$DATE +"%Y%m%d-%H%M%S %s"`
START=`echo $NOW | $AWK '{print $2;}'`
NOW=`echo $NOW | $AWK '{print $1;}'`
HOSTNAME=`$HOSTNAME -f`
USERNAME=`$WHOAMI`
PREFIX="backup-$NOW-$USERNAME@$HOSTNAME"

cd $HOME

# echo ""
# echo "Deleting VistA repositories. You can always git them back."
# echo ""

# $RM -vrf $HOME/Dashboard/VistA
# $RM -vrf $HOME/Dashboard/VistA-M
# echo "..."

echo ""
echo ">>>---------------------------------------------------------------------"
echo ">>> Beginning backup of the OSEHRA VistA environment . . ."
echo ">>> Backing up the GT.M database."
echo ">>> This will take less than a minute."
echo ">>> Start: `$DATE`"
echo ""

$MKDIR -p $HOME/g-backup
$TIME -f "\nElapsed time: %E (%P cpu, %Ss kernel mode, %Us user mode)" \
    $MUPIP backup "*" $HOME/g-backup
$CP -v $HOME/g/osehra.gld $HOME/g-backup/

# The following section has been commented out, as Alexis no longer believes
# that it's necessary to kill all the Mumps processes.

# echo ""
# echo ">>> Killing all MUMPS processes."
# echo ""

# test_list=$($PS -aux | $GREP '[m]umps' | $AWK '{print $2}')
# for process in $test_list
# do
#     echo -n "Stopping $process ... "
# #     $MUPIP stop $process
#     echo "done."
# done

echo ""
echo ">>>---------------------------------------------------------------------"
echo ">>> Building compressed backup."

FILELIST=`LC_ALL=C $LS -a1 $HOME \
    | $SED -e '/^\.*$/d' \
           -e '/^[gj]$/d' \
           -e '/~$/d' \
           -e 's/^/.\//' \
    | LC_ALL=C $SORT`

BYTES=`$DU -bcs $FILELIST | $TAIL -1 | $AWK '{print $1;}'`
BYTES=`LC_ALL=en_US.UTF8 $PRINTF "%'d" $BYTES`
NFILES=`$FIND $FILELIST -print | $WC -l`
NFILES=`LC_ALL=en_US.UTF-8 $PRINTF "%'d" $NFILES`

echo ">>> Backing up $BYTES bytes in $NFILES files."
echo ">>> This will take 5-7 minutes (each dot = 250 files)."
echo ">>> Start: `$DATE`"
echo ""

# This depends heavily on GNU tar!

# It also requires a useless file in $HOME/ that starts with g. This allows the
# following command to slurp up any file beginning with 'g' but without
# slurping up the $HOME/g directory, which has already been backed up with
# mupip.

$TIME -f "\nElapsed time: %E (%P cpu, %Ss kernel mode, %Us user mode)" \
    $TAR --create \
	--file=$HOME/$PREFIX.tar.bz2 \
	--checkpoint=250 \
	--checkpoint-action=dot \
	--totals \
	--exclude-backups \
	--exclude="backup-*.tar.bz2" \
        --bzip2 \
	$FILELIST

echo ""
echo ">>>---------------------------------------------------------------------"
echo ">>> Cleaning up the database backup directory:"
echo ""

$RM -rfv $HOME/g-backup

# echo ""
# echo ">>>---------------------------------------------------------------------"
# echo ">>> Compressing backup."
# echo ">>> This will take around ten minutes."
# echo ">>> Start: `$DATE`"
# echo ""

# $TIME -f "\nElapsed time: %E (%P cpu, %Ss kernel mode, %Us user mode)" \
#    $BZIP2 -v $HOME/$PREFIX.tar

echo ""
echo ">>>---------------------------------------------------------------------"
echo ">>> Start Taskman:"
echo ""

# echo $START_TASKMAN | $MUMPS -dir
echo "..."

# NEXT: Write command to squirt backup file to another host, delete it from
# here. Optionally, manage the number of backups stored at the remote host.

END=`$DATE +"%s"`
SEC=`echo "$END - $START" | $BC -l`
MN=`$PRINTF "scale=0\n$SEC / 60\n" | $BC -l`
SC=`$PRINTF "scale=0\n$SEC %% 60\n" | $BC -l`
ELA=`$PRINTF "%dm%02ds" $MN $SC`
SEC=`LC_ALL=en_US.UTF-8 $PRINTF "%'ds" $SEC`

echo ""
echo ">>>---------------------------------------------------------------------"
echo ">>> Done ($ELA, or $SEC total)."
echo ">>> End: `$DATE`"
echo ">>>---------------------------------------------------------------------"
echo ""
<<<<<<< HEAD
=======

>>>>>>> 6e4d6bc3ba8d5533a9299081d73390a531b0791c
