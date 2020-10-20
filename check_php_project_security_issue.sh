#!/usr/bin/env bash
#
# Check PHP-lol project security
#
# Usage: check_php_project_security_issue.sh [-f file]
#     -f, --file            Path to composer.lock
#     -h, --help            Display this screen
#
# eg: check_php_project_security_issue.sh \
#         -f '/path/to/composer.lock'
#
# (c) 2015, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#

while [[ -n "$1" ]]; do
  case $1 in
  -f | --file)
    file=$2
    shift
    ;;
  --help | -h)
    sed -n '2,10p' "$0" | tr -d '#'
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

if [[ -z "$file" ]]; then
  echo "CRITICAL - path to composer.lock is not provided"
  exit 2
fi

if [[ ! -f "$file" ]]; then
  echo "CRITICAL - composer.lock does not exist"
  exit 2
fi

output=$(curl -s -i -H 'Accept: text/plain' -F lock="@${file}" \
  https://security.sensiolabs.org/check_lock)
alerts=$(echo "$output" | grep 'X-Alerts' | cut -d' ' -f2 | tr -d '[:space:]')

if [[ "$alerts" -gt 0 ]]; then
  echo "WARNING - The checker detected ${alerts} package(s) that have known vulnerabilities"
  echo
  echo "$output" | sed -n -e '/Security Report/,$p'
  exit 1
fi

echo "OK - The checker did not detect any known vulnerabilities in your project dependencies."
exit 0
