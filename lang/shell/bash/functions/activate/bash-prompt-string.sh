#!/usr/bin/env bash

_koopa_bash_prompt_string() {
    # """
    # Bash prompt string (PS1).
    # @note Updated 2023-03-09.
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
    # - https://unix.stackexchange.com/questions/218174/
    # """
    local dict
    declare -A dict=(
        ['newline']='\n'
        ['prompt']='\$'
        ['prompt_color']=35
        ['user']='\u@\h'
        ['user_color']=36
        ['wd']='\w'
        ['wd_color']=34
    )
    printf '%s%s%s%s%s%s ' \
        "${dict['newline']}" \
        "\[\033[${dict['user_color']}m\]${dict['user']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['wd_color']}m\]${dict['wd']}\[\033[00m\]" \
        "${dict['newline']}" \
        "\[\033[${dict['prompt_color']}m\]${dict['prompt']}\[\033[00m\]"
    return 0
}
