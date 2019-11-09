#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

Rscript --vanilla "${script_dir}/check.R"

_acid_disk_check
_acid_is_azure && _acid_check_azure
