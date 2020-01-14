#!/usr/bin/env bash
set -Eeu -o pipefail

KOOPA_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." \
    >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/os/ubuntu/include/header.sh"
