#!/usr/bin/env bash

_koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2025-01-02.
    # """
    local -A dict
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['bash_completion_file']="${dict['opt_prefix']}/bash-completion/etc/\
profile.d/bash_completion.sh"
    dict['git_completion_file']="${dict['opt_prefix']}/git/share/\
completion/git-completion.bash"
    if [[ -f "${dict['bash_completion_file']}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict['bash_completion_file']}"
    fi
    if [[ -f "${dict['git_completion_file']}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict['git_completion_file']}"
    fi
    return 0
}
