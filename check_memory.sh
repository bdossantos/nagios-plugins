#!/usr/bin/env sh
# Check memory usage
#
# Options :
#
#   -w/--warning)
#       Warning value (percent)
#
#   -c/--critical)
#       Critical value (percent)

while test -n "$1"; do
  case $1 in
    --warning|-w)
      warn=$2
      shift
      ;;
    --critical|-c)
      crit=$2
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 3
      ;;
  esac
  shift
done

warn=${warn:=90}
crit=${crit:=95}

memory_total=$(free | fgrep "Mem:" | awk '{print $2}')
memory_used=$(free | fgrep "/+ buffers/cache" | awk '{print $3}')
percentage=$(expr $memory_used \* 100 \/ $memory_total)
status="${percentage}% ($(expr $memory_used \/ 1024) of $(expr $memory_total \/ 1024)) MB used";

if [ $percentage -gt $crit ]; then
  echo "CRITICAL - ${status}"
  exit 2
elif [ $percentage -gt $warn ]; then
  echo "WARNING - ${status}"
  exit 1
else
  echo "OK - ${status}"
  exit 0
fi

echo "UNKNOWN - Error"
exit 3
