#!/usr/bin/env bash
# Check number of opened files

if [ $# != 2 ]; then
    echo "Syntax: check_max_open_files.sh <warn percent> <crit percent>"
    echo
    echo "Example: check_max_open_files.sh 75 90"
    exit 3
fi

opened_files=$(lsof | wc -l)
max_open_files=$(cat /proc/sys/fs/file-max)

if [ -z $opened_files ] || [ -z $max_open_files ]; then
    echo "ERROR - Can't find opened_files / max_open_files"
    exit 3
fi

warn=$(expr $max_open_files \* $1 \/ 100)
crit=$(expr $max_open_files \* $2 \/ 100)

if [ $opened_files -gt $crit ]; then
    echo "CRITICAL - $opened_files / $max_open_files"
    exit 2
elif [ $opened_files -gt $warn -a $opened_files -lt $crit ]; then
    echo "WARNING - $opened_files / $max_open_files"
    exit 1
else
    echo "OK - $opened_files / $max_open_files"
    exit 0
fi

echo "UNKNOWN - Error"
exit 3