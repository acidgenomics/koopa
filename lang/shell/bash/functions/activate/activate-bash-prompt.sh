#!/usr/bin/env bash

_koopa_activate_bash_prompt() {
    # """
    # Activate Bash prompt.
    # @note Updated 2023-03-09.
    # """
    _koopa_is_root && return 0
    _koopa_activate_starship
    [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    PS1="$(_koopa_bash_prompt_string)"
    export PS1
    return 0
}
