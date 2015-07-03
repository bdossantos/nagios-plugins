#!/usr/bin/env bats

load test_helper

@test 'Test check_ssl_cert.sh with SHA1 cert' {
  stub timeout ''
  stub openssl ''
  stub grep 'Signature Algorithm: sha1WithRSAEncryption'

  run check_ssl_cert.sh --warning 15 --critical 7 --host monitoringsuck --port 443
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - SSL Certificate is SHA1'
}

@test 'Test check_ssl_cert.sh with far expiration date' {
  # fake `timeout $timeout openssl s_client -connect $host:$port < /dev/null 2>&1 | openssl x509 -enddate -noout | cut -d '=' -f2` output
  stub timeout ''
  stub openssl ''
  stub cut "$(date -d '+1337 days')"

  run check_ssl_cert.sh --warning 15 --critical 7 --host monitoringsuck --port 443
  [ "$status" -eq 0 ]
  [ "$output" = 'OK - 1337 days left - monitoringsuck:443' ]
}

@test 'Test check_ssl_cert.sh with warn expiration date' {
  # fake `timeout $timeout openssl s_client -connect $host:$port < /dev/null 2>&1 | openssl x509 -enddate -noout | cut -d '=' -f2` output
  stub timeout ''
  stub openssl ''
  stub cut "$(date -d '+8 days')"

  run check_ssl_cert.sh --warning 15 --critical 7 --host monitoringsuck --port 443
  [ "$status" -eq 1 ]
  [ "$output" = 'WARNING - 8 days left - monitoringsuck:443' ]
}

@test 'Test check_ssl_cert.sh with critical expiration date' {
  # fake `timeout $timeout openssl s_client -connect $host:$port < /dev/null 2>&1 | openssl x509 -enddate -noout | cut -d '=' -f2` output
  stub timeout ''
  stub openssl ''
  stub cut "$(date -d '+2 days')"

  run check_ssl_cert.sh --warning 15 --critical 7 --host monitoringsuck --port 443
  [ "$status" -eq 2 ]
  [ "$output" = 'CRITICAL - 2 days left - monitoringsuck:443' ]
}

@test 'Test check_ssl_cert.sh when unable to fetch cert expiration date' {
  # fake `timeout $timeout openssl s_client -connect $host:$port < /dev/null 2>&1 | openssl x509 -enddate -noout | cut -d '=' -f2` output
  stub timeout ''
  stub openssl ''
  stub cut ''

  run check_ssl_cert.sh --warning 15 --critical 7 --host monitoringsuck --port 443
  [ "$status" -eq 2 ]
  [ "$output" = 'CRITICAL - 0 days left - monitoringsuck:443' ]
}
