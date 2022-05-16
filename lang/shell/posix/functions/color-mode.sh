#!/bin/sh

koopa_color_mode() {
    # """
    # macOS color mode (dark/light) value.
    # @note Updated 2022-04-13.
    # """
    local str
    str="${KOOPA_COLOR_MODE:-}"
    if [ -n "$str" ]
    then
        koopa_print "$str"
        return 0
    fi
    if [ -z "$str" ]
    then
        if koopa_is_macos
        then
            if koopa_macos_is_dark_mode
            then
                str='dark'
            else
                str='light'
            fi
        fi
    fi
    [ -n "$str" ] || return 0
    # Optionally, here's how to write the config to a file:
    # > local conf_file
    # > conf_file="$(koopa_config_prefix)/color-mode"
    # > koopa_print "$str" > "$conf_file"
    koopa_print "$str"
    return 0
}
