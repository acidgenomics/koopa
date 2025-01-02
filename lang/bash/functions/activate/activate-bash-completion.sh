#!/usr/bin/env bash

_koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2025-01-02.
    # """
    local -A dict
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['completion_file']="${dict['opt_prefix']}/bash-completion/etc/\
profile.d/bash_completion.sh"
    if [[ -f "${dict['completion_file']}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict['completion_file']}"
    fi
    return 0
}
