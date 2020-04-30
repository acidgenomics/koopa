#!/usr/bin/env bash

_koopa_prompt() {  # {{{1
    # """
    # Prompt string.
    # @note Updated 2020-01-19.
    #
    # Note that Unicode characters don't work well with some Windows fonts.
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
    local shell
    shell="$(_koopa_shell)"
    local hostname
    hostname="${HOSTNAME:?}"
    hostname="${hostname//.*/}"
    local user
    user="${USER:?}"
    user="${user}@${hostname}"
    # Note that subshell exec need to be escaped here, so they are evaluated
    # dynamically when the prompt is refreshed.
    local conda
    conda="\$(_koopa_prompt_conda)"
    local git
    git="\$(_koopa_prompt_git)"
    local venv
    venv="\$(_koopa_prompt_venv)"
    local newline prompt wd
    case "$shell" in
        bash)
            newline='\n'
            prompt='\$'
            wd='\w'
            ;;
        zsh)
            newline=$'\n'
            prompt='%%'
            wd='%~'
            ;;
        *)
            _koopa_warning "Unsupported shell."
            return 0
            ;;
    esac
    # Enable colorful prompt.
    # Note that vim can set TERM as 'xterm' instead of 'xterm-256color' inside
    # of tmux, so disable this check:
    # > if _koopa_str_match "${TERM:-}" "256color"
    local conda_color git_color prompt_color user_color venv_color wd_color
    case "$shell" in
        bash)
            conda_color="33"
            git_color="32"
            prompt_color="35"
            user_color="36"
            venv_color="33"
            wd_color="34"
            # Colorize the variable strings.
            conda="\[\033[${conda_color}m\]${conda}\[\033[00m\]"
            git="\[\033[${git_color}m\]${git}\[\033[00m\]"
            prompt="\[\033[${prompt_color}m\]${prompt}\[\033[00m\]"
            user="\[\033[${user_color}m\]${user}\[\033[00m\]"
            venv="\[\033[${venv_color}m\]${venv}\[\033[00m\]"
            wd="\[\033[${wd_color}m\]${wd}\[\033[00m\]"
            ;;
        zsh)
            # SC2154: fg is referenced but not assigned.
            # shellcheck disable=SC2154
            conda_color="${fg[yellow]}"
            git_color="${fg[green]}"
            prompt_color="${fg[magenta]}"
            user_color="${fg[cyan]}"
            venv_color="${fg[yellow]}"
            wd_color="${fg[blue]}"
            # Colorize the variable strings.
            conda="%F%{${conda_color}%}${conda}%f"
            git="%F%{${git_color}%}${git}%f"
            prompt="%F%{${prompt_color}%}${prompt}%f"
            user="%F%{${user_color}%}${user}%f"
            venv="%F%{${venv_color}%}${venv}%f"
            wd="%F%{${wd_color}%}${wd}%f"
            ;;
    esac
    printf "%s%s%s%s%s%s%s%s%s " \
        "$newline" \
        "$user" "$conda" "$venv" \
        "$newline" \
        "$wd" "$git" \
        "$newline" \
        "$prompt"
}

_koopa_prompt_conda() {  # {{{1
    # """
    # Get conda environment name for prompt string.
    # @note Updated 2020-01-12.
    # """
    local env
    env="$(_koopa_conda_env)"
    [ -n "$env" ] || return 0
    printf " conda:%s\n" "${env}"
}

_koopa_prompt_disk_used() {  # {{{1
    # """
    # Get current disk usage on primary drive.
    # @note Updated 2020-01-12.
    # """
    local used
    used="$(_koopa_disk_pct_used)"
    local pct
    case "$(_koopa_shell)" in
        zsh)
            pct="%%"
            ;;
        *)
            pct="%"
            ;;
    esac
    printf " disk:%d%s\n" "$used" "$pct"
}

_koopa_prompt_git() {  # {{{1
    # """
    # Return the current git branch, if applicable.
    # @note Updated 2020-01-12.
    #
    # Also indicate status with "*" if dirty (i.e. has unstaged changes).
    # """
    _koopa_is_git || return 0
    local git_branch
    git_branch="$(_koopa_git_branch)"
    local git_status
    if _koopa_is_git_clean
    then
        git_status=""
    else
        git_status="*"
    fi
    printf " %s%s\n" "$git_branch" "$git_status"
}

_koopa_prompt_venv() {  # {{{1
    # """
    # Get Python virtual environment name for prompt string.
    # @note Updated 2020-01-12.
    #
    # See also: https://stackoverflow.com/questions/10406926
    # """
    local env
    env="$(_koopa_venv)"
    [ -n "$env" ] || return 0
    printf " venv:%s\n" "${env}"
}
