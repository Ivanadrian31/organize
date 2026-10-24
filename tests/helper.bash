#!/usr/bin/env bash
# Shared helpers for the bats suite.

# shellcheck disable=SC2034 # read by tests/*.bats, which shellcheck cannot see
BIN="$BATS_TEST_DIRNAME/../bin/organize"
# shellcheck disable=SC2034 # read by tests/*.bats, which shellcheck cannot see
BIN_DL="$BATS_TEST_DIRNAME/../bin/organize-dl"

# buat DIR NAME... creates empty files inside DIR
buat() {
	local dir=$1
	shift
	local nama
	for nama in "$@"; do
		: >"$dir/$nama"
	done
}

assert_file() {
	[ -f "$1" ] || {
		printf 'expected a file: %s\n' "$1" >&2
		return 1
	}
}

assert_dir() {
	[ -d "$1" ] || {
		printf 'expected a directory: %s\n' "$1" >&2
		return 1
	}
}

assert_absent() {
	[ ! -e "$1" ] || {
		printf 'expected no such path: %s\n' "$1" >&2
		return 1
	}
}
