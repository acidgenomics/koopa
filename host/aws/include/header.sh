#!/usr/bin/env bash

KOOPA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." \
    >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
source "${KOOPA_HOME}/os/linux/include/header.sh"
