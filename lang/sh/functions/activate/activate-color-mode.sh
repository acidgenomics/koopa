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
        __kvar_applied="${HOME:?}/.cache/koopa/color-mode-applied"
        __kvar_applied_cached=''
        [ -f "$__kvar_applied" ] && \
            read -r __kvar_applied_cached < "$__kvar_applied" 2>/dev/null || true
        if [ ! -f "$__kvar_applied" ] || \
            [ "$__kvar_applied_cached" != "$KOOPA_COLOR_MODE" ]
        then
            if [ -z "${KOOPA_COLOR_MODE_SYNCING:-}" ]
            then
                if _koopa_is_interactive
                then
                    "${KOOPA_PREFIX:?}/bin/koopa" configure user color-mode \
                        >>/dev/null 2>&1
                else
                    "${KOOPA_PREFIX:?}/bin/koopa" configure user color-mode \
                        >>/dev/null 2>&1 &
                fi
            fi
        fi
        unset -v __kvar_applied __kvar_applied_cached
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
