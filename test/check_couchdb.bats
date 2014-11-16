#!/usr/bin/env bats

load test_helper

@test 'Test check_couchdb.sh with fake up and running CouchDB' {
  stub curl '{"couchdb":"Welcome","version":"1.2.1"}'
  run check_couchdb.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - CouchDB is up & running'
}

@test 'Test check_couchdb.sh with KO service' {
  run check_couchdb.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - CouchDB is KO'
}
