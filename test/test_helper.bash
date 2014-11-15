setup() {
  export TMP="$BATS_TEST_DIRNAME/tmp"
  export NAGIOS_PLUGINS_DIRECTORY="$TMP/../.."
  export PATH="$NAGIOS_PLUGINS_DIRECTORY:$TMP/bin:$PATH"
  export NAGIOS_BASH_SCRIPTS=$(find "$NAGIOS_PLUGINS_DIRECTORY" -type f -name '*.sh' -print)
}

teardown() {
  [ -d "$TMP" ] && rm -f "$TMP"/*
}
