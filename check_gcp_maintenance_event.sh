#!/usr/bin/env bash
#
# Check GCP instance maintenance event
# https://cloud.google.com/compute/docs/storing-retrieving-metadata#maintenanceevents
#
# Usage: check_gcp_maintenance_event.sh
#     -h, --help            Display this screen
#
# (c) 2017, Benjamin Dos Santos <benjamin.dossantos@gmail.com>
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

event=$(
  curl -s -H 'Metadata-Flavor: Google' \
    http://metadata.google.internal/computeMetadata/v1/instance/maintenance-event \
    2>/dev/null
)

if [[ "$event" == 'MIGRATE_ON_HOST_MAINTENANCE' ]]; then
  echo 'WARNING - Undergoing host maintenance, instance will be migrated'
  exit 1
elif [[ "$event" == 'SHUTDOWN_ON_HOST_MAINTENANCE' ]]; then
  echo 'WARNING - Undergoing host maintenance, instance will be shut down'
  exit 1
elif [[ "$event" == 'NONE' ]]; then
  echo 'OK - No scheduled host maintenance'
  exit 0
fi

echo 'UNKNOWN - Could not fetch maintenance event'
exit 3
