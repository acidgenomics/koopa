#!/usr/bin/env zsh
set -eu -o pipefail

# ZSH shared header script.
# Updated 2020-01-15.

KOOPA_ZSH_INC="$(cd "$(dirname "${(%):-%N}")" >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_ZSH_INC}/../../posix/include/functions.sh"

# Source ZSH functions.
# shellcheck source=/dev/null
# > source "${KOOPA_ZSH_INC}/functions.sh"

_koopa_help "$@"

# Require sudo permission to run 'sbin/' scripts.
if echo "$0" | grep -q "/sbin/"
then
    _koopa_assert_has_sudo
fi

unset -v KOOPA_ZSH_INC
