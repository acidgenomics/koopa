#!/usr/bin/env bash

_koopa_alias_colorls() {
    local color_flag
    case "$(_koopa_color_mode)" in
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
