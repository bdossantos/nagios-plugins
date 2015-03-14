#!/usr/bin/env bash
#
# Check application disk(s) health
#
# Usage: check_smart.sh
#     -h, --help            Display this screen
#
# (c) 2015, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --help | -h)
      sed -n '2,10p' "$0" | tr -d '#'
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

if ! hash lsblk 2>/dev/null; then
  echo 'UNKNOWN - Could not find `lsblk` utility'
  exit 3
fi

if ! hash smartctl 2>/dev/null || [[ -x smartctl ]]; then
  echo 'UNKNOWN - Could not find or execute `smartctl` utility'
  exit 3
fi

smart_available=()
unknown_disks=()
unhealthy_disks=()
healthy_disks=()

disks=$(lsblk -nro NAME,TYPE | grep 'disk' | awk '{ print $1 }')
for disk in $disks
do
  device="/dev/${disk}"
  smart=$(smartctl -i "$device")

  if echo "$smart" | grep -q 'SMART support is: Available'; then
    smart_available=("${smart_available[@]}" "$device")
  fi
done

for device in "${smart_available[@]}"
do
  health=$(smartctl -a "$device")
  if echo "$health" | grep -q 'ATA Error Count:'; then
    unhealthy_disks=("${unhealthy_disks[@]}" "$device")
  elif echo "$health" | grep -q 'No Errors Logged'; then
    healthy_disks=("${healthy_disks[@]}" "$device")
  else
    unknown_disks=("${unknown_disks[@]}" "$device")
  fi
done

if [[ ${#unhealthy_disks[@]} -gt 0 ]]; then
  output=$(IFS=, ; echo "${unhealthy_disks[*]}")
  echo "CRITICAL - unhealthy disk(s) found : ${output}"
  exit 2
fi

if [[ ${#unknown_disks[@]} -gt 0 ]]; then
  output=$(IFS=, ; echo "${unknown_disks[*]}")
  echo "CRITICAL - unknown disk(s) found : ${output}"
  exit 2
fi

output=$(IFS=, ; echo "${healthy_disks[*]}")
echo "OK - disk(s) look healthy : ${output}"
exit 0
