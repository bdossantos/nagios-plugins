#!/usr/bin/env bash
# This plugin is based on this work :
# https://github.com/mabitt/mab-nagios-plugins/blob/master/check_phpfpm.sh

PROGNAME=`basename $0`
hostname='127.0.0.1'
port=80
status_page="fpm_status"
output_dir=/tmp
secure=0

print_help() {
  print_version $PROGNAME
  echo ""
  echo "$PROGNAME is a Nagios plugin to check whether php-fpm is running."
  echo "It also parses the php-fpm's status page to get requests and"
  echo "connections per second as well as requests per connection. You"
  echo "may have to alter your nginx/php-fpm configuration so that the plugin"
  echo "can access the server's php-fpm status page."
  echo "The plugin is highly configurable for this reason. See below for"
  echo "available options."
  echo ""
  echo "$PROGNAME -H localhost -P 80 -s fpm_status -o /tmp [-w INT] [-c INT] [-S]"
  echo ""
  echo "Options:"
  echo "  -H/--hostname)"
  echo "     Defines the hostname. Default is: localhost"
  echo "  -P/--port)"
  echo "     Defines the port. Default is: 80"
  echo "  -s/--status-page)"
  echo "     Name of the server's status page defined in the location"
  echo "     directive of your nginx configuration. Default is:"
  echo "     nginx_status"
  echo "  -o/--output-directory)"
  echo "     Specifies where to write the tmp-file that the check creates."
  echo "     Default is: /tmp"
  echo "  -S/--secure)"
  echo "     In case your server is only reachable via SSL, use this"
  echo "     this switch to use HTTPS instead of HTTP. Default is: off"
  echo "  -w/--warning)"
  echo "     Sets a warning level for requests per second. Default is: off"
  echo "  -c/--critical)"
  echo "     Sets a critical level for requests per second. Default is:"
  echo "     off"
  exit 3
}

while test -n "$1"; do
  case "$1" in
    --help|-h)
      print_help
      exit 3
      ;;
    --hostname|-H)
      hostname=$2
      shift
      ;;
    --port|-P)
      port=$2
      shift
      ;;
    --status-page|-s)
      status_page=$2
      shift
      ;;
    --output-directory|-o)
      output_dir=$2
      shift
      ;;
    --secure|-S)
      secure=1
      ;;
    --warning|-w)
      warning=$2
      shift
      ;;
    --critical|-c)
      critical=$2
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      print_help
      exit 3
      ;;
  esac
  shift
done

get_wcdiff() {
  if [ ! -z "$warning" -a ! -z "$critical" ]
  then
    wclvls=1
    if [ ${warning} -gt ${critical} ]
    then
      wcdiff=1
    fi
  elif [ ! -z "$warning" -a -z "$critical" ]
  then
    wcdiff=2
  elif [ -z "$warning" -a ! -z "$critical" ]
  then
    wcdiff=3
  fi
}

val_wcdiff() {
  if [ "$wcdiff" = 1 ]
  then
    echo 'Please adjust your warning/critical thresholds. The warning must be lower than the critical level!'
    exit 3
  elif [ "$wcdiff" = 2 ]
  then
    echo 'Please also set a critical value when you want to use warning/critical thresholds!'
    exit 3
  elif [ "$wcdiff" = 3 ]
  then
    echo 'Please also set a warning value when you want to use warning/critical thresholds!'
    exit 3
  fi
}

get_status() {
  filename=${PROGNAME}-${hostname}-${status_page}.1
  filename=$(echo $filename | tr -d '\/')
  filename=${output_dir}/${filename}

  if [ "$secure" = 1 ]
  then
    wget --no-check-certificate -q -t 3 -T 3 http://${hostname}:${port}/${status_page} -O ${filename}
  else
    wget -q -t 3 -T 3 http://${hostname}:${port}/${status_page} -O ${filename}
  fi
}

get_vals() {
  pool=$(grep pool ${filename}|awk '{print $2}')
  conn=$(grep accepted ${filename}|awk '{print $3}')
  iproc=$(grep idle ${filename}|awk '{print $3}')
  aproc=$(grep active ${filename}|awk '{print $3}')
  tproc=$(grep total ${filename}|awk '{print $3}')
  listql=$(grep listen ${filename} | grep -v max | awk {'print $4'})
  mlistql=$(grep listen ${filename} | grep max | awk {'print $5'})
  mchildren=$(grep children ${filename} | awk {'print $4'})
  rm -f ${filename}
}

do_output() {
    output="php-fpm (${pool}) is running. \
accepted conn: ${conn}; \
idle processes: ${iproc}; \
active processes: ${aproc}; \
total processes: ${tproc}; \
listen queue len: ${listql}; \
max listen queue len: ${mlistql}; \
max children reached: ${mchildren}"
}

do_perfdata() {
  perfdata="'idle'=${iproc} 'active'=${aproc} 'total'=${tproc}"
}

get_wcdiff
val_wcdiff
get_status

if [ ! -s "$filename" ]; then
  echo "CRITICAL - Could not connect to server ${hostname}"
  exit 2
else
  get_vals
  if [ -z "$pool" ]; then
    echo 'CRITICAL - Error parsing server output'
    exit 2
  else
    do_output
    do_perfdata
  fi
fi

if [ -n "$warning" -a -n "$critical" ]
then
  if [ "$aproc" -ge "$warning" -a "$aproc" -lt "$critical" ]
  then
    echo "WARNING - ${output} | ${perfdata}"
    exit 1
  elif [ "$aproc" -ge "$critical" ]
  then
    echo "CRITICAL - ${output} | ${perfdata}"
    exit 2
  else
    echo "OK - ${output} | ${perfdata}"
    exit 0
  fi
else
  echo "OK - ${output} | ${perfdata}"
  exit 0
fi

exit 3
