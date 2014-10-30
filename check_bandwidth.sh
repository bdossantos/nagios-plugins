#!/usr/bin/env bash
#
# Check bandwidth plugin for Nagios
#
# Options :
#
#   -iface/--interface)
#       Interface name (eth0 by default)
#
#   -s/--sleep)
#       Sleep time between both statistics measures
#
#   -w/--warning)
#       Warning value (KB/s)
#
#   -c/--critical)
#       Critical value (KB/s)
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --interface|-iface)
      interface=$2
      shift
      ;;
    --sleep|-s)
      sleep=$2
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

warn=${warn:=5000}
crit=${crit:=6000}
interface=${interface:=eth0}
sleep=${sleep:=5}

rx1=$(cat "/sys/class/net/${interface}/statistics/rx_bytes")
tx1=$(cat "/sys/class/net/${interface}/statistics/tx_bytes")
sleep "$sleep"
rx2=$(cat "/sys/class/net/${interface}/statistics/rx_bytes")
tx2=$(cat "/sys/class/net/${interface}/statistics/tx_bytes")

tx_bps=$((tx2 - tx1))
rx_bps=$((rx2 - rx1))
tx_kbps=$((tx_bps / 1024))
rx_kbps=$((rx_bps / 1024))

status="tx $1: $tx_kbps kb/s rx $1: $rx_kbps kb/s"
if [[ $rx_kbps -ge $warn ]] || [[ $tx_kbps -ge $warn ]]; then
  if [[ $rx_kbps -ge $crit ]] || [[ $tx_kbps -ge $crit ]]; then
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
