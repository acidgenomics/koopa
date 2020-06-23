#!/usr/bin/env bash

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

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)"
koopa_prefix="$(cd "${script_dir}/.." &>/dev/null && pwd -P)"

rm -fr "${koopa_prefix}/coverage"

# --bash-path="/usr/local/bin/bash"
bashcov \
    --root="$koopa_prefix" \
    "${script_dir}/shunit2.sh"
