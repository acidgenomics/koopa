#!/bin/sh
# shellcheck disable=SC2039

_koopa_prompt() {                                                         # {{{3
    # """
    # Prompt string.
    # Updated 2019-10-31.
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
    local conda git newline prompt user venv wd
    user="${USER}@${HOSTNAME//.*/}"
    # Note that subshell exec need to be escaped here, so they are evaluated
    # dynamically when the prompt is refreshed.
    conda="\$(_koopa_prompt_conda)"
    git="\$(_koopa_prompt_git)"
    venv="\$(_koopa_prompt_venv)"
    case "$KOOPA_SHELL" in
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
    esac
    # Enable colorful prompt, when possible.
    if _koopa_is_matching_fixed "${TERM:-}" "256color"
    then
        local conda_color git_color prompt_color user_color venv_color wd_color
        case "$KOOPA_SHELL" in
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
    fi
    printf "%s%s%s%s%s%s%s%s%s " \
        "$newline" \
        "$user" "$conda" "$venv" \
        "$newline" \
        "$wd" "$git" \
        "$newline" \
        "$prompt"
}

_koopa_prompt_conda() {                                                   # {{{3
    # """
    # Get conda environment name for prompt string.
    # Updated 2019-10-13.
    # """
    local env
    env="$(_koopa_conda_env)"
    if [ -n "$env" ]
    then
        printf " conda:%s\n" "${env}"
    else
        return 0
    fi
}

_koopa_prompt_disk_used() {                                               # {{{3
    # """
    # Get current disk usage on primary drive.
    # Updated 2019-10-13.
    # """
    local pct used
    used="$(_koopa_disk_pct_used)"
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

_koopa_prompt_git() {                                                     # {{{3
    # """
    # Return the current git branch, if applicable.
    # Updated 2019-10-14.
    #
    # Also indicate status with "*" if dirty (i.e. has unstaged changes).
    # """
    _koopa_is_git || return 0
    local git_branch git_status
    git_branch="$(_koopa_git_branch)"
    if _koopa_is_git_clean
    then
        git_status=""
    else
        git_status="*"
    fi
    printf " %s%s\n" "$git_branch" "$git_status"
}

_koopa_prompt_venv() {                                                    # {{{3
    # """
    # Get Python virtual environment name for prompt string.
    # Updated 2019-10-13.
    #
    # See also: https://stackoverflow.com/questions/10406926
    # """
    local env
    env="$(_koopa_venv)"
    if [ -n "$env" ]
    then
        printf " venv:%s\n" "${env}"
    else
        return 0
    fi
}
