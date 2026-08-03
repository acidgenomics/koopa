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
    elif [[ -n "${TMUX:-}" ]]
    then
        # Inside tmux, re-derive from the tmux server env rather than trusting
        # an inherited value, which may be stale (days-old server, reattached
        # session). '_koopa_color_mode' would just echo the stale value back.
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
        if _koopa_is_interactive
        then
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
                    local log_file="${XDG_CACHE_HOME:?}/koopa/logs/color-mode.log"
                    mkdir -p "${log_file%/*}"
                    "${KOOPA_PREFIX:?}/bin/koopa" configure user color-mode \
                        >>"$log_file" 2>&1 &!
                fi
            fi
        fi
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
