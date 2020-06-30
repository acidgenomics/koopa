#!/usr/bin/env bash

_koopa_activate_bash_aliases() {  # {{{1
    # """
    # Alias definitions.
    # @note Updated 2020-06-19.
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local user_aliases
    user_aliases="${HOME}/.bash_aliases"
    if [[ -f "$user_aliases" ]]
    then
        # shellcheck source=/dev/null
        source "$user_aliases"
    fi
    return 0
}

_koopa_activate_bash_completion() {  # {{{1
    # """
    # Activate Bash completion.
    # @note Updated 2020-06-19.
    # Add tab completion for many commands.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local etc_completion
    etc_completion="/etc/bash_completion"
    if _koopa_is_installed brew
    then
        local brew_prefix
        brew_prefix="$(_koopa_homebrew_prefix)"
        # Ensure existing Homebrew v1 completions continue to work.
        export BASH_COMPLETION_COMPAT_DIR="${brew_prefix}/etc/bash_completion.d"
        # shellcheck source=/dev/null
        source "${brew_prefix}/etc/profile.d/bash_completion.sh"
    elif [[ -f "$etc_completion" ]]
    then
        # shellcheck source=/dev/null
        source "$etc_completion"
    fi
    return 0
}

_koopa_activate_bash_extras() {  # {{{1
    # """
    # Activate Bash extras.
    # @note Updated 2020-06-19.
    # """
    [[ "$#" -eq 0 ]] || return 1
    _koopa_activate_bash_completion
    _koopa_activate_bash_readline
    _koopa_activate_bash_lesspipe
    _koopa_activate_bash_aliases
    _koopa_activate_bash_prompt
    return 0
}

_koopa_activate_bash_lesspipe() {  # {{{1
    # """
    # Activate lesspipe for Bash.
    # @note Updated 2020-06-19.
    # Make less more friendly for non-text input files, see lesspipe(1).
    # """
    [[ "$#" -eq 0 ]] || return 1
    [[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"
    return 0
}

_koopa_activate_bash_prompt() {  # {{{1
    # """
    # Activate Bash prompt.
    # @note Updated 2020-06-19.
    # """
    [[ "$#" -eq 0 ]] || return 1
    PS1="$(_koopa_prompt)"
    export PS1
    return 0
}

_koopa_activate_bash_readline() {  # {{{1
    # """
    # Readline input options.
    # @note Updated 2020-06-19.
    # """
    [[ "$#" -eq 0 ]] || return 1
    [[ -n "${INPUTRC:-}" ]] && return 0
    local input_rc
    input_rc="${HOME}/.inputrc"
    [[ -r "$input_rc" ]] || return 0
    export INPUTRC="${HOME}/.inputrc"
    return 0
}
