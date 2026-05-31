#!/bin/sh

_koopa_activate_color_mode() {
    # """
    # Activate dark / light color mode.
    # @note Updated 2022-04-13.
    # """
    if _koopa_is_macos
    then
        if _koopa_is_light_mode
        then
            KOOPA_COLOR_MODE='light'
        else
            KOOPA_COLOR_MODE='dark'
        fi
    elif [ -z "${KOOPA_COLOR_MODE:-}" ]
    then
        KOOPA_COLOR_MODE="$(_koopa_color_mode)"
    fi
    if [ -n "${KOOPA_COLOR_MODE:-}" ]
    then
        export KOOPA_COLOR_MODE
        __kvar_cache_file="${HOME:?}/.cache/koopa/color-mode"
        __kvar_cached=''
        [ -f "$__kvar_cache_file" ] && \
            read -r __kvar_cached < "$__kvar_cache_file" 2>/dev/null || true
        if [ ! -f "$__kvar_cache_file" ] || \
            [ "$__kvar_cached" != "$KOOPA_COLOR_MODE" ]
        then
            mkdir -p "${__kvar_cache_file%/*}"
            printf '%s\n' "$KOOPA_COLOR_MODE" > "$__kvar_cache_file"
        fi
        unset -v __kvar_cache_file __kvar_cached
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
