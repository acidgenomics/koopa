#!/usr/bin/env bash

_koopa_activate_bash_aliases() { # {{{1
    # """
    # Alias definitions.
    # @note Updated 2021-06-04.
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    # """
    local user_aliases
    [[ "$#" -eq 0 ]] || return 1
    user_aliases="${HOME}/.bash_aliases"
    if [[ -f "$user_aliases" ]]
    then
        # shellcheck source=/dev/null
        source "$user_aliases"
    fi
    return 0
}

_koopa_activate_bash_completion() { # {{{1
    # """
    # Activate Bash completion.
    # @note Updated 2021-09-29.
    #
    # Adds tab completion for many commands.
    # Consider adding detection support inside of make prefix.
    # """
    local brew_prefix brew_script nounset sys_script
    [[ "$#" -eq 0 ]] || return 1
    brew_prefix="$(_koopa_homebrew_prefix)"
    brew_script="${brew_prefix}/etc/profile.d/bash_completion.sh"
    sys_script='/etc/bash_completion'
    if [[ ! -r "$brew_script" ]] && [[ ! -r "$sys_script" ]]
    then
        return 0
    fi
    nounset="$(_koopa_boolean_nounset)"
    if [[ "$nounset" -eq 1 ]]
    then
        set +e
        set +u
    fi
    if [[ -r "$brew_script" ]]
    then
        # shellcheck source=/dev/null
        source "$brew_script"
    fi
    if [[ -r "$sys_script" ]]
    then
        # shellcheck source=/dev/null
        source "$sys_script"
    fi
    if [[ "$nounset" -eq 1 ]]
    then
        set -e
        set -u
    fi
    return 0
}

_koopa_activate_bash_extras() { # {{{1
    # """
    # Activate Bash extras.
    # @note Updated 2021-09-29.
    # """
    [[ "$#" -eq 0 ]] || return 1
    _koopa_is_interactive || return 0
    echo 'FIXME 1a'
    _koopa_activate_bash_completion
    echo 'FIXME 1b'
    _koopa_activate_bash_readline
    echo 'FIXME 1c'
    _koopa_activate_bash_aliases
    echo 'FIXME 1d'
    _koopa_activate_bash_prompt
    echo 'FIXME 1e'
    _koopa_activate_bash_reverse_search
    echo 'FIXME 1f'
    _koopa_activate_completion
    echo 'FIXME 1g'
    return 0
}

_koopa_activate_bash_prompt() { # {{{1
    # """
    # Activate Bash prompt.
    # @note Updated 2021-09-21.
    # """
    [[ "$#" -eq 0 ]] || return 1
    _koopa_is_root && return 0
    if [[ -z "${_PRESERVED_PROMPT_COMMAND:-}" ]]
    then
        export _PRESERVED_PROMPT_COMMAND=''
    fi
    if _koopa_is_installed 'starship'
    then
        _koopa_activate_starship
        [[ -n "${STARSHIP_SHELL:-}" ]] && return 0
    fi
    PS1="$(_koopa_prompt)"
    export PS1
    return 0
}

_koopa_activate_bash_readline() { # {{{1
    # """
    # Readline input options.
    # @note Updated 2020-11-24.
    # """
    local input_rc
    [[ "$#" -eq 0 ]] || return 1
    [[ -n "${INPUTRC:-}" ]] && return 0
    input_rc="${HOME}/.inputrc"
    [[ -r "$input_rc" ]] || return 0
    export INPUTRC="${HOME}/.inputrc"
    return 0
}

_koopa_activate_bash_reverse_search() { # {{{1
    # """
    # Activate reverse search for Bash.
    # @note Updated 2021-06-16.
    # """
    if _koopa_is_installed 'mcfly'
    then
        _koopa_activate_mcfly
    fi
    return 0
}
