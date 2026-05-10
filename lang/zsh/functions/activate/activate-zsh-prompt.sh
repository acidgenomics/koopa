#!/usr/bin/env zsh

_koopa_activate_zsh_prompt() {
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    setopt promptsubst
    autoload -U promptinit
    promptinit
    prompt koopa
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
