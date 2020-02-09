#!/usr/bin/env bash

# """
# Bash coverage.
# Updated 2020-02-09.
#
# https://github.com/infertux/bashcov
# """

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"

bashcov --skip-uncovered "${script_dir}/shunit2.sh"
