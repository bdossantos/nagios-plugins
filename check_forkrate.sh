#!/usr/bin/env bash
#
# Check forkrate
#
# Usage: check_forkrate.sh [-w warning] [-c critical] [-i interval]
#     -w, --warning WARNING         Warning value (percent)
#     -c, --critical CRITICAL       Critical value (percent)
#     -i, --interval INTERVAL       Interval
#     -h, --help                    Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#
# Adapted from :
#
# https://gist.github.com/internetstaff/11269560
#
# Copyright bitly, Aug 2011
# written by Jehiah Czebotar
#

while [[ -n "$1" ]]; do
  case $1 in
  -w | --warning)
    warning_treshold=$2
    shift
    ;;
  -c | --critical)
    critical_treshold=$2
    shift
    ;;
  -i | --interval)
    interval=$2
    shift
    ;;
  -h | --help)
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

DATAFILE='/tmp/nagios_check_forkrate.dat'
interval=${interval:=60}

if [[ -z "$warning_treshold" ]] || [[ -z "$critical_treshold" ]]; then
  echo "Error: --warning and --critical parameters are required"
  exit 3
fi

if [[ $warning_treshold -ge $critical_treshold ]]; then
  echo "Error: --warn ($warning_treshold) can't be greater than --critical ($critical_treshold)"
  exit 3
fi

now=$(date +%s)
min_valid_ts=$((now - interval))
current_process_count=$(awk '/processes/ {print $2}' /proc/stat)

if [[ ! -f $DATAFILE ]]; then
  echo -e "$now\t$current_process_count" >$DATAFILE
  echo "Missing $DATAFILE; creating"
  exit 0
fi

# now compare this to previous
mv $DATAFILE{,.previous}
while read ts process_count; do
  if [[ $ts -lt $min_valid_ts ]]; then
    continue
  fi

  if [[ $ts -ge $now ]]; then
    # we can't use data from the same second
    continue
  fi

  # calculate the rate
  process_delta=$((current_process_count - process_count))
  ts_delta=$((now - ts))
  current_fork_rate=$((process_delta / ts_delta))
  echo -e "$ts\t$process_count" >>$DATAFILE
done <$DATAFILE.previous

echo -e "$now\t$current_process_count" >>$DATAFILE
output="fork rate is $current_fork_rate processes/second (based on the last $ts_delta seconds) | fork_rate=$current_fork_rate"

if [[ $current_fork_rate -ge $critical_treshold ]]; then
  echo "CRITICAL: $output"
  exit 2
fi

if [[ $current_fork_rate -ge $warning_treshold ]]; then
  echo "WARNING: $output"
  exit 1
fi

echo "OK: $output"
exit 0
