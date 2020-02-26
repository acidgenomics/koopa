#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

_koopa_assert_is_installed R Rscript

Rscript --vanilla "${script_dir}/check.R"

_koopa_disk_check
