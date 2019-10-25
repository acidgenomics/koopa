#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../linux/include/header.sh"

_koopa_assert_is_debian
