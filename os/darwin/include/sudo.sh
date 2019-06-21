#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/shell/bash/include/functions.sh"

_koopa_assert_has_sudo
_koopa_assert_is_os_darwin
