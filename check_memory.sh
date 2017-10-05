#!/usr/bin/env bash
#
# Check memory usage
#
# Usage: check_memory.sh [-w warning] [-c critical]
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

meminfo=$(cat /proc/meminfo)
memory_total=$(echo "$meminfo" | awk '/MemTotal/ { print int($2 / 1024) }')
memory_free=$(echo "$meminfo" | awk '/MemFree/ { print int($2 / 1024) }')
buffers=$(echo "$meminfo" | awk '/Buffers/ { print int($2 / 1024) }')
cached=$(echo "$meminfo" | awk '/^Cached: */ { print int($2 / 1024) }')
total_used_memory=$((memory_total - memory_free))
non_cached_buffer_used_memory=$((total_used_memory - (buffers + cached)))

percentage=$((non_cached_buffer_used_memory * 100 / memory_total))
status="${percentage}% of memory used (${non_cached_buffer_used_memory} of ${memory_total} MB)"

if [[ -z $percentage ]]; then
  echo "UNKNOWN - Error"
  exit 3
elif [[ $percentage -gt $crit ]]; then
  echo "CRITICAL - ${status} | used=${non_cached_buffer_used_memory} total=${memory_total}"
  exit 2
elif [[ $percentage -gt $warn ]]; then
  echo "WARNING - ${status} | used=${non_cached_buffer_used_memory} total=${memory_total}"
  exit 1
else
  echo "OK - ${status} | used=${non_cached_buffer_used_memory} total=${memory_total}"
  exit 0
fi
