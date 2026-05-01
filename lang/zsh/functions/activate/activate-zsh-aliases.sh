#!/usr/bin/env zsh

_koopa_activate_zsh_aliases() {
    local user_aliases
    user_aliases="${HOME}/.zsh_aliases"
    if [[ -f "$user_aliases" ]]
    then
        source "$user_aliases"
    fi
    return 0
}
