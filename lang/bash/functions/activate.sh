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
    local -A dict
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['bash_completion_file']="${dict['opt_prefix']}/bash-completion/etc/\
profile.d/bash_completion.sh"
    dict['git_completion_file']="${dict['opt_prefix']}/git/share/\
completion/git-completion.bash"
    if [[ -f "${dict['bash_completion_file']}" ]]
    then
        source "${dict['bash_completion_file']}"
    else
        if [[ -f '/usr/share/bash-completion/bash_completion' ]]
        then
            source '/usr/share/bash-completion/bash_completion'
        elif [[ -f '/etc/bash_completion' ]]
        then
            source '/etc/bash_completion'
        fi
    fi
    if [[ -f "${dict['git_completion_file']}" ]]
    then
        source "${dict['git_completion_file']}"
    fi
    if [[ -d '/etc/bash_completion.d' ]]
    then
        local rc_file
        for rc_file in '/etc/bash_completion.d/'*
        do
            if [[ -f "$rc_file" ]]
            then
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
                source "$rc_file"
            fi
        done
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
