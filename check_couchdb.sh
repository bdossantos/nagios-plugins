#!/usr/bin/env bash
#
# Check CouchDB plugin for Nagios
#
# Options :
#   -H/--hostname)
#       CouchDB host
#
#   -P/--port)
#       CouchDB port
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while test -n "$1"; do
  case "$1" in
    --hostname|-H)
      hostname=$2
      shift
      ;;
    --port|-P)
      port=$2
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 3
      ;;
  esac
  shift
done

hostname=${hostname:=127.0.0.1}
port=${port:=5984}

response=$(curl -s http://${hostname}:${port})
if [[ "$response" =~ "Welcome" ]]; then
  echo "CouchDB OK"
  exit 0
else
  echo "CouchDB KO"
  exit 2
fi
