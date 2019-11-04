#!/usr/bin/env zsh
set -eu -o pipefail

# ZSH shared header script.
# Updated 2019-11-04.

KOOPA_ZSH_INC="$(cd "$(dirname "${(%):-%N}")" >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_ZSH_INC}/../../posix/include/functions.sh"

# Source ZSH functions.
# shellcheck source=/dev/null
# > source "${KOOPA_ZSH_INC}/functions.sh"

unset -v KOOPA_ZSH_INC
