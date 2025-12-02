#!/usr/bin/env bash
# shellcheck disable=all

_koopa_activate_bash_aliases() {
    local -A dict
    dict['user_aliases_file']="${HOME}/.bash_aliases"
    if [[ -f "${dict['user_aliases_file']}" ]]
    then
        source "${dict['user_aliases_file']}"
    fi
    return 0
}

_koopa_activate_bash_completion() {
    local -A app dict
    local -a completion_dirs completion_files
    local completion_dir completion_file
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    completion_files+=(
        "${dict['opt_prefix']}/bash-completion/etc/profile.d/bash_completion.sh"
        "${dict['opt_prefix']}/gh/share/bash-completion/completions/gh"
        "${dict['opt_prefix']}/git/share/completion/git-completion.bash"
        "${dict['opt_prefix']}/google-cloud-sdk/libexec/gcloud/\
completion.bash.inc"
    )
    for completion_file in "${completion_files[@]}"
    do
        if [[ -f "$completion_file" ]]
        then
            source "$completion_file"
        fi
    done
    completion_dirs+=(
        '/etc/bash_completion.d'
        '/usr/local/etc/bash_completion.d'
        "${dict['opt_prefix']}/chezmoi/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/eza/libexec/etc/bash_completion.d"
        "${dict['opt_prefix']}/gum/etc/bash_completion.d"
        "${dict['opt_prefix']}/lesspipe/etc/bash_completion.d"
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
                    source "$rc_file"
                fi
            done
        fi
    done
    app['aws_completer']="${dict['opt_prefix']}/aws-cli/bin/aws_completer"
    if [[ -x "${app['aws_completer']}" ]]
    then
        complete -C "${app['aws_completer']}" 'aws'
    fi
    return 0
}

_koopa_activate_bash_extras() {
    _koopa_is_interactive || return 0
    _koopa_activate_bash_readline
    _koopa_activate_bash_aliases
    _koopa_activate_bash_prompt
    _koopa_activate_bash_reverse_search
    _koopa_activate_bash_completion
    _koopa_activate_completion
    return 0
}

_koopa_activate_bash_prompt() {
    _koopa_activate_starship
    [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    PS1="$(_koopa_bash_prompt_string)"
    export PS1
    return 0
}

_koopa_activate_bash_readline() {
    local -A dict
    [[ -n "${INPUTRC:-}" ]] && return 0
    dict['input_rc_file']="${HOME}/.inputrc"
    [[ -r "${dict['input_rc_file']}" ]] || return 0
    export INPUTRC="${dict['input_rc_file']}"
    return 0
}

_koopa_activate_bash_reverse_search() {
    _koopa_activate_mcfly
    return 0
}

_koopa_bash_prompt_string() {
    local -A dict
    dict['newline']='\n'
    dict['prompt']='\$'
    dict['prompt_color']=35
    dict['user']='\u@\h'
    dict['user_color']=36
    dict['wd']='\w'
    dict['wd_color']=34
    printf '%s%s%s%s%s%s ' \
        "${dict['newline']}" \
        "\[\033[${dict['user_color']}m\]${dict['user']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['wd_color']}m\]${dict['wd']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['prompt_color']}m\]${dict['prompt']}\[\033[00m\]"
    return 0
}
