#!/usr/bin/env bash
#
# Simple check Memcached plugin for Nagios
#
# Usage: check_memcached.sh [-h host] [-p port] [-w warning] [-c critical]
#   -h, --host                  Memcached host
#   -p, --port                  Memcached port, eg: 11211
#   -w, --warning WARNING       Warning value (percent)
#   -c, --critical CRITICAL     Critical value (percent)
#   -H, --help                  Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --host | -h)
      host=$2
      shift
      ;;
    --port | -p)
      port=$2
      shift
      ;;
    --warning | -w)
      warn=$2
      shift
      ;;
    --critical | -c)
      crit=$2
      shift
      ;;
    --help | -H)
      sed -n '2,11p' "$0" | tr -d '#'
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

host=${host:=127.0.0.1}
port=${port:=11211}
warn=${warn:=90}
crit=${crit:=95}

output=$( (echo 'stats'; echo 'quit';) | nc "$host" "$port")

if test $? -ne 0; then
  echo "CRITICAL - timed out connecting to memcached on ${host}:${port}"
  exit 2
fi

limit_maxbytes=$(echo "$output" | grep 'limit_maxbytes' | awk '{ gsub(/\r/, ""); print $3 }')
bytes=$(echo "$output" | grep ' bytes ' | awk '{ gsub(/\r/, ""); print $3 }')

if [[ "$bytes" -eq 0 ]]; then
  echo 'OK - Memcached is empty'
  exit 0
fi

used=$((bytes * 100 / limit_maxbytes))
status="${used}% used (${bytes} of ${limit_maxbytes}) bytes used";

if [[ $used -gt $crit ]]; then
  echo "CRITICAL - ${status}"
  exit 2
elif [[ $used -gt $warn ]]; then
  echo "WARNING - ${status}"
  exit 1
else
  echo "OK - ${status}"
  exit 0
fi
