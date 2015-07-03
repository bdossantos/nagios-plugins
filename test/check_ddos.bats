#!/usr/bin/env bats

load test_helper

@test 'Test check_ddos.sh when ok' {
  [[ $OS != 'Linux' ]] && skip 'Skip - not on Linux'

  local netstat_output='Active Internet connections (servers and established)
  Proto Recv-Q Send-Q Local Address           Foreign Address         State
  tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
  tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:36313           0.0.0.0:*               LISTEN
  tcp        0      0 10.0.2.15:22            10.0.2.2:56870          ESTABLISHED
  tcp6       0      0 :::22                   :::*                    LISTEN
  tcp6       0      0 ::1:25                  :::*                    LISTEN
  udp        0      0 0.0.0.0:68              0.0.0.0:*
  udp        0      0 0.0.0.0:58567           0.0.0.0:*
  udp        0      0 0.0.0.0:111             0.0.0.0:*
  udp        0      0 0.0.0.0:756             0.0.0.0:*
  udp        0      0 10.0.2.15:123           0.0.0.0:*
  udp        0      0 127.0.0.1:123           0.0.0.0:*
  udp        0      0 0.0.0.0:123             0.0.0.0:*
  udp6       0      0 fe80::a00:27ff:fe06:123 :::*
  udp6       0      0 ::1:123                 :::*
  udp6       0      0 :::123                  :::*
  Active UNIX domain sockets (servers and established)
  Proto RefCnt Flags       Type       State         I-Node   Path
  unix  2      [ ACC ]     STREAM     LISTENING     3299     /var/run/acpid.socket
  unix  2      [ ]         DGRAM                    1923     @/org/kernel/udev/udevd
  unix  6      [ ]         DGRAM                    3260     /dev/log
  unix  3      [ ]         STREAM     CONNECTED     33200
  unix  3      [ ]         STREAM     CONNECTED     33199
  unix  2      [ ]         DGRAM                    33198
  unix  2      [ ]         DGRAM                    3590
  unix  2      [ ]         DGRAM                    3354
  unix  2      [ ]         DGRAM                    3296
  unix  3      [ ]         DGRAM                    1928
  unix  3      [ ]         DGRAM                    1927'

  stub netstat "$netstat_output"

  run check_ddos.sh -w 42 -c 1337
  [ "$status" -eq 0 ]
  echo "$output" | grep 'No DDOS detected (0 / 42)'
}

@test 'Test check_ddos.sh when warning' {
  [[ $OS != 'Linux' ]] && skip 'Skip - not on Linux'

  local netstat_output='Active Internet connections (servers and established)
  Proto Recv-Q Send-Q Local Address           Foreign Address         State
  tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
  tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:36313           0.0.0.0:*               LISTEN
  tcp        0      0 10.0.2.15:22            10.0.2.2:56870          ESTABLISHED
  tcp        0      0 10.0.2.15:22            10.0.2.2:56871          SYN_RECV
  tcp        0      0 10.0.2.15:22            10.0.2.2:56872          SYN_RECV
  tcp6       0      0 :::22                   :::*                    LISTEN
  tcp6       0      0 ::1:25                  :::*                    LISTEN
  udp        0      0 0.0.0.0:68              0.0.0.0:*
  udp        0      0 0.0.0.0:58567           0.0.0.0:*
  udp        0      0 0.0.0.0:111             0.0.0.0:*
  udp        0      0 0.0.0.0:756             0.0.0.0:*
  udp        0      0 10.0.2.15:123           0.0.0.0:*
  udp        0      0 127.0.0.1:123           0.0.0.0:*
  udp        0      0 0.0.0.0:123             0.0.0.0:*
  udp6       0      0 fe80::a00:27ff:fe06:123 :::*
  udp6       0      0 ::1:123                 :::*
  udp6       0      0 :::123                  :::*
  Active UNIX domain sockets (servers and established)
  Proto RefCnt Flags       Type       State         I-Node   Path
  unix  2      [ ACC ]     STREAM     LISTENING     3299     /var/run/acpid.socket
  unix  2      [ ]         DGRAM                    1923     @/org/kernel/udev/udevd
  unix  6      [ ]         DGRAM                    3260     /dev/log
  unix  3      [ ]         STREAM     CONNECTED     33200
  unix  3      [ ]         STREAM     CONNECTED     33199
  unix  2      [ ]         DGRAM                    33198
  unix  2      [ ]         DGRAM                    3590
  unix  2      [ ]         DGRAM                    3354
  unix  2      [ ]         DGRAM                    3296
  unix  3      [ ]         DGRAM                    1928
  unix  3      [ ]         DGRAM                    1927'

  stub netstat "$netstat_output"

  run check_ddos.sh -w 2 -c 4
  [ "$status" -eq 1 ]
  echo "$output" | grep 'DDOS attack !
  Top 10 SYN_RECV sources :
  2 SYN_RECV'
}

@test 'Test check_ddos.sh when critical' {
  [[ $OS != 'Linux' ]] && skip 'Skip - not on Linux'

  local netstat_output='Active Internet connections (servers and established)
  Proto Recv-Q Send-Q Local Address           Foreign Address         State
  tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
  tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:36313           0.0.0.0:*               LISTEN
  tcp        0      0 10.0.2.15:22            10.0.2.2:56870          ESTABLISHED
  tcp        0      0 10.0.2.15:22            10.0.2.2:56871          SYN_RECV
  tcp        0      0 10.0.2.15:22            10.0.2.2:56872          SYN_RECV
  tcp6       0      0 :::22                   :::*                    LISTEN
  tcp6       0      0 ::1:25                  :::*                    LISTEN
  udp        0      0 0.0.0.0:68              0.0.0.0:*
  udp        0      0 0.0.0.0:58567           0.0.0.0:*
  udp        0      0 0.0.0.0:111             0.0.0.0:*
  udp        0      0 0.0.0.0:756             0.0.0.0:*
  udp        0      0 10.0.2.15:123           0.0.0.0:*
  udp        0      0 127.0.0.1:123           0.0.0.0:*
  udp        0      0 0.0.0.0:123             0.0.0.0:*
  udp6       0      0 fe80::a00:27ff:fe06:123 :::*
  udp6       0      0 ::1:123                 :::*
  udp6       0      0 :::123                  :::*
  Active UNIX domain sockets (servers and established)
  Proto RefCnt Flags       Type       State         I-Node   Path
  unix  2      [ ACC ]     STREAM     LISTENING     3299     /var/run/acpid.socket
  unix  2      [ ]         DGRAM                    1923     @/org/kernel/udev/udevd
  unix  6      [ ]         DGRAM                    3260     /dev/log
  unix  3      [ ]         STREAM     CONNECTED     33200
  unix  3      [ ]         STREAM     CONNECTED     33199
  unix  2      [ ]         DGRAM                    33198
  unix  2      [ ]         DGRAM                    3590
  unix  2      [ ]         DGRAM                    3354
  unix  2      [ ]         DGRAM                    3296
  unix  3      [ ]         DGRAM                    1928
  unix  3      [ ]         DGRAM                    1927'

  stub netstat "$netstat_output"

  run check_ddos.sh -w 1 -c 2
  [ "$status" -eq 2 ]
  echo "$output" | grep 'DDOS attack !
  Top 10 SYN_RECV sources :
  2 SYN_RECV'
}
