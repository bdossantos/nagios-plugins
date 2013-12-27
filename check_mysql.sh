#!/usr/bin/env sh
# Check MySQL plugin for Nagios
#
# Options :
#
#   -u/--user)
#       The user name
#
#   -p/--password)
#       User password
#
#   -f/--defaults-file)
#       MySQL defaults-file path
#

if test "$#" -lt 1; then
  echo "Illegal number of parameters"
  exit 3
fi

while test -n "$1"; do
  case $1 in
    --user|-u)
      user=$2
      shift
      ;;
    --password|-p)
      password=$2
      shift
      ;;
    --defaults-file|-f)
      default_files=$2
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 3
      ;;
  esac
  shift
done

if ! test -z $user; then
  options="${options} -u ${user}"
fi

if ! test -z $password; then
  options="${options} -p${password}"
fi

if ! test -z $default_files; then
  options="${options} --defaults-file=${default_files}"
fi

perf_datas=$(/usr/bin/mysqladmin $options status)
exit_status=$?

echo $perf_datas
exit $exit_status
