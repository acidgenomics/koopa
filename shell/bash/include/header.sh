#!/usr/bin/env bash
set -Eeu -o pipefail

# Bash shared header script.
# Updated 2019-09-26.

KOOPA_BASH_INC="$(cd "$(dirname "${BASH_SOURCE[0]}")" \
    >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_BASH_INC}/../../posix/include/functions.sh"

# Source Bash functions.
# shellcheck source=/dev/null
source "${KOOPA_BASH_INC}/functions.sh"

unset -v KOOPA_BASH_INC
