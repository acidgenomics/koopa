#!/usr/bin/env zsh

_koopa_is_light_mode() {
    if [[ "$OSTYPE" == darwin* ]]
    then
        [[ "$(/usr/bin/defaults read -g 'AppleInterfaceStyle' 2>/dev/null)" != 'Dark' ]]
    elif [[ -n "${TMUX:-}" || "${TERM:-}" == screen* || "${TERM:-}" == tmux* ]]
    then
        local tmux_mode=''
        if [[ -n "${TMUX:-}" ]]
        then
            tmux_mode="$(tmux show-environment -g KOOPA_COLOR_MODE 2>/dev/null)"
            tmux_mode="${tmux_mode#KOOPA_COLOR_MODE=}"
        fi
        if [[ "$tmux_mode" == 'light' || "$tmux_mode" == 'dark' ]]
        then
            [[ "$tmux_mode" == 'light' ]]
        else
            local cache_file="${HOME:?}/.cache/koopa/color-mode"
            [[ -f "$cache_file" ]] && [[ "$(<"$cache_file")" == 'light' ]]
        fi
    elif [[ "${TERM_PROGRAM:-}" == 'vscode' ]]
    then
        local cache_file="${HOME:?}/.cache/koopa/color-mode"
        [[ -f "$cache_file" ]] && [[ "$(<"$cache_file")" == 'light' ]]
    else
        _koopa_terminal_is_light_background
    fi
}
