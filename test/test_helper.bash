#!/usr/bin/env bash

setup() {
  export TMP="$BATS_TEST_DIRNAME/tmp"
  export NAGIOS_PLUGINS_DIRECTORY="$TMP/../.."
  export PATH="$NAGIOS_PLUGINS_DIRECTORY:$TMP/stub:$PATH"
  NAGIOS_BASH_SCRIPTS=$(find "$NAGIOS_PLUGINS_DIRECTORY" -maxdepth 1 -type f -name '*.sh' -print)
  export NAGIOS_BASH_SCRIPTS
  OS="$(uname)"
  export $OS
}

teardown() {
  [[ -d "$TMP" ]] && rm -rf "$TMP"/*
}

# http://www.nherson.com/blog/2014/01/13/stubbing-system-executables-with-bats
stub() {
  exit_code=$3
  [[ -z $exit_code ]] && exit_code=0

  mkdir -p "$BATS_TEST_DIRNAME/tmp/stub"
  cat <<STUB > "$BATS_TEST_DIRNAME/tmp/stub/$1"
#!/usr/bin/env bash

echo '$2'
exit $exit_code
STUB
  chmod +x "$BATS_TEST_DIRNAME/tmp/stub/$1"
}
