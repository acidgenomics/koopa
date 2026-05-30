#!/usr/bin/env zsh

_koopa_activate_color_mode() {
    if [[ "$OSTYPE" == darwin* ]]
    then
        if _koopa_is_light_mode
        then
            KOOPA_COLOR_MODE='light'
        else
            KOOPA_COLOR_MODE='dark'
        fi
        local cache_file="${HOME:?}/.cache/koopa/color-mode"
        if [[ ! -f "$cache_file" ]]
        then
            mkdir -p "${cache_file%/*}"
            printf '%s\n' "$KOOPA_COLOR_MODE" > "$cache_file"
        fi
    elif [[ -z "${KOOPA_COLOR_MODE:-}" ]]
    then
        KOOPA_COLOR_MODE="$(_koopa_color_mode)"
    fi
    if [[ -n "${KOOPA_COLOR_MODE:-}" ]]
    then
        export KOOPA_COLOR_MODE
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
