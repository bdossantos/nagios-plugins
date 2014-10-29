#!/usr/bin/env bash
#
# Simple check Memcached plugin for Nagios
#
# Options :
#
#   -h/--host)
#       Memcached host
#
#   -p/--port)
#       Memcached port
#
#   -w/--warning)
#       MySQL defaults-file path
#
#   -c/--critical)
#       Critical value (percent)
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while test -n "$1"; do
  case $1 in
    --host|-h)
      user=$2
      shift
      ;;
    --port|-p)
      password=$2
      shift
      ;;
    --warning|-w)
      warn=$2
      shift
      ;;
    --critical|-c)
      crit=$2
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 3
      ;;
  esac
  shift
done

host=${host:=127.0.0.1}
port=${port:=11211}
warn=${warn:=90}
crit=${crit:=95}

output=$((echo 'stats'; echo 'quit';) | nc "$host" "$port")

if test $? -ne 0; then
  echo "CRITICAL - timed out connecting to memcached on ${host}:${port}"
  exit 2
fi

limit_maxbytes=$(echo "$output" | grep 'limit_maxbytes' | awk '{ gsub(/\r/, ""); print $3 }')
bytes=$(echo "$output" | grep ' bytes ' | awk '{ gsub(/\r/, ""); print $3 }')

if test $bytes -eq 0; then
  echo 'OK - Memcached is empty'
  exit 0
fi

used=$(expr $bytes \* 100 \/ $limit_maxbytes)
status="${used}% used (${bytes} of ${limit_maxbytes}) bytes used";

if test $used -gt $crit; then
  echo "CRITICAL - ${status}"
  exit 2
elif test $used -gt $warn; then
  echo "WARNING - ${status}"
  exit 1
else
  echo "OK - ${status}"
  exit 0
fi
