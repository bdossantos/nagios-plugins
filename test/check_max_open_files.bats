#!/usr/bin/env bats

load test_helper

@test 'Test check_max_open_files.sh when max_open_files is not found' {
  # fake awk '{ print $1 }' < /proc/sys/fs/file-nr
  stub awk '1515866'

  # fake `cat /proc/sys/fs/file-max` output (max open files)
  stub cat ''

  run check_max_open_files.sh --warning 75 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep "ERROR - Can't find opened_files / max_open_files"
}

@test 'Test check_max_open_files.sh when opened_files is not found' {
  # fake awk '{ print $1 }' < /proc/sys/fs/file-nr
  stub awk ''

  # fake `cat /proc/sys/fs/file-max` output (max open files)
  stub cat '3271108'

  run check_max_open_files.sh --warning 75 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep "ERROR - Can't find opened_files / max_open_files"
}

@test 'Test check_max_open_files.sh when both opened_files and max_open_files are not found' {
  # fake awk '{ print $1 }' < /proc/sys/fs/file-nr
  stub awk ''

  # fake `cat /proc/sys/fs/file-max` output (max open files)
  stub cat ''

  run check_max_open_files.sh --warning 75 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep "ERROR - Can't find opened_files / max_open_files"
}

@test 'Test check_max_open_files.sh when everything is OK' {
  # fake awk '{ print $1 }' < /proc/sys/fs/file-nr
  stub awk '1515866'

  # fake `cat /proc/sys/fs/file-max` output (max open files)
  stub cat '3271108'

  run check_max_open_files.sh --warning 75 --critical 90
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - 46% (1515866 of 3271108) open files'
}

@test 'Test check_max_open_files.sh when warning treshold is reached' {
  # fake awk '{ print $1 }' < /proc/sys/fs/file-nr
  stub awk '2705866'

  # fake `cat /proc/sys/fs/file-max` output (max open files)
  stub cat '3271108'

  run check_max_open_files.sh --warning 75 --critical 90
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - 82% (2705866 of 3271108) open files'
}

@test 'Test check_max_open_files.sh when critical treshold is reached' {
  # fake awk '{ print $1 }' < /proc/sys/fs/file-nr
  stub awk '3145532'

  # fake `cat /proc/sys/fs/file-max` output (max open files)
  stub cat '3271108'

  run check_max_open_files.sh --warning 75 --critical 90
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - 96% (3145532 of 3271108) open files'
}
