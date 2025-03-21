#!/usr/bin/env bash

# TODO Work on consolidating these scripts into a single directory managed
# in koopa.

_koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2025-02-27.
    #
    # System Bash completion paths:
    # - /usr/share/bash-completion/bash_completion
    # - /etc/bash_completion
    # """
    local -A app dict
    local -a completion_dirs completion_files
    local completion_dir completion_file
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    completion_files+=(
        # > '/usr/share/bash-completion/bash_completion'
        # > '/etc/bash_completion'
        "${dict['opt_prefix']}/bash-completion/etc/profile.d/bash_completion.sh"
        "${dict['opt_prefix']}/git/share/completion/git-completion.bash"
        "${dict['opt_prefix']}/google-cloud-sdk/libexec/gcloud/\
completion.bash.inc"
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
        '/usr/local/etc/bash_completion.d'
        "${dict['opt_prefix']}/chezmoi/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/eza/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/gum/etc/bash_completion.d"
        "${dict['opt_prefix']}/rust/etc/bash_completion.d"
        "${dict['opt_prefix']}/tealdeer/libexec/etc/bash_completion.d"
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
    # AWS CLI completion support.
    # https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-completion.html
    app['aws_completer']="${dict['opt_prefix']}/aws-cli/bin/aws_completer"
    if [[ -x "${app['aws_completer']}" ]]
    then
        complete -C "${app['aws_completer']}" 'aws'
    fi
    return 0
}
