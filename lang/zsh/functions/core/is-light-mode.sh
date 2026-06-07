#!/usr/bin/env zsh

_koopa_is_light_mode() {
    if [[ "$OSTYPE" == darwin* ]]
    then
        [[ "$(/usr/bin/defaults read -g 'AppleInterfaceStyle' 2>/dev/null)" != 'Dark' ]]
    elif [[ -n "${TMUX:-}" || "${TERM:-}" == screen* || "${TERM:-}" == tmux* ]]
    then
        local cache_file="${HOME:?}/.cache/koopa/color-mode"
        [[ -f "$cache_file" ]] && [[ "$(<"$cache_file")" == 'light' ]]
    elif [[ "${TERM_PROGRAM:-}" == 'vscode' ]]
    then
        local cache_file="${HOME:?}/.cache/koopa/color-mode"
        [[ -f "$cache_file" ]] && [[ "$(<"$cache_file")" == 'light' ]]
    else
        _koopa_terminal_is_light_background
    fi
}
