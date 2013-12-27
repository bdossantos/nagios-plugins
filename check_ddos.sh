#!/usr/bin/env sh
# Check DDOS attack (SYN FLOOD) plugin for Nagios
#
# Options :
#   -w/--warning)
#       Warning value (number of SYN_RECV)
#
#   -c/--critical)
#       Critical value (number of SYN_RECV)

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

warn=${warn:=50}
crit=${crit:=70}
filename='/tmp/check_ddos'

trap "rm -f $filename; exit" EXIT
netstat -an > $filename
syn_recv=$(grep SYN_RECV $filename | wc -l)
perfdata=$(grep SYN_RECV $filename | awk {'print $5'} | cut -f 1 -d ":" | sort | uniq -c | sort -k1,1rn | head -10)

exit_status=3
if [ $syn_recv -ge $warn ]; then
    exit_status=1
    if [ $syn_recv -ge $crit ]; then
        exit_status=2
    fi
    echo "DDOS attack !"
    echo "Top 10 SYN_RECV sources :"
    echo "$perfdata"
else
    echo "No DDOS detected ($syn_recv / $warn)"
    exit_status=0
fi

exit $exit_status