setup() {
  export TMP="$BATS_TEST_DIRNAME/tmp"
  export NAGIOS_PLUGINS_DIRECTORY="$TMP/../.."
  export PATH="$NAGIOS_PLUGINS_DIRECTORY:$TMP/stub:$PATH"
  export NAGIOS_BASH_SCRIPTS=$(find "$NAGIOS_PLUGINS_DIRECTORY" -type f -maxdepth 1 -name '*.sh' -print)
}

teardown() {
  [[ -d "$TMP" ]] && rm -rf "$TMP"/*
}

# http://www.nherson.com/blog/2014/01/13/stubbing-system-executables-with-bats
stub() {
  mkdir -p "$BATS_TEST_DIRNAME/tmp/stub"
  echo "echo '$2'" > "$BATS_TEST_DIRNAME/tmp/stub/$1"
  chmod +x "$BATS_TEST_DIRNAME/tmp/stub/$1"
}
