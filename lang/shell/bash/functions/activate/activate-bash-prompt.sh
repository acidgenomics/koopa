#!/usr/bin/env bash

koopa_activate_bash_prompt() {
    # """
    # Activate Bash prompt.
    # @note Updated 2022-06-16.
    # """
    [[ "$#" -eq 0 ]] || return 1
    [[ "${KOOPA_DEV:-0}" -eq 1 ]] && return 0
    koopa_is_root && return 0
    if [[ -z "${_PRESERVED_PROMPT_COMMAND:-}" ]]
    then
        export _PRESERVED_PROMPT_COMMAND=''
    fi
    koopa_activate_starship
    [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    PS1="$(koopa_bash_prompt_string)"
    export PS1
    return 0
}
