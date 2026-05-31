#!/usr/bin/env zsh

_koopa_activate_zsh_compinit() {
    autoload -Uz compinit
    local _zcompdump="${ZDOTDIR:-${HOME:?}}/.zcompdump"
    if [[ -n ${_zcompdump}(#qN.mh-24) ]]
    then
        compinit -C 2>/dev/null
    else
        compinit 2>/dev/null
    fi
    return 0
}
