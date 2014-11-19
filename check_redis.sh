#!/usr/bin/env bash
#
# Dead simple script to check if Redis is UP
#
# Usage: check_redis.sh [-h host] [-p port] [-w warning] [-c critical]
#   -h, --host                  Redis host
#   -p, --port                  Redis port, eg: 6379
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
port=${port:=6379}

output=$(echo 'info' | nc -w1 $host $port)
if [[ $? -ne 0 ]] || [[ -z  $output ]]; then
  echo "CRITICAL - could not connect to redis on ${host}:${port}"
  exit 2
fi

used_memory_human=$(echo "$output" | awk -F ":" '$1 == "used_memory_human" {print $2}'|sed -e 's/\r//')
instantaneous_ops_per_sec=$(echo "$output" | awk -F : '$1 == "instantaneous_ops_per_sec" {print $2}')

if [[ -z $used_memory_human ]] || [[ -z  $instantaneous_ops_per_sec ]]; then
  echo "CRITICAL - could not fetch redis stats on ${host}:${port}"
  exit 2
fi

echo "OK - Redis Memory: ${used_memory_human}, Ops/s: ${instantaneous_ops_per_sec}"
exit 0
