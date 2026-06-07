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
    elif [[ -z "${KOOPA_COLOR_MODE:-}" ]]
    then
        KOOPA_COLOR_MODE="$(_koopa_color_mode)"
    fi
    if [[ -n "${KOOPA_COLOR_MODE:-}" ]]
    then
        export KOOPA_COLOR_MODE
        local cache_file="${HOME:?}/.cache/koopa/color-mode"
        if [[ ! -f "$cache_file" ]] || \
            [[ "$(<"$cache_file")" != "$KOOPA_COLOR_MODE" ]]
        then
            mkdir -p "${cache_file%/*}"
            printf '%s\n' "$KOOPA_COLOR_MODE" > "$cache_file"
        fi
        local applied_file="${HOME:?}/.cache/koopa/color-mode-applied"
        if [[ ! -f "$applied_file" ]] || \
            [[ "$(<"$applied_file")" != "$KOOPA_COLOR_MODE" ]]
        then
            if [[ -z "${KOOPA_COLOR_MODE_SYNCING:-}" ]]
            then
                if _koopa_is_interactive
                then
                    "${KOOPA_PREFIX:?}/bin/koopa" configure user color-mode \
                        >>/dev/null 2>&1
                else
                    "${KOOPA_PREFIX:?}/bin/koopa" configure user color-mode \
                        >>/dev/null 2>&1 &!
                fi
            fi
        fi
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
