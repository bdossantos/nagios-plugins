#!/usr/bin/env bash
#
# Check application health
#
# eg : check_application_health.sh \
#         -w '/var/www/myapp.io/current' \
#         -c 'php app/console monitor:health'
#
# Options :
#
#   -w/--webroot)
#       Path to webroot
#
#   -c/--command)
#       Healthcheck command
#
#   -t/--timeout)
#       timeout, eg: 10s
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    -w | --webroot)
      webroot=$2
      ;;
    -c | --command)
      command=$2
      ;;
    -t | --timeout)
      timeout=$2
      ;;
  esac
  shift
done

timeout=${timeout:=30s}

if [[ -z "$webroot" ]] || [[ -z "$command" ]]; then
  echo "CRITICAL - undefined webroot or command"
  exit 2
fi

if [[ ! -d "$webroot" ]]; then
  echo "CRITICAL - webroot directory does not exist"
  exit 2
fi

cd "$webroot"
health=$(timeout -k $timeout $timeout $command)

if [[ $? -ne 0 ]]; then
  echo "CRITICAL - The application is sick, '${command}' return code != 0 !"
  echo "$health"
  exit 2
fi

echo "OK - The application is healthy"
echo "$health"
exit 0
