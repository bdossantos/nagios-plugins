#!/usr/bin/env bash
#
# Check for ephemeral port exhaustion
#
# Usage: check_ephemeral_ports.sh [-w warning] [-c critical]
#   -w, --warning WARNING       Warning treshold
#   -c, --critical CRITICAL     Critical treshold
#   -h, --help                  Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --warning | -w)
      warning=$2
      shift
      ;;
    --critical | -c)
      critical=$2
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

warning=${warning:=2048}
critical=${critical:=1024}

if [[ $critical -ge $warning ]]; then
  echo "UNKNOWN - critical ($critical) can't be greater than warning ($warning)"
  exit 3
fi

port_range=$(cat /proc/sys/net/ipv4/ip_local_port_range 2>/dev/null)
if [[ $? -ne 0 ]]; then
  echo 'CRITICAL - Could not fetch local port range'
  exit 2
fi

min_port_range=$(echo "$port_range" | awk '{ print $1 }')
max_port_range=$(echo "$port_range" | awk '{ print $2 }')
established_connections=$(netstat -an | grep -c 'ESTABLISHED')

if [[ -z $min_port_range ]] || [[ -z $max_port_range ]] || \
  [[ -z $established_connections ]]; then
  echo "CRITICAL - could not fetch 'min_port_range' or 'max_port_range'"
  exit 2
fi

available_ports=$((max_port_range - min_port_range - established_connections))
status="${established_connections} established connections, ${available_ports} free ephemeral ports (range ${min_port_range}-${max_port_range})";

if [[ $available_ports -lt $critical ]]; then
  echo "CRITICAL - ${status}"
  exit 2
elif [[ $available_ports -gt $critical ]] && \
  [[ $available_ports -lt $warning ]]; then
  echo "WARNING - ${status}"
  exit 1
else
  echo "OK - ${status}"
  exit 0
fi

echo "UNKNOWN - Error"
exit 3
