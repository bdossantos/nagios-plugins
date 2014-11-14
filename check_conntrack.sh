#!/usr/bin/env bash
#
# Check conntrack table usage
#
# Usage: check_conntrack.sh [-w warning] [-c critical]
#     -w, --warning WARNING         Warning value (percent)
#     -c, --critical CRITICAL       Critical value (percent)
#     -h, --help                    Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --warning|-w)
      warn=$2
      shift
      ;;
    --critical|-c)
      crit=$2
      shift
      ;;
    --help|-h)
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

warn=${warn:=90}
crit=${crit:=95}

conntrack_count=$(find /proc/sys -type f -name '*conntrack_count' | head -n 1)
max_value=$(find /proc/sys -name '*conntrack_max' | head -n 1)
if [[ -z $max_value ]] || [[ -z $conntrack_count ]]; then
  echo "ERROR - Can't find *conntrack_count"
  exit 3
fi

conntrack_count=$(head -n 1 < "$conntrack_count")
max_value=$(head -n 1 < "$max_value")
warn=$((max_value * warn / 100))
crit=$((max_value * crit / 100))
performance_data="conntrack_table=$conntrack_count;$warn;$crit;0;$max_value"

if [[ $conntrack_count -gt $warn ]]; then
  echo "CRITICAL - conntrack table usage : $conntrack_count / $max_value | $performance_data"
  exit 2
elif [[ $conntrack_count -gt $warn  ]] && [[ $conntrack_count -lt $warn ]]; then
  echo "WARNING - conntrack table usage : $conntrack_count / $max_value | $performance_data"
  exit 1
elif [[ $conntrack_count -lt $warn ]]; then
  echo "OK - conntrack table usage : $conntrack_count / $max_value | $performance_data"
  exit 0
fi

echo "UNKNOWN - Error"
exit 3
