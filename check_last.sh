#!/usr/bin/env bash
#
# Return last logged in user
#
# Usage: check_last.sh
#     -h, --help            Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
  --help | -h)
    sed -n '2,7p' "$0" | tr -d '#'
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

last | tac | tail -n 1
exit $?
