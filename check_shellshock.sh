#!/usr/bin/env bash
#
# Check bash for CVE-2014-6271 (shellshock)
# http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-6271
#
# Usage: check_shellshock.sh
#     -h, --help            Display this screen
#
# (c) 2014, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
# https://github.com/bdossantos/nagios-plugins
#
# Basics from https://github.com/Voxer/nagios-plugins/blob/master/check_shellshock
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

vuln=$(foo='() { :; }; echo vulnerable' bash -c true 2>/dev/null)
code=$?

if [[ $code -ne 0 ]]; then
  echo "UNKNOWN - bash return ${code}"
  exit 3
elif [[ $vuln == vulnerable ]]; then
  echo 'CRITICAL - bash is vulnerable to shellshock'
  exit 2
else
  echo 'OK - bash is secure against shellshock'
  exit 0
fi
