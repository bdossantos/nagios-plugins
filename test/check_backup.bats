#!/usr/bin/env bats

load test_helper

@test 'Test check_backup.sh without log flag' {
  run check_backup.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - the path to backup log file is not defined'
}

@test 'Test check_backup.sh with absent log file' {
  run check_backup.sh -l $TMP/backup.log
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - $TMP/backup.log does not exist !"
}

@test 'Test backup.sh on a log without any error or warning' {
  # Create fake backup log "on fly", ugly, right ?
  cat <<BACKUP > $TMP/backup.log
[$(date +"%Y/%m/%d %H:%M:%S")][info] [ backup 4.0.1 : ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-linux] ]
[$(date +"%Y/%m/%d %H:%M:%S")][info] Database::MySQL Started...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Using Compressor::Custom for compression.
[$(date +"%Y/%m/%d %H:%M:%S")][info]   Command: '/usr/bin/pigz -p8 -6'
[$(date +"%Y/%m/%d %H:%M:%S")][info]   Ext: '.gz'
[$(date +"%Y/%m/%d %H:%M:%S")][info] Database::MySQL Finished!
[$(date +"%Y/%m/%d %H:%M:%S")][info] Packaging the backup files...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Packaging Complete!
[$(date +"%Y/%m/%d %H:%M:%S")][info] Cleaning up the temporary files...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Storage::SCP Started...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Storing 'sto01.prd.sfo.bds.tld:/backups/sql01.prd.nyc.bds.tld/mysql_all_databases/$(date +"%Y.%m.%d.%H.%M.%S")/mysql_all_databases.tar'...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Cycling Started...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Removing backup package dated $(date --date="yesterday" +"%Y.%m.%d.%H.%M.%S")...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Storage::SCP Finished!
[$(date +"%Y/%m/%d %H:%M:%S")][info] Storage::Local Started...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Storing '/backups/mysql/mysql_all_databases/$(date +"%Y.%m.%d.%H.%M.%S")/mysql_all_databases.tar'...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Cycling Started...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Removing backup package dated 2014.11.12.23.23.05...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Storage::Local Finished!
[$(date +"%Y/%m/%d %H:%M:%S")][info] Cleaning up the package files...
[$(date +"%Y/%m/%d %H:%M:%S")][info] Backup for 'MySQL all_databases (mysql_all_databases)' Completed Successfully in 00:01:16
[$(date +"%Y/%m/%d %H:%M:%S")][info] After Hook Starting...
[$(date +"%Y/%m/%d %H:%M:%S")][info] After Hook Finished.
BACKUP

  run check_backup.sh -l $TMP/backup.log
  [ "$status" -eq 0 ]
  echo "$output" | grep "OK - $TMP/backup.log does not contain any error/warning"
}

@test 'Test backup.sh on a log with warnings' {
  # Inject error to previous backup log
  cat <<BACKUP >> $TMP/backup.log
[$(date +"%Y/%m/%d %H:%M:%S")][warn] Cleaner: Cleanup Warning
[$(date +"%Y/%m/%d %H:%M:%S")][warn]   The temporary packaging folder still exists!
[$(date +"%Y/%m/%d %H:%M:%S")][warn]   '/backups/tmp/mysql_all_databases'
[$(date +"%Y/%m/%d %H:%M:%S")][warn]   It will now be removed.
[$(date +"%Y/%m/%d %H:%M:%S")][warn]
[$(date +"%Y/%m/%d %H:%M:%S")][warn]   Please check the log for messages and/or your notifications
[$(date +"%Y/%m/%d %H:%M:%S")][warn]   concerning this backup: 'MySQL all_databases (mysql_all_databases)'
[$(date +"%Y/%m/%d %H:%M:%S")][warn]   The temporary files which had to be removed should not have existed.
BACKUP

  run check_backup.sh -l $TMP/backup.log
  [ "$status" -eq 1 ]
  echo "$output" | grep "WARNING - $TMP/backup.log contain warning(s)"
}

@test 'Test backup.sh on a log with errors' {
  # Inject error to previous backup log
  cat <<BACKUP >> $TMP/backup.log
[$(date +"%Y/%m/%d %H:%M:%S")][error] Model::Error: Backup for MySQL all_databases (mysql_all_databases) Failed!
[$(date +"%Y/%m/%d %H:%M:%S")][error] --- Wrapped Exception ---
[$(date +"%Y/%m/%d %H:%M:%S")][error] Database::MySQL::Error: Dump Failed!
[$(date +"%Y/%m/%d %H:%M:%S")][error]   Pipeline STDERR Messages:
[$(date +"%Y/%m/%d %H:%M:%S")][error]   (Note: may be interleaved if multiple commands returned error messages)
[$(date +"%Y/%m/%d %H:%M:%S")][error]
[$(date +"%Y/%m/%d %H:%M:%S")][error]   Error: Couldn't read status information for table tmp_blabla ()
[$(date +"%Y/%m/%d %H:%M:%S")][error]   mysqldump: Couldn't execute 'show create table 'tmp_blabla': Table 'my_big_db.tmp_blabla' doesn't exist (1146)
[$(date +"%Y/%m/%d %H:%M:%S")][error]   The following system errors were returned:
[$(date +"%Y/%m/%d %H:%M:%S")][error]   Errno::ENOENT: No such file or directory - 'mysqldump' returned exit code: 2
BACKUP

  run check_backup.sh -l $TMP/backup.log
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - $TMP/backup.log contain error(s)"
}
