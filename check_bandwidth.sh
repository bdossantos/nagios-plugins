#!/usr/bin/env bash
#
# Check bandwidth plugin for Nagios
#
# Usage: check_bandwidth.sh [-i interface] [-s sleep] [-w warning] [-c critical]
#     -i, --interface         Interface name (eth0 by default)
#     -s, --sleep             Sleep time between both statistics measures
#     -w, --warning           Warning value (KB/s)
#     -c, --critical          Critical value (KB/s)
#     -h, --help              Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --interface | -i)
      interface=$2
      shift
      ;;
    --sleep | -s)
      sleep=$2
      shift
      ;;
    --warning | -w)
      warning=$2
      shift
      ;;
    --critical | -c)
      critical=$2
      shift
      ;;
    --help | -h)
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

warning=${warning:=5000}
critical=${critical:=8000}
interface=${interface:=eth0}
sleep=${sleep:=1}

if [[ $warning -ge $critical ]]; then
  echo "UNKNOWN - warning ($warning) can't be greater than critical ($critical)"
  exit 3
fi

if [[ ! -f "/sys/class/net/${interface}/statistics/rx_bytes" ]] ||
  [[ ! -f "/sys/class/net/${interface}/statistics/tx_bytes" ]]; then
  echo "CRITICAL - Could not fetch '${interface}' interface statistics"
  exit 2
fi

rx1=$(cat "/sys/class/net/${interface}/statistics/rx_bytes")
tx1=$(cat "/sys/class/net/${interface}/statistics/tx_bytes")
sleep "$sleep"
rx2=$(cat "/sys/class/net/${interface}/statistics/rx_bytes")
tx2=$(cat "/sys/class/net/${interface}/statistics/tx_bytes")

tx_bps=$((tx2 - tx1))
rx_bps=$((rx2 - rx1))
tx_kbps=$((tx_bps / 1024))
rx_kbps=$((rx_bps / 1024))

status="tx ${interface}: $tx_kbps kb/s, rx ${interface}: $rx_kbps kb/s | tx=$tx_kbps rx=$rx_kbps"

if [[ $rx_kbps -ge $warning ]] || [[ $tx_kbps -ge $warning ]]; then
  if [[ $rx_kbps -ge $critical ]] || [[ $tx_kbps -ge $critical ]]; then
    exit_status=2
    echo "CRITICAL - $status"
  else
    exit_status=1
    echo "WARNING - $status"
  fi
else
  exit_status=0
  echo "OK - $status"
fi

exit ${exit_status:=3}
