#!/usr/bin/env bash

koopa_activate_bash_extras() {
    # """
    # Activate Bash extras.
    # @note Updated 2021-09-29.
    # """
    [[ "$#" -eq 0 ]] || return 1
    koopa_is_interactive || return 0
    koopa_activate_bash_completion
    koopa_activate_bash_readline
    koopa_activate_bash_aliases
    koopa_activate_bash_prompt
    koopa_activate_bash_reverse_search
    koopa_activate_completion
    return 0
}
