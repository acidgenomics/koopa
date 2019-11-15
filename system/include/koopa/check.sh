#!/usr/bin/env bash
set -Eeu -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

Rscript --vanilla "${script_dir}/check.R"

_koopa_disk_check
_koopa_is_azure && _koopa_check_azure
