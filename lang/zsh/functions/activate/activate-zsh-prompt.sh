#!/usr/bin/env zsh

_koopa_activate_zsh_prompt() {
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    setopt promptsubst
    autoload -U promptinit
    promptinit
    prompt koopa
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
