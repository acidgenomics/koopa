#!/bin/sh

_koopa_prompt() { # {{{1
    # """
    # Prompt string.
    # @note Updated 2020-07-13.
    #
    # Subshell exec need to be escaped here, so they are evaluated dynamically
    # when the prompt is refreshed.
    #
    # Unicode characters don't work well with some Windows fonts.
    #
    # User name and host.
    # - Bash : user="\u@\h"
    # - ZSH  : user="%n@%m"
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
    # shellcheck disable=SC2039
    local conda conda_color git git_color hostname newline prompt prompt_color \
        shell user user_color venv venv_color wd wd_color
    shell="$(_koopa_shell)"
    hostname="$(_koopa_hostname)"
    # String replacement supported in Bash, Zsh.
    # shellcheck disable=SC2039
    hostname="${hostname//.local/}"
    user="$(_koopa_user)"
    user="${user}@${hostname}"
    conda="\$(_koopa_prompt_conda)"
    git="\$(_koopa_prompt_git)"
    venv="\$(_koopa_prompt_venv)"
    case "$shell" in
        bash)
            newline='\n'
            prompt='\$'
            wd='\w'
            ;;
        zsh)
            # shellcheck disable=SC2039
            newline=$'\n'
            # Note that Zsh uses '%' by default.
            # > prompt='%%'
            # Inspired by Pure prompt.
            # https://github.com/sindresorhus/pure
            prompt='❯'
            wd='%~'
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 0
            ;;
    esac
    case "$shell" in
        bash)
            conda_color=33
            git_color=32
            prompt_color=35
            user_color=36
            venv_color=33
            wd_color=34
            conda="\[\033[${conda_color}m\]${conda}\[\033[00m\]"
            git="\[\033[${git_color}m\]${git}\[\033[00m\]"
            prompt="\[\033[${prompt_color}m\]${prompt}\[\033[00m\]"
            user="\[\033[${user_color}m\]${user}\[\033[00m\]"
            venv="\[\033[${venv_color}m\]${venv}\[\033[00m\]"
            wd="\[\033[${wd_color}m\]${wd}\[\033[00m\]"
            ;;
        zsh)
            # shellcheck disable=SC2039,SC2154
            conda_color="${fg[yellow]}"
            # shellcheck disable=SC2039
            git_color="${fg[green]}"
            # shellcheck disable=SC2039
            prompt_color="${fg[magenta]}"
            # shellcheck disable=SC2039
            user_color="${fg[cyan]}"
            # shellcheck disable=SC2039
            venv_color="${fg[yellow]}"
            # shellcheck disable=SC2039
            wd_color="${fg[blue]}"
            conda="%F%{${conda_color}%}${conda}%f"
            git="%F%{${git_color}%}${git}%f"
            prompt="%F%{${prompt_color}%}${prompt}%f"
            user="%F%{${user_color}%}${user}%f"
            venv="%F%{${venv_color}%}${venv}%f"
            wd="%F%{${wd_color}%}${wd}%f"
            ;;
    esac
    printf '%s%s%s%s%s%s%s%s%s ' \
        "$newline" \
        "$user" "$conda" "$venv" \
        "$newline" \
        "$wd" "$git" \
        "$newline" \
        "$prompt"
    return 0
}

_koopa_prompt_conda() { # {{{1
    # """
    # Get conda environment name for prompt string.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
    local env
    env="$(_koopa_conda_env)"
    [ -n "$env" ] || return 0
    _koopa_print " conda:${env}"
    return 0
}

_koopa_prompt_git() { # {{{1
    # """
    # Return the current git branch, if applicable.
    # @note Updated 2020-07-20.
    #
    # Also indicate status with "*" if dirty (i.e. has unstaged changes).
    # """
    # shellcheck disable=SC2039
    local git_branch git_status
    _koopa_is_git || return 0
    git_branch="$(_koopa_git_branch)"
    if _koopa_is_git_clean
    then
        git_status=
    else
        git_status='*'
    fi
    _koopa_print " ${git_branch}${git_status}"
    return 0
}

_koopa_prompt_venv() { # {{{1
    # """
    # Get Python virtual environment name for prompt string.
    # @note Updated 2020-06-30.
    #
    # See also: https://stackoverflow.com/questions/10406926
    # """
    # shellcheck disable=SC2039
    local env
    env="$(_koopa_venv)"
    [ -n "$env" ] || return 0
    _koopa_print " venv:${env}"
    return 0
}
