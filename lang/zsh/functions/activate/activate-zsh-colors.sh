#!/usr/bin/env zsh

_koopa_activate_zsh_colors() {
    autoload -Uz colors && colors 2>/dev/null
    return 0
}
