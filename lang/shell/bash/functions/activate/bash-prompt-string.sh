#!/usr/bin/env bash

koopa_bash_prompt_string() {
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
