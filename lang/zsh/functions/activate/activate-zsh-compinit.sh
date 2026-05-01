#!/usr/bin/env zsh

_koopa_activate_zsh_compinit() {
    autoload -Uz compinit && compinit 2>/dev/null
    return 0
}
