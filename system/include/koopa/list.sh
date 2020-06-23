#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)"

_koopa_assert_is_installed Rscript

Rscript --vanilla "${script_dir}/list.R"
