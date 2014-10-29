#!/usr/bin/env bash
#
# Check dmesg output
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

output=$(dmesg -T -l err,crit,alert,emerg 2>/dev/null || dmesg || exit 3)
if test ! -z "$output"; then
  filtered_output=$({
    echo $output | egrep -o -i \
    'Hardware Error|I/O error|hard resetting link|DRDY ERR|Out of memory|Killed process|temperature above threshold|Possible SYN flooding|segfault|MEMORY ERROR'
  })

  if test ! -z "$filtered_output"; then
    echo 'WARNING - The dmesg output contain error(s) :'
    echo $filtered_output
    exit 1
  fi
fi

echo "OK - The dmesg command output doesn't seem contain error."
exit 0
