#!/usr/bin/env bash
set -x

# """
# Bash coverage.
# Updated 2020-02-09.
#
# > bashcov --help
#
# Use '--mute' flag to quiet down.
# Use '--skip-uncovered' to only show covered files.
#
# https://github.com/infertux/bashcov
# """

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"
KOOPA_PREFIX="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX

rm -fr "${KOOPA_PREFIX}/coverage"

bashcov \
    --bash-path="/usr/local/bin/bash" \
    --root="$KOOPA_PREFIX" \
    "${script_dir}/shunit2.sh"
