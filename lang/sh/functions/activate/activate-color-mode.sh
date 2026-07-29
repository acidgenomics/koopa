#!/bin/sh

_koopa_activate_color_mode() {
    # """
    # Activate dark / light color mode.
    # @note Updated 2026-07-29.
    #
    # 'KOOPA_COLOR_MODE' is exported unconditionally, since it's a plain env
    # var that non-interactive consumers can also benefit from. The cache
    # file writes and the background 'koopa configure user color-mode' spawn
    # are interactive-only, since they're filesystem/process side effects
    # that shouldn't fire on every non-interactive shell (e.g. 'scp', 'rsync',
    # git-over-ssh).
    # """
    if _koopa_is_macos
    then
        if _koopa_is_light_mode
        then
            KOOPA_COLOR_MODE='light'
        else
            KOOPA_COLOR_MODE='dark'
        fi
    elif [ -z "${KOOPA_COLOR_MODE:-}" ] || [ -n "${TMUX:-}" ]
    then
        KOOPA_COLOR_MODE="$(_koopa_color_mode)"
    fi
    if [ -n "${KOOPA_COLOR_MODE:-}" ]
    then
        export KOOPA_COLOR_MODE
        if _koopa_is_interactive
        then
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
                    __kvar_log_file="${XDG_CACHE_HOME:?}/koopa/logs/color-mode.log"
                    mkdir -p "${__kvar_log_file%/*}"
                    "${KOOPA_PREFIX:?}/bin/koopa" configure user color-mode \
                        >>"$__kvar_log_file" 2>&1 &
                    unset -v __kvar_log_file
                fi
            fi
            unset -v __kvar_applied __kvar_applied_cached
        fi
    else
        unset -v KOOPA_COLOR_MODE
    fi
    return 0
}
