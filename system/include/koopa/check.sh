#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

_koopa_assert_is_installed R Rscript

export KOOPA_FORCE=1
set +u
# shellcheck disable=SC1090
source "${koopa_prefix}/activate"
set -u

Rscript --vanilla "${script_dir}/check.R"

_koopa_disk_check
