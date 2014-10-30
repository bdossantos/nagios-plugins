#!/usr/bin/env bash
#
# Check application health
#
# Usage: check_application_health.sh [-w webroot] [-c command] [-t timeout]
#     -w, --webroot         Path to webroot
#     -c, --command         Healthcheck command
#     -t, --timeout         timeout, eg: 10s
#     -h, --help            Display this screen
#
# eg: check_application_health.sh \
#         -w '/var/www/myapp.io/current' \
#         -c 'php app/console monitor:health'
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
