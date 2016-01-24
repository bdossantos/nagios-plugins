#!/usr/bin/env bash
#
# Check InfluxDB plugin for Nagios
#
# Usage: check_influxdb.sh [-H host] [-P port]
#   -H, --host            Hostname
#   -P, --port            Port, eg: 8086
#   -h, --help            Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case "$1" in
    --hostname | -H)
      hostname=$2
      shift
      ;;
    --port | -P)
      port=$2
      shift
      ;;
    --help | -h)
      sed -n '2,9p' "$0" | tr -d '#'
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

hostname=${hostname:=127.0.0.1}
port=${port:=8086}
url="http://${hostname}:${port}/ping?wait_for_leader=1s"

if curl -s -I "$url" >/dev/null; then
  echo "OK - InfluxDB is up & running"
  exit 0
else
  echo "CRITICAL - InfluxDB is KO"
  exit 2
fi
