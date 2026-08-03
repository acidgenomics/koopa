#!/bin/sh

_koopa_is_light_mode() {
    if _koopa_is_macos
    then
        __kvar_cache_file="${HOME:?}/.cache/koopa/color-mode"
        if [ -f "$__kvar_cache_file" ]
        then
            __kvar_mode=''
            read -r __kvar_mode < "$__kvar_cache_file" 2>/dev/null
            [ "$__kvar_mode" = 'light' ]
            __kvar_result=$?
            unset -v __kvar_cache_file __kvar_mode
            return "$__kvar_result"
        fi
        unset -v __kvar_cache_file
        [ "$(/usr/bin/defaults read -g 'AppleInterfaceStyle' 2>/dev/null)" != 'Dark' ]
    else
        __kvar_in_multiplexer=0
        case "${TERM:-}" in screen*|tmux*) __kvar_in_multiplexer=1 ;; esac
        [ -n "${TMUX:-}" ] && __kvar_in_multiplexer=1
        if [ "$__kvar_in_multiplexer" -eq 1 ]
        then
            unset -v __kvar_in_multiplexer
            __kvar_tmux_mode=''
            if [ -n "${TMUX:-}" ]
            then
                __kvar_tmux_mode="$(tmux show-environment -g KOOPA_COLOR_MODE 2>/dev/null)" \
                    || __kvar_tmux_mode=''
                case "$__kvar_tmux_mode" in
                    KOOPA_COLOR_MODE=*)
                        __kvar_tmux_mode="${__kvar_tmux_mode#KOOPA_COLOR_MODE=}"
                        ;;
                    *)
                        __kvar_tmux_mode=''
                        ;;
                esac
            fi
            case "$__kvar_tmux_mode" in
                light|dark)
                    [ "$__kvar_tmux_mode" = 'light' ]
                    __kvar_result=$?
                    unset -v __kvar_tmux_mode
                    return "$__kvar_result"
                    ;;
            esac
            unset -v __kvar_tmux_mode
            __kvar_cache_file="${HOME:?}/.cache/koopa/color-mode"
            if [ -f "$__kvar_cache_file" ]
            then
                __kvar_mode=''
                read -r __kvar_mode < "$__kvar_cache_file" 2>/dev/null
                [ "$__kvar_mode" = 'light' ]
                __kvar_result=$?
                unset -v __kvar_cache_file __kvar_mode
                return "$__kvar_result"
            fi
            unset -v __kvar_cache_file
            return 1
        fi
        unset -v __kvar_in_multiplexer
        if [ "${TERM_PROGRAM:-}" = 'vscode' ]
        then
            __kvar_cache_file="${HOME:?}/.cache/koopa/color-mode"
            if [ -f "$__kvar_cache_file" ]
            then
                __kvar_mode=''
                read -r __kvar_mode < "$__kvar_cache_file" 2>/dev/null
                [ "$__kvar_mode" = 'light' ]
                __kvar_result=$?
                unset -v __kvar_cache_file __kvar_mode
                return "$__kvar_result"
            fi
            unset -v __kvar_cache_file
            return 1
        fi
        if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_TTY:-}" ]
        then
            __kvar_cache_file="${HOME:?}/.cache/koopa/color-mode"
            if [ -f "$__kvar_cache_file" ]
            then
                __kvar_mode=''
                read -r __kvar_mode < "$__kvar_cache_file" 2>/dev/null
                [ "$__kvar_mode" = 'light' ]
                __kvar_result=$?
                unset -v __kvar_cache_file __kvar_mode
                return "$__kvar_result"
            fi
            unset -v __kvar_cache_file
            return 1
        fi
        _koopa_terminal_is_light_background
    fi
}
