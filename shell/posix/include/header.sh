#!/bin/sh
# shellcheck disable=SC2039

if [ -n "${BASH_VERSION:-}" ]
then
    KOOPA_POSIX_SOURCE="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]
then
    KOOPA_POSIX_SOURCE="${(%):-%N}"
else
    >&2 printf '%s\n' 'ERROR: Unsupported shell.'
    exit 1
fi

KOOPA_POSIX_INC="$(cd "$(dirname "$KOOPA_POSIX_SOURCE")" \
    >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${KOOPA_POSIX_INC}/functions.sh"

unset -v KOOPA_POSIX_INC KOOPA_POSIX_SOURCE

# Ensure koopa prefix is exported, if necessary.

if [ -z "${KOOPA_PREFIX:-}" ]
then
    KOOPA_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." \
        >/dev/null 2>&1 && pwd -P)"
    export KOOPA_PREFIX
fi

# Disable user-defined aliases.
# Primarily intended to reset cp, mv, rf for use inside scripts.
unalias -a
