#!/usr/bin/env bash
# Check conntrack table usage

if [ $# != 2 ]; then
    echo "Syntax: check_conntrack.sh <warn percent> <crit percent>"
    echo
    echo "Example: check_conntrack.sh 75 90"
    exit 3
fi

conntrack_count=$(find /proc/sys -name *conntrack_count | head -n 1)
max_file=$(find /proc/sys -name *conntrack_max | head -n 1)
if [ -z $max_file ] || [ -z $conntrack_count ]; then
    echo "ERROR - Can't find *conntrack_count"
    exit 3
fi

conntrack_count=$(cat $conntrack_count | head -n 1)
max_file=$(cat $max_file | head -n 1)
warn=$(expr $max_file \* $1 \/ 100)
crit=$(expr $max_file \* $2 \/ 100)

if [ $conntrack_count -gt $warn ]; then
    echo "CRITICAL - conntrack table usage : $conntrack_count / $max_file"
    exit 2
elif [ $conntrack_count -gt $warn -a $conntrack_count -lt $warn ]; then
    echo "WARNING - conntrack table usage : $conntrack_count / $max_file"
    exit 1
elif [ $conntrack_count -lt $warn ]; then
    echo "OK - conntrack table usage : $conntrack_count / $max_file"
    exit 0
fi

echo "UNKNOWN - Error"
exit 3