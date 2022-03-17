#!/usr/bin/env bash

koopa_activate_bash_aliases() { # {{{1
    # """
    # Alias definitions.
    # @note Updated 2022-02-04.
    #
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    # """
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [user_aliases_file]="${HOME}/.bash_aliases"
    )
    if [[ -f "${dict[user_aliases_file]}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict[user_aliases_file]}"
    fi
    return 0
}

koopa_activate_bash_completion() { # {{{1
    # """
    # Activate Bash completion.
    # @note Updated 2022-02-04.
    # """
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
    # shellcheck source=/dev/null
    source "${dict[script]}"
    if [[ "${dict[nounset]}" -eq 1 ]]
    then
        set -o errexit
        set -o nounset
    fi
    return 0
}

koopa_activate_bash_extras() { # {{{1
    # """
    # Activate Bash extras.
    # @note Updated 2021-09-29.
    # """
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

koopa_activate_bash_prompt() { # {{{1
    # """
    # Activate Bash prompt.
    # @note Updated 2022-01-21.
    # """
    [[ "$#" -eq 0 ]] || return 1
    koopa_is_root && return 0
    if [[ -z "${_PRESERVED_PROMPT_COMMAND:-}" ]]
    then
        export _PRESERVED_PROMPT_COMMAND=''
    fi
    if koopa_is_installed 'starship'
    then
        koopa_activate_starship
        [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    fi
    PS1="$(koopa_bash_prompt_string)"
    export PS1
    return 0
}

koopa_activate_bash_readline() { # {{{1
    # """
    # Readline input options.
    # @note Updated 2022-02-04.
    # """
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

koopa_activate_bash_reverse_search() { # {{{1
    # """
    # Activate reverse search for Bash.
    # @note Updated 2021-06-16.
    # """
    if koopa_is_installed 'mcfly'
    then
        koopa_activate_mcfly
    fi
    return 0
}

koopa_bash_prompt_string() { # {{{1
    # """
    # Bash prompt string (PS1).
    # @note Updated 2022-01-21.
    #
    # This is a modified, lighter version of Pure, by Sindre Sorhus.
    #
    # Subshell exec need to be escaped here, so they are evaluated dynamically
    # when the prompt is refreshed.
    #
    # Unicode characters don't work well with some Windows fonts.
    #
    # The default PS1 value is '\s-\v\$ '.
    #
    # See also:
    # - https://github.com/sindresorhus/pure/
    # - https://www.cyberciti.biz/tips/
    #       howto-linux-unix-bash-shell-setup-prompt.html
    # - https://misc.flogisoft.com/bash/tip_colors_and_formatting
    # """
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
