#!/usr/bin/env zsh

_koopa_activate_zsh_bashcompinit() {
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
    return 0
}
