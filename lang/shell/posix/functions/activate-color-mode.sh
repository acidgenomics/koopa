#!/bin/sh

koopa_activate_color_mode() { # {{{1
    # """
    # Activate dark / light color mode.
    # @note Updated 2022-04-13.
    # """
    if [ -z "${KOOPA_COLOR_MODE:-}" ]
    then
        KOOPA_COLOR_MODE="$(koopa_color_mode)"
    fi
    if [ -n "${KOOPA_COLOR_MODE:-}" ]
    then
        export KOOPA_COLOR_MODE
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
