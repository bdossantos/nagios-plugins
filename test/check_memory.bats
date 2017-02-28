#!/usr/bin/env bats

load test_helper

meminfo='MemTotal:       65914216 kB
MemFree:         2649432 kB
MemAvailable:   23368032 kB
Buffers:          179848 kB
Cached:         22858120 kB
SwapCached:            0 kB
Active:         11381036 kB
Inactive:       12305080 kB
Active(anon):    2348508 kB
Inactive(anon):  1584020 kB
Active(file):    9032528 kB
Inactive(file): 10721060 kB
Unevictable:    37812864 kB
Mlocked:        37812864 kB
SwapTotal:       1569780 kB
SwapFree:        1569780 kB
Dirty:             35472 kB
Writeback:             4 kB
AnonPages:      38461012 kB
Mapped:          4710720 kB
Shmem:           3254352 kB
Slab:            1151948 kB
SReclaimable:    1086740 kB
SUnreclaim:        65208 kB
KernelStack:       10272 kB
PageTables:       143336 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    34526888 kB
Committed_AS:   41533500 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      393568 kB
VmallocChunk:   34359133484 kB
HardwareCorrupted:     0 kB
DirectMap4k:        7684 kB
DirectMap2M:     1974272 kB
DirectMap1G:    67108864 kB'

@test 'Test check_memory.sh under warning/critical treshold' {
  stub cat "$meminfo"

  run check_memory.sh --warning 90 --critical 95
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - 61% of memory used (39285 of 64369 MB)'
}

@test 'Test check_memory.sh warning' {
  stub cat "$meminfo"

  run check_memory.sh --warning 60 --critical 95
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - 61% of memory used (39285 of 64369 MB)'
}

@test 'Test check_memory.sh critical' {
  stub cat "$meminfo"

  run check_memory.sh --warning 50 --critical 60
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - 61% of memory used (39285 of 64369 MB)'
}

@test 'Test check_memory.sh unknown' {
  stub cat ''

  run check_memory.sh --warning 85 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Error'
}
