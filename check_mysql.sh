#!/usr/bin/env bash
#
# Check MySQL plugin for Nagios
#
# Usage: check_mysql.sh [-u user] [-p password] [-f MySQL defaults-file path]
#   -u, --user                  MySQL user name
#   -p, --port                  MySQL user password
#   -f, --defaults-file         MySQL defaults-file path
#   -h, --help                  Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --user | -u)
      user=$2
      shift
      ;;
    --password | -p)
      password=$2
      shift
      ;;
    --defaults-file | -f)
      default_files=$2
      shift
      ;;
    --help | -h)
      sed -n '2,10p' "$0" | tr -d '#'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exec "$0" --help
      exit 3
      ;;
  esac
  shift
done

options=()

if [[ ! -z $user ]]; then
  options=("${options[@]}" "-u ${user}")
fi

if [[ ! -z $password ]]; then
  options=("${options[@]}" "-p${password}")
fi

if [[ ! -z $default_files ]]; then
  options=("${options[@]}" "--defaults-file=${default_files}")
fi

status=$(/usr/bin/mysqladmin "${options[@]}" status)
exit_code=$?

echo "$status"
exit $exit_code
