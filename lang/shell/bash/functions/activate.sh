#!/usr/bin/env bash
# shellcheck disable=all

_koopa_activate_bash_aliases() {
    local dict
    declare -A dict=(
        ['user_aliases_file']="${HOME}/.bash_aliases"
    )
    if [[ -f "${dict['user_aliases_file']}" ]]
    then
        source "${dict['user_aliases_file']}"
    fi
    return 0
}

_koopa_activate_bash_extras() {
    _koopa_is_interactive || return 0
    _koopa_activate_bash_readline
    _koopa_activate_bash_aliases
    _koopa_activate_bash_prompt
    _koopa_activate_bash_reverse_search
    _koopa_activate_completion
    return 0
}

_koopa_activate_bash_prompt() {
    _koopa_is_root && return 0
    _koopa_activate_starship
    [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    PS1="$(_koopa_bash_prompt_string)"
    export PS1
    return 0
}

_koopa_activate_bash_readline() {
    local dict
    [[ -n "${INPUTRC:-}" ]] && return 0
    declare -A dict=(
        ['input_rc_file']="${HOME}/.inputrc"
    )
    [[ -r "${dict['input_rc_file']}" ]] || return 0
    export INPUTRC="${dict['input_rc_file']}"
    return 0
}

_koopa_activate_bash_reverse_search() {
    _koopa_activate_mcfly
    return 0
}

_koopa_bash_prompt_string() {
    local dict
    declare -A dict=(
        ['newline']='\n'
        ['prompt']='\$'
        ['prompt_color']=35
        ['user']='\u@\h'
        ['user_color']=36
        ['wd']='\w'
        ['wd_color']=34
    )
    printf '%s%s%s%s%s%s ' \
        "${dict['newline']}" \
        "\[\033[${dict['user_color']}m\]${dict['user']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['wd_color']}m\]${dict['wd']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['prompt_color']}m\]${dict['prompt']}\[\033[00m\]"
    return 0
}
