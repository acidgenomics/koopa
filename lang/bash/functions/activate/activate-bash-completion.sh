#!/usr/bin/env bash

_koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2025-01-15.
    #
    # System Bash completion paths:
    # - /usr/share/bash-completion/bash_completion
    # - /etc/bash_completion
    #
    # May want to source all files in '/etc/bash_completion.d'.
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
    else
        if [[ -f '/usr/share/bash-completion/bash_completion' ]]
        then
            # shellcheck source=/dev/null
            source '/usr/share/bash-completion/bash_completion'
        elif [[ -f '/etc/bash_completion' ]]
        then
            # shellcheck source=/dev/null
            source '/etc/bash_completion'
        fi
    fi
    if [[ -f "${dict['git_completion_file']}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict['git_completion_file']}"
    fi
    if [[ -d '/etc/bash_completion.d' ]]
    then
        local rc_file
        for rc_file in '/etc/bash_completion.d/'*
        do
            if [[ -f "$rc_file" ]]
            then
                # shellcheck source=/dev/null
                source "$rc_file"
            fi
        done
    fi
    if [[ -d '/usr/local/etc/bash_completion.d' ]]
    then
        local rc_file
        for rc_file in '/usr/local/etc/bash_completion.d/'*
        do
            if [[ -f "$rc_file" ]]
            then
                # shellcheck source=/dev/null
                source "$rc_file"
            fi
        done
    fi
    return 0
}
