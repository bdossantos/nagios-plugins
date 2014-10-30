#!/usr/bin/env bash
#
# Check SSL certificate
#
# Options :
#
#   -w/--warning)
#       Warning numbers of days left
#
#   -c/--critical)
#       Critical numbers of days left
#
#   -h/--host)
#       Hostname
#
#   -p/--port)
#       port, eg: 443
#
#   -t/--timeout)
#       timeout, eg: 10s
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    -h | --host)
      host=$2
      ;;
    -p | --port)
      port=$2
      ;;
    -t | --timeout)
      timeout=$2
      ;;
    -w | --warning)
      warn=$2
      ;;
    -c | --critical)
      crit=$2
      ;;
    -h | --help)
      usage
      exit 0;
      ;;
  esac
  shift
done

host=${host:=localhost}
port=${port:=443}
timeout=${timeout:=30s}
warn=${warn:=15}
crit=${crit:=7}

expire=$(timeout $timeout openssl s_client -connect $host:$port < /dev/null 2>&1 | openssl x509 -enddate -noout | cut -d '=' -f2)
parsed_expire=$(date -d "$expire" +%s)
today=$(date +%s)
days_until=$(echo "($parsed_expire - $today) / (60 * 60 * 24)" | bc)

if [[ $days_until -lt 0 ]]; then
  echo "CRITICAL - Expired ${days_until} days ago - ${host}:${port}"
  exit 2
elif [[ $days_until -lt $crit ]]; then
  echo "CRITICAL - ${days_until} days left - ${host}:${port}"
  exit 2
elif [[ $days_until -lt $warn ]]; then
  echo "WARNING - ${days_until} days left - ${host}:${port}"
  exit 1
else
  echo "OK - ${days_until} days left - ${host}:${port}"
  exit 0
fi
