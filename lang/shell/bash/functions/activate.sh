#!/bin/sh
# shellcheck disable=all

koopa_activate_bash_aliases() {
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [user_aliases_file]="${HOME}/.bash_aliases"
    )
    if [[ -f "${dict[user_aliases_file]}" ]]
    then
        source "${dict[user_aliases_file]}"
    fi
    return 0
}

koopa_activate_bash_completion() {
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [make_prefix]="$(koopa_make_prefix)"
        [nounset]="$(koopa_boolean_nounset)"
    )
    dict[script]="${dict[make_prefix]}/etc/profile.d/bash_completion.sh"
    [[ -r "${dict[script]}" ]] || return 0
    if [[ "${dict[nounset]}" -eq 1 ]]
    then
        set +o errexit
        set +o nounset
    fi
    source "${dict[script]}"
    if [[ "${dict[nounset]}" -eq 1 ]]
    then
        set -o errexit
        set -o nounset
    fi
    return 0
}

koopa_activate_bash_extras() {
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

koopa_activate_bash_prompt() {
    [[ "$#" -eq 0 ]] || return 1
    koopa_is_root && return 0
    if [[ -z "${_PRESERVED_PROMPT_COMMAND:-}" ]]
    then
        export _PRESERVED_PROMPT_COMMAND=''
    fi
    koopa_activate_starship
    [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    PS1="$(koopa_bash_prompt_string)"
    export PS1
    return 0
}

koopa_activate_bash_readline() {
    local dict
    [[ "$#" -eq 0 ]] || return 1
    [[ -n "${INPUTRC:-}" ]] && return 0
    declare -A dict=(
        [input_rc_file]="${HOME}/.inputrc"
    )
    [[ -r "${dict[input_rc_file]}" ]] || return 0
    export INPUTRC="${dict[input_rc_file]}"
    return 0
}

koopa_activate_bash_reverse_search() {
    koopa_activate_mcfly
    return 0
}

koopa_bash_prompt_string() {
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [conda]="\$(koopa_prompt_conda)"
        [conda_color]=33
        [git]="\$(koopa_prompt_git)"
        [git_color]=32
        [newline]='\n'
        [prompt]='\$'
        [prompt_color]=35
        [user]="$(koopa_user)@$(koopa_hostname)"
        [user_color]=36
        [venv]="\$(koopa_prompt_python_venv)"
        [venv_color]=33
        [wd]='\w'
        [wd_color]=34
    )
    printf '%s%s%s%s%s%s%s%s%s ' \
        "${dict[newline]}" \
        "\[\033[${dict[user_color]}m\]${dict[user]}\[\033[00m\]" \
        "\[\033[${dict[conda_color]}m\]${dict[conda]}\[\033[00m\]" \
        "\[\033[${dict[venv_color]}m\]${dict[venv]}\[\033[00m\]" \
        "${dict[newline]}" \
        "\[\033[${dict[wd_color]}m\]${dict[wd]}\[\033[00m\]" \
        "\[\033[${dict[git_color]}m\]${dict[git]}\[\033[00m\]" \
        "${dict[newline]}" \
        "\[\033[${dict[prompt_color]}m\]${dict[prompt]}\[\033[00m\]"
    return 0
}
