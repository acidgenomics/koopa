#!/usr/bin/env bash

_koopa_activate_bash_extras() {
    # """
    # Activate Bash extras.
    # @note Updated 2025-01-02.
    # """
    _koopa_is_interactive || return 0
    _koopa_activate_bash_readline
    _koopa_activate_bash_aliases
    _koopa_activate_bash_prompt
    _koopa_activate_bash_reverse_search
    _koopa_activate_bash_completion
    _koopa_activate_completion
    return 0
}
