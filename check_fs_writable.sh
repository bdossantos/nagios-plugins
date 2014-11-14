#!/usr/bin/env bash
#
# Check directory for writability, useful for checking for stale NFS mounts.
#
# Usage: check_fs_writable.sh [-d directory]
#     -d, --directory DIRECTORY     Directory to check for writability
#     -h, --help                    Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#
# Basics from https://github.com/sensu/sensu-community-plugins/blob/master/plugins/system/check-fs-writable.rb
#

while [[ -n "$1" ]]; do
  case $1 in
    --directory|-d)
      directory=$2
      shift
      ;;
    --help|-h)
      sed -n '2,8p' "$0" | tr -d '#'
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

if [[ -z $directory ]]; then
  echo "CRITICAL - the path to directory to check is not defined"
  exit 2
fi

if [[ ! -d $directory ]]; then
  echo "CRITICAL - '${directory}' does not exist!"
  exit 2
fi

readonly FILE="${directory}/.$(hostname -f).$(basename "$0").$$"
trap '[[ -f "${FILE}" ]] && rm -rf "${FILE}"' TERM EXIT

if ! touch "$FILE" 2>/dev/null; then
  echo "CRITICAL - Could not create a file into '${directory}' directory!"
  exit 2
fi

if ! echo 'monitoring suck' > "$FILE" 2>/dev/null; then
  echo "CRITICAL - Could not write into '${FILE}' file!"
  exit 2
fi

echo "OK - '${directory}' directory is writable"
exit 0
