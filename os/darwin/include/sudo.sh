#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "${KOOPA_DIR}/shell/bash/include/functions.sh"

assert_has_sudo
assert_is_os_darwin
