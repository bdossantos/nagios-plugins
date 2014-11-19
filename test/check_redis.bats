#!/usr/bin/env bats

load test_helper

REDIS_INFO_OUTPUT='# Server
redis_version:2.8.17
redis_git_sha1:ec2814a7
redis_git_dirty:1
redis_build_id:d6bc670aa01e64ab
redis_mode:standalone
os:Linux 3.10.23-xxxx-grs-ipv6-64 x86_64
arch_bits:64
multiplexing_api:epoll
gcc_version:4.7.2
process_id:7800
run_id:5f3ebb8952f010645bf919677e715d0ba4e1072c
tcp_port:6379
uptime_in_seconds:2818129
uptime_in_days:32
hz:10
lru_clock:7119891
config_file:/etc/redis/redis.conf

# Clients
connected_clients:5
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

# Memory
used_memory:8588235368
used_memory_human:8.00G
used_memory_rss:8812318720
used_memory_peak:8596447840
used_memory_peak_human:8.01G
used_memory_lua:33792
mem_fragmentation_ratio:1.03
mem_allocator:jemalloc-3.6.0

# Stats
total_connections_received:748810
total_commands_processed:692402571
instantaneous_ops_per_sec:116
rejected_connections:0
sync_full:1
sync_partial_ok:1
sync_partial_err:0
expired_keys:17424
evicted_keys:5131185
keyspace_hits:563969189
keyspace_misses:4681291
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:111318

# Replication
role:master
connected_slaves:1
slave0:ip=1.2.3.4,port=6379,state=online,offset=19085796802,lag=0
master_repl_offset:19085796802
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:19084748227
repl_backlog_histlen:1048576

# CPU
used_cpu_sys:19462.26
used_cpu_user:13665.37
used_cpu_sys_children:5036.75
used_cpu_user_children:105986.34

# Keyspace
db0:keys=63395707,expires=1728941,avg_ttl=4863268773
db10:keys=12902,expires=0,avg_ttl=0
db11:keys=80530,expires=0,avg_ttl=0
db13:keys=38,expires=0,avg_ttl=0'

@test 'Test check_redis.sh with fake unreachable Redis and default options' {
  [[ $(echo 'info' | nc -w1 127.0.0.1 6379) ]] && skip
  run check_redis.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not connect to redis on 127.0.0.1:6379'
}

@test 'Test check_redis.sh with fake unreachable Redis' {
  run check_redis.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not connect to redis on fakehost:123456'
}

@test 'Test check_redis.sh with fake reachable Redis + empty output' {
  stub nc ''

  run check_redis.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not connect to redis on fakehost:123456'
}

@test 'Test check_redis.sh with fake reachable Redis + no stats in output' {
  stub nc 'fake'

  run check_redis.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not fetch redis stats on fakehost:123456'
}

@test 'Test check_redis.sh with fake reachable Redis' {
  stub nc "$REDIS_INFO_OUTPUT"

  run check_redis.sh --host fakehost --port 123456
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - Redis Memory: 8.00G, Ops/s: 116'
}
