#!/usr/bin/env bash
#
# Check CouchDB plugin for Nagios
#
# Usage: check_couchdb.sh [-H host] [-P port]
#   -H, --host            Hostname
#   -P, --port            Port, eg: 443
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
port=${port:=5984}

response=$(curl -s "http://${hostname}:${port}")
if [[ "$response" =~ Welcome ]]; then
  echo 'OK - CouchDB is up & running'
  exit 0
else
  echo 'CRITICAL - CouchDB is KO'
  exit 2
fi
