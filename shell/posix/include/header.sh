#!/bin/sh
# shellcheck disable=SC2039

koopa::posix_header() { # {{{1
    # """
    # POSIX shell header.
    # @note Updated 2020-07-04.
    # """
    local file
    if [ -z "${KOOPA_PREFIX:-}" ]
    then
        printf "%s\n" "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
        exit 1
    fi
    # Source POSIX functions.
    # Use shell globbing instead of 'find', which doesn't support source.
    for file in "${KOOPA_PREFIX}/shell/posix/functions/"*".sh"
    do
        # shellcheck source=/dev/null
        [ -f "$file" ] && . "$file"
    done
    # Ensure koopa scripts are in path.
    koopa::activate_koopa_paths
    return 0
}

koopa::posix_header
