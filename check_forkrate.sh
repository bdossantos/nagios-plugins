#!/usr/bin/env sh
# Copyright bitly, Aug 2011
# written by Jehiah Czebotar
#
# Adapted from https://gist.github.com/internetstaff/11269560

DATAFILE='/tmp/nagios_check_forkrate.dat'
VALID_INTERVAL=60

function usage() {
  echo "usage: $0 --warning <int> --critical <int>"
  echo "this script checks the rate processes are created"
  echo "and alerts when it goes above a certain threshold"
  echo "it saves the value from each run in $DATAFILE"
  echo "and computes a delta on the next run. It will ignore"
  echo "any values that are older than --valid-interval=$VALID_INTERVAL (seconds)"
  echo "warn and critical values are in # of new processes per second"
}

while test -n "$1"; do
  case $1 in
    -w | --warning)
      warning_treshold=$2
      ;;
    -c | --critical)
      critical_treshold=$2
      ;;
    -i | --valid-interval)
      valid_interval=$2
      ;;
    -h | --help)
      usage
      exit 0;
      ;;
  esac
  shift
done

if test -z "$warning_treshold" || test -z "$critical_treshold"; then
  echo "Error: --warning and --critical parameters are required"
  exit 3
fi

if test $warning_treshold -ge $critical_treshold; then
  echo "Error: --warn ($warning_treshold) can't be greater than --critical ($critical_treshold)"
  exit 3
fi

NOW=$(date +%s)
min_valid_ts=$(expr $NOW - $VALID_INTERVAL)
current_process_count=$(awk '/processes/ {print $2}' /proc/stat)

if test ! -f $DATAFILE; then
  echo -e "$NOW\t$current_process_count" > $DATAFILE
  echo "Missing $DATAFILE; creating"
  exit 0
fi

# now compare this to previous
mv $DATAFILE{,.previous}
while read ts process_count; do
  if test $ts -lt $min_valid_ts; then
    continue
  fi

  if test $ts -ge $NOW; then
    # we can't use data from the same second
    continue
  fi

  # calculate the rate
  process_delta=$(expr $current_process_count - $process_count)
  ts_delta=$(expr $NOW - $ts)
  current_fork_rate=$(expr $process_delta \/ $ts_delta)
  echo -e "$ts\t$process_count" >> $DATAFILE
done < $DATAFILE.previous

echo -e "$NOW\t$current_process_count" >> $DATAFILE
output="fork rate is $current_fork_rate processes/second (based on the last $ts_delta seconds) | fork_rate=$current_fork_rate"

if test $current_fork_rate -ge $critical_treshold; then
  echo "CRITICAL: $output"
  exit 2
fi

if test $current_fork_rate -ge $warning_treshold; then
  echo "WARNING: $output"
  exit 1
fi

echo "OK: $output"
exit 0
