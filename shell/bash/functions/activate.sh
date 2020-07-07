#!/usr/bin/env bash

koopa::activate_bash_aliases() { # {{{1
    # """
    # Alias definitions.
    # @note Updated 2020-06-19.
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    # """
    local user_aliases
    koopa::assert_has_no_args "$#"
    user_aliases="${HOME}/.bash_aliases"
    if [[ -f "$user_aliases" ]]
    then
        # shellcheck source=/dev/null
        source "$user_aliases"
    fi
    return 0
}

koopa::activate_bash_completion() { # {{{1
    # """
    # Activate Bash completion.
    # @note Updated 2020-07-06.
    # Add tab completion for many commands.
    # """
    local brew_prefix nounset script
    koopa::assert_has_no_args "$#"
    if koopa::is_installed brew
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        # Ensure existing Homebrew v1 completions continue to work.
        export BASH_COMPLETION_COMPAT_DIR="${brew_prefix}/etc/bash_completion.d"
        # shellcheck source=/dev/null
        script="${brew_prefix}/etc/profile.d/bash_completion.sh"
    else
        script='/etc/bash_completion'
    fi
    [[ -r "$script" ]] || return 0
    nounset="$(koopa::boolean_nounset)"
    if [[ "$nounset" -eq 1 ]]
    then
        set +e
        set +u
    fi
    # shellcheck source=/dev/null
    source "$script"
    if [[ "$nounset" -eq 1 ]]
    then
        set -e
        set -u
    fi
    return 0
}

koopa::activate_bash_extras() { # {{{1
    # """
    # Activate Bash extras.
    # @note Updated 2020-06-19.
    # """
    koopa::assert_has_no_args "$#"
    koopa::activate_bash_completion
    koopa::activate_bash_readline
    koopa::activate_bash_lesspipe
    koopa::activate_bash_aliases
    koopa::activate_bash_prompt
    return 0
}

koopa::activate_bash_lesspipe() { # {{{1
    # """
    # Activate lesspipe for Bash.
    # @note Updated 2020-06-19.
    # Make less more friendly for non-text input files, see lesspipe(1).
    # """
    koopa::assert_has_no_args "$#"
    [[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
    return 0
}

koopa::activate_bash_prompt() { # {{{1
    # """
    # Activate Bash prompt.
    # @note Updated 2020-07-07.
    # """
    koopa::assert_has_no_args "$#"
    PS1="$(koopa::prompt)"
    export PS1
    return 0
}

koopa::activate_bash_readline() { # {{{1
    # """
    # Readline input options.
    # @note Updated 2020-06-19.
    # """
    local input_rc
    koopa::assert_has_no_args "$#"
    [[ -n "${INPUTRC:-}" ]] && return 0
    input_rc="${HOME}/.inputrc"
    [[ -r "$input_rc" ]] || return 0
    export INPUTRC="${HOME}/.inputrc"
    return 0
}
