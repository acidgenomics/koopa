#!/bin/sh

_koopa_posix_header() { # {{{1
    # """
    # POSIX shell header.
    # @note Updated 2021-05-24.
    # """
    local file
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        return 1
    fi
    # Source POSIX functions.
    # Use shell globbing instead of 'find', which doesn't support source.
    for file in "${KOOPA_PREFIX}/lang/shell/posix/functions/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    _koopa_check_os || return 1
    _koopa_check_shell || return 1
    return 0
}

_koopa_posix_header "$@"
