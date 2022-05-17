#!/usr/bin/env bash

koopa_is_export() {
    # """
    # Is a variable exported in the current shell session?
    # @note Updated 2022-02-17.
    #
    # Use 'export -p' (POSIX) instead of 'declare -x' (Bashism).
    #
    # See also:
    # - https://unix.stackexchange.com/questions/390831
    #
    # @examples
    # > koopa_is_export 'KOOPA_SHELL'
    # """
    local arg exports
    koopa_assert_has_args "$#"
    exports="$(export -p)"
    for arg in "$@"
    do
        koopa_str_detect_regex \
            --string="$exports" \
            --pattern="\b${arg}\b=" \
        || return 1
    done
    return 0
}
