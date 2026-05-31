#!/usr/bin/env bash

_koopa_activate_color_mode_sync() {
    _koopa_is_interactive || return 0
    _koopa_bash_color_mode_sync() {
        local new_mode
        if _koopa_is_light_mode
        then
            new_mode='light'
        else
            new_mode='dark'
        fi
        [[ "${KOOPA_COLOR_MODE:-}" != "$new_mode" ]] || return 0
        export KOOPA_COLOR_MODE="$new_mode"
        __koopa_warn "Terminal appearance changed to ${new_mode} mode. Updating shell colors."
        unset -v FZF_DEFAULT_OPTS
        _koopa_activate_fzf
        _koopa_activate_dircolors
        _koopa_activate_difftastic
        if [[ "$new_mode" == 'light' ]]
        then
            export MCFLY_LIGHT=true
        else
            unset -v MCFLY_LIGHT
        fi
        return 0
    }
    if [[ "$(declare -p PROMPT_COMMAND 2>&1)" == "declare -a"* ]]
    then
        PROMPT_COMMAND+=('_koopa_bash_color_mode_sync')
    elif [[ -n "${PROMPT_COMMAND:-}" ]]
    then
        PROMPT_COMMAND="${PROMPT_COMMAND};_koopa_bash_color_mode_sync"
    else
        PROMPT_COMMAND='_koopa_bash_color_mode_sync'
    fi
    return 0
}
