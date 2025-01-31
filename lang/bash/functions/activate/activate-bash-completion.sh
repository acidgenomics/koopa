#!/usr/bin/env bash

_koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2025-01-31.
    #
    # System Bash completion paths:
    # - /usr/share/bash-completion/bash_completion
    # - /etc/bash_completion
    # """
    local -A dict
    local -a completion_dirs completion_files
    local completion_dir completion_file
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    completion_files+=(
        # > '/usr/share/bash-completion/bash_completion'
        # > '/etc/bash_completion'
        "${dict['opt_prefix']}/bash-completion/etc/profile.d/bash_completion.sh"
        "${dict['opt_prefix']}/git/share/completion/git-completion.bash"
    )
    for completion_file in "${completion_files[@]}"
    do
        if [[ -f "$completion_file" ]]
        then
            # shellcheck source=/dev/null
            source "$completion_file"
        fi
    done
    completion_dirs+=(
        '/etc/bash_completion.d'
        "${dict['opt_prefix']}/chezmoi/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/eza/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/gum/etc/bash_completion.d"
        "${dict['opt_prefix']}/rust/etc/bash_completion.d"
        "${dict['opt_prefix']}/tealdeer/libexec/etc/bash_completion.d"
        '/usr/local/etc/bash_completion.d'
    )
    for completion_dir in "${completion_dirs[@]}"
    do
        if [[ -d "$completion_dir" ]]
        then
            local rc_file
            for rc_file in "${completion_dir}/"*
            do
                if [[ -f "$rc_file" ]]
                then
                    # shellcheck source=/dev/null
                    source "$rc_file"
                fi
            done
        fi
    done
    return 0
}
