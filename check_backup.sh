#!/usr/bin/env bash
# Quick and dirty script to check if backup failed, in log we trust.

while test -n "$1"; do
  case $1 in
    -l|--log)
      backup_log=$2
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 3
      ;;
  esac
  shift
done

TODAY=$(date +"%Y/%m/%d")
YESTERDAY=$(date --date="yesterday" +"%Y/%m/%d")

if test -z $backup_log; then
  echo "CRITICAL - the path to backup log file is not defined"
  exit 2
fi

if test ! -f $backup_log; then
  echo "CRITICAL - ${backup_log} does not exist !"
  exit 2
fi

if egrep "$TODAY|$YESTERDAY" $backup_log | grep -q -i 'error'; then
  echo "CRITICAL - ${backup_log} contain error(s)"
  exit 2
fi

if egrep "$TODAY|$YESTERDAY" $backup_log | grep -q -i 'warn'; then
  echo "WARNING - ${backup_log} contain warning(s)"
  exit 1
fi

echo "OK - ${backup_log} does not contain any error/warning"
exit 0
