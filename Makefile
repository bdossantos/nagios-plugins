SHELL := /usr/bin/env bash
BATS_DIR := /tmp/bats

test: deps
	@$(BATS_DIR)/bin/bats test

deps:
	@[ -d $(BATS_DIR) ] || \
		git clone -q --depth 1 https://github.com/sstephenson/bats.git $(BATS_DIR)

clean:
	@rm -rf $(BATS_DIR)
