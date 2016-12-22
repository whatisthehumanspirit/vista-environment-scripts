#!/bin/bash

# This script backs up a specially configured OSEHRA VistA environment. Future versions will be more generalized and include options.
# 
# Journals are not preserved.

username=`whoami`
hostname=`hostname -f`
timestamp=`date +%Y%m%d-%H%M%S`
prefix="$username@$hostname-$timestamp"

cd /home/osehra
mkdir -p data/backups/$prefix/data/globals

mupip backup -database -noonline "*" data/backups/$prefix/data/globals

cp data/globals/osehra.gld data/backups/$prefix/data/globals

echo "Copying files."
rsync -a --exclude="/.bash_history" --exclude="/data" --exclude="/lib" \
    --exclude="/.ssh" --exclude="/.viminfo" /home/osehra/ /home/osehra/data/backups/$prefix/

# echo "Compressing backup."
# tar czf /home/osehra/data/backups/$prefix.tar.gz /home/osehra/data/backups/$prefix
