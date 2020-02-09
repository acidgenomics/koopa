#!/usr/bin/env bash

# """
# Python test coverage.
# Updated 2020-02-09.
#
# https://docs.pytest.org/en/latest/getting-started.html
# """

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"
KOOPA_PREFIX="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

_koopa_exit_if_not_installed pytest

tests_dir="${script_dir}/pytest"

pytest \
    --rootdir="$tests_dir"
