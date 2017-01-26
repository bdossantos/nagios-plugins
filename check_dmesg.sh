#!/usr/bin/env bash
#
# Check dmesg output for common errors
#
# Usage: check_dmesg.sh
#     -h, --help            Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --help | -h)
      sed -n '2,7p' "$0" | tr -d '#'
      exit 3
      ;;
    *)
      echo "Unknown argument: $1"
      exec "$0" --help
      exit 3
      ;;
  esac
  shift
done

output=$(dmesg -T -l warn,err,crit,alert,emerg 2>/dev/null || dmesg || exit 3)
if [[ ! -z "$output" ]]; then
  filtered_output=$({
    echo "$output" | egrep -o -i \
    'Hardware Error|I/O error|hard resetting link|DRDY ERR|Out of memory|Killed process|temperature above threshold|Possible SYN flooding|segfault|MEMORY ERROR|dropping packet'
  })

  if [[ ! -z "$filtered_output" ]]; then
    echo 'WARNING - The dmesg output contain error(s) :'
    echo "$filtered_output"
    exit 1
  fi
fi

echo "OK - The dmesg command output doesn't seem contain error."
exit 0
