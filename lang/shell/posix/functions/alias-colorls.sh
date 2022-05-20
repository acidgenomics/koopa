#!/bin/sh

koopa_alias_colorls() {
    # """
    # colorls alias.
    # @note Updated 2022-04-14.
    #
    # Use of '--git-status' is slow for large directories / monorepos.
    # """
    local color_flag color_mode
    color_mode="$(koopa_color_mode)"
    case "$color_mode" in
        'dark')
            color_flag='--dark'
            ;;
        'light')
            color_flag='--light'
            ;;
    esac
    colorls \
        "$color_flag" \
        --group-directories-first \
            "$@"
    return 0
}
