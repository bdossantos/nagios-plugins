#!/usr/bin/env bash
#
# Check php-fpm pool status
#
# Usage: check_php_fpm.sh.sh [-h host] [-p port] [-w warning] [-c critical] [-s status page] [-S secure]
#   -h, --host                  php-fpm status page host
#   -p, --port                  php-fpm status page port, eg: 80
#   -w, --warning WARNING       Warning value (percent)
#   -c, --critical CRITICAL     Critical value (percent)
#   -S, --secure                Use HTTPS instead of HTTP
#   -s, --status-page           Name of the php-fpm status page
#   -H, --help                  Display this screen
#
# This plugin is based on this work :
# https://github.com/mabitt/mab-nagios-plugins/blob/master/check_phpfpm.sh
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
    --host | -h)
      host=$2
      shift
      ;;
    --port | -p)
      port=$2
      shift
      ;;
    --warning | -w)
      warning=$2
      shift
      ;;
    --critical | -c)
      critical=$2
      shift
      ;;
    --status-page | -s)
      status_page=$2
      shift
      ;;
    --secure | -S)
      secure=$2
      shift
      ;;
    --help | -H)
      sed -n '2,13p' "$0" | tr -d '#'
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

host=${host:=127.0.0.1}
port=${port:=80}
secure=${secure:=0}
status_page=${status_page:='status'}
warning=${warning:=90}
critical=${critical:=95}

if [[ $warning -ge $critical ]]; then
  echo "UNKNOWN - warning ($warning) can't be greater than critical ($critical)"
  exit 3
fi

if [[ "$secure" = 1 ]]; then
  status=$(wget --no-check-certificate -q -t 3 -T 3 \
    "https://${host}:${port}/${status_page}" -O -)
else
  status=$(wget -q -t 3 -T 3 "http://${host}:${port}/${status_page}" -O -)
fi

if [[ $? -ne 0 ]] || [[ -z $status ]]; then
  echo "CRITICAL - could not fetch php-fpm pool status page \
${host}:${port}/${status_page}"
  exit 2
fi

active_processes=$(echo "$status" \
  | grep -w 'active processes:' \
  | head -n 1 \
  | awk '{ print $3 }'
)
total_processes=$(echo "$status" \
  | grep 'total processes' \
  | awk '{ print $3 }'
)

if [[ -z $active_processes ]] || [[ -z $total_processes ]]; then
  echo "UNKNOWN - 'active_processes' or 'total_processes' are empty"
  exit 3
fi

used=$((active_processes * 100 / total_processes))
status="${used}% of process pool is used (${active_processes} active processes \
on ${total_processes})";

if [[ $used -gt $critical ]]; then
  echo "CRITICAL - ${status}"
  exit 2
elif [[ $used -gt $warning ]]; then
  echo "WARNING - ${status}"
  exit 1
else
  echo "OK - ${status}"
  exit 0
fi
