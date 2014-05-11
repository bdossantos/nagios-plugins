#!/usr/bin/env sh

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

PROGNAME=$(basename $0)
VERSION='Version 0.1.0'
AUTHOR='MAB (MAB@MAB.NET), Based on Mike Adolphs (http://www.matejunkie.com/) check_nginx.sh code'

hostname='127.0.0.1'
port=6379
output_dir='/tmp'
secure=0

print_version() {
    echo "$VERSION $AUTHOR"
}

print_help() {
    print_version $PROGNAME $VERSION
    echo ""
    echo "$PROGNAME is a Nagios plugin to check redis. (http://redis.io)"
    echo "It also parses the redis info output to get used memory, changes "
    echo "current connections, etc..."
    echo ""
    echo "$PROGNAME -H localhost -P 6379 -o /tmp [-w INT] [-c INT]"
    echo ""
    echo "Options:"
    echo "  -H/--hostname)"
    echo "     Defines the hostname. Default is: localhost"
    echo "  -P/--port)"
    echo "     Defines the port. Default is: 80"
    echo "  -p/--password)"
    echo "     Name of the server's status page defined in the location"
    echo "     directive of your nginx configuration. Default is:"
    echo "  -o/--output-directory)"
    echo "     Specifies where to write the tmp-file that the check creates."
    echo "     Default is: /tmp"
    echo "  -w/--warning)"
    echo "     Sets a warning level for used_memory. Default is: off"
    echo "  -c/--critical)"
    echo "     Sets a critical level for used_memory. Default is:"
    echo "     off"
    exit 3
}

while test -n "$1"; do
    case "$1" in
        -help|-h)
            print_help
            exit 3
            ;;
        --version|-v)
            print_version $PROGNAME $VERSION
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
        --password|-p)
            secure=1
            password=$2
            ;;
        --output-directory|-o)
            output_dir=$2
            shift
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
        echo "Please adjust your warning/critical thresholds. The warning must be lower than the critical level!"
        exit 3
    elif [ "$wcdiff" = 2 ]
    then
        echo "Please also set a critical value when you want to use warning/critical thresholds!"
        exit 3
    elif [ "$wcdiff" = 3 ]
    then
        echo "Please also set a warning value when you want to use warning/critical thresholds!"
        exit 3
    fi
}

check_pid() {
    if [ -f "$path_pid/$name_pid" ]
    then
        retval=0
    else
        retval=1
    fi
}

get_status() {
    filename=${output_dir}/${PROGNAME}-${hostname}.1
    if [ "$secure" = 1 ]
    then
        redis-cli -h $hostname -p $port  -a $password info > ${filename}
    else
        redis-cli -h $hostname -p $port  info > ${filename}
    fi
}

get_vals() {
    used_memory=$(grep used_memory ${filename} | grep -v human | awk -F: '{print $2}' | tr -d '\r')
    used_memory_human=$(grep used_memory_human ${filename} | awk -F: '{print $2}' | tr -d '\r')
    changes_since_last_save=$(grep changes_since_last_save ${filename} | awk -F: '{print $2}' | tr -d '\r')
    connected_clients=$(grep connected_clients ${filename} | awk -F: '{print $2}' | tr -d '\r')
    connected_slaves=$(grep connected_slaves ${filename} | awk -F: '{print $2}' | tr -d '\r')
    uptime_in_days=$(grep uptime_in_days ${filename} | awk -F: '{print $2}' | tr -d '\r')
    db0keys=$(grep db0 ${output_dir}/$PROGNAME-${hostname}.1 | awk -F, '{print $1}' | awk -F= '{print $2}' | tr -d '\r')
    db0expires=$(grep db0 ${output_dir}/$PROGNAME-${hostname}.1 | awk -F, '{print $2}' | awk -F= '{print $2}' | tr -d '\r')

    rm -f ${filename}
}

do_output() {
output="Redis is using \
$used_memory_human of RAM; \
$uptime_in_days days up; \
$changes_since_last_save Changes; \
$connected_clients Clients; \
$connected_slaves Slaves; \
DB0 ($db0keys keys $db0expires expires)"
}

do_perfdata() {
    perfdata="'Memory'=$used_memory_human 'Clients'=$connected_clients 'DB0.keys'=$db0keys"
}

# Here we go!
get_wcdiff
val_wcdiff
get_status

if [ ! -s "$filename" ]; then
    echo "CRITICAL - Could not connect to server"
    exit 2
else
    get_vals
    if [ -z "$used_memory_human" ]; then
        echo "CRITICAL - Error parsing server output"
        exit 2
    else
      do_output
      do_perfdata
    fi
fi

if [ -n "$warning" -a -n "$critical" ]
then
    if [ "$used_memory" -ge "$warning" -a "$used_memory" -lt "$critical" ]
    then
        echo "WARNING - ${output} | ${perfdata}"
        exit 2
    elif [ "$used_memory" -ge "$critical" ]
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
