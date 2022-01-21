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
    local brew_prefix brew_script nounset
    [[ "$#" -eq 0 ]] || return 1
    brew_prefix="$(_koopa_homebrew_prefix)"
    brew_script="${brew_prefix}/etc/profile.d/bash_completion.sh"
    # Disabled because sourcing system Bash completion is problematic on
    # Ubuntu 20.
    # > if [[ ! -r "$brew_script" ]] && [[ ! -r "$sys_script" ]]
    # > then
    # >     return 0
    # > fi
    if [[ ! -r "$brew_script" ]]
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
    # This is problematic on Ubuntu 20 LTS.
    # > local sys_script
    # > sys_script='/etc/bash_completion'
    # > if [[ -r "$sys_script" ]]
    # > then
    # >     # shellcheck source=/dev/null
    # >     source "$sys_script"
    # > fi
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
    _koopa_activate_bash_completion
    _koopa_activate_bash_readline
    _koopa_activate_bash_aliases
    _koopa_activate_bash_prompt
    _koopa_activate_bash_reverse_search
    _koopa_activate_completion
    return 0
}

_koopa_activate_bash_prompt() { # {{{1
    # """
    # Activate Bash prompt.
    # @note Updated 2022-01-21.
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
    PS1="$(_koopa_bash_prompt_string)"
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

_koopa_bash_prompt_string() { # {{{1
    # """
    # Bash prompt string (PS1).
    # @note Updated 2022-01-21.
    #
    # Subshell exec need to be escaped here, so they are evaluated dynamically
    # when the prompt is refreshed.
    #
    # Unicode characters don't work well with some Windows fonts.
    #
    # User name and host.
    # - Bash : user='\u@\h'
    # - ZSH  : user='%n@%m'
    #
    # Bash: The default value is '\s-\v\$ '.
    #
    # ZSH: conda environment activation is messing up '%m'/'%M' flag on macOS.
    # This seems to be specific to macOS and doesn't happen on Linux.
    #
    # See also:
    # - https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/
    #       robbyrussell.zsh-theme
    # - https://www.cyberciti.biz/tips/
    #       howto-linux-unix-bash-shell-setup-prompt.html
    # - https://misc.flogisoft.com/bash/tip_colors_and_formatting
    # """
    local dict
    [ "$#" -eq 0 ] || return 1
    declare -A dict=(
        [conda]="\$(_koopa_prompt_conda)"
        [conda_color]=33
        [git]="\$(_koopa_prompt_git)"
        [git_color]=32
        [newline]='\n'
        [prompt]='\$'
        [prompt_color]=35
        [user]="$(_koopa_user)@$(_koopa_hostname)"
        [user_color]=36
        [venv]="\$(_koopa_prompt_python_venv)"
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
