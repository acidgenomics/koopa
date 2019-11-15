#!/usr/bin/env bash
set -Eeu -o pipefail

KOOPA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." \
    >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
source "${KOOPA_HOME}/shell/bash/include/header.sh"
_koopa_assert_is_darwin
