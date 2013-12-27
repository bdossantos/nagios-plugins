# Various Nagios plugins

## Check bandwidth

### Options

```
-iface/--interface)
    Interface name (eth0 by default)

-s/--sleep)
    Sleep time between both statistics measures

-w/--warning)
    Warning value (KB/s)

-c/--critical)
    Critical value (KB/s)
```

### Usage

```bash
check_bandwidth.sh -iface eth0 -w 5000 -c 6000
```

## Check conntrack table

### Options

```
$1
    warning percent of conntrack table

$2
    critical percent of conntrack table
```

### Usage

```bash
check_max_conntrack.sh 75 90
```

## Check DDOS (SYN Flood)

### Options

```
-w/--warning)
    Warning value (number of SYN_RECV)

-c/--critical)
    Critical value (number of SYN_RECV)
```

### Usage

```bash
check_ddos.sh -w 100 -c 150
```

## Check number of opened files

### Options

```
$1
    warning percent of max open file system can handle : /proc/sys/fs/file-max

$2
    critical percent of max open file system can handle
```

### Usage

```bash
check_max_open_files.sh 75 90
```

## Check last user

## Check CouchDB

### Options

```
-H/--hostname)
  CouchDB host

-P/--port)
  CouchDB port
```

### Usage

```bash
check_couchdb.sh -H 127.0.0.1 -P 5984
```

## Check MySQL

### Options

```
-u/--user)
  The user name

-p/--password)
  User password

-f/--defaults-file)
  MySQL defaults-file path
```
