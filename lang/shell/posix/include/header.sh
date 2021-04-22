#!/bin/sh

_koopa_posix_header() { # {{{1
    # """
    # POSIX shell header.
    # @note Updated 2021-01-19.
    # """
    local file
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        exit 1
    fi
    # Source POSIX functions.
    # Use shell globbing instead of 'find', which doesn't support source.
    for file in "${KOOPA_PREFIX}/lang/shell/posix/functions/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
}

_koopa_posix_header "$@"
