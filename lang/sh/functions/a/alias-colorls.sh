#!/bin/sh

_koopa_alias_colorls() {
    # """
    # colorls alias.
    # @note Updated 2023-03-11.
    #
    # Use of '--git-status' is slow for large directories / monorepos.
    # """
    case "$(_koopa_color_mode)" in
        'dark')
            __kvar_color_flag='--dark'
            ;;
        'light')
            __kvar_color_flag='--light'
            ;;
    esac
    colorls \
        "$__kvar_color_flag" \
        --group-directories-first \
        "$@"
    unset -v __kvar_color_flag
    return 0
}
