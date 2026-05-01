#!/usr/bin/env bash

_koopa_activate_completion() {
    local shell
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    local koopa_prefix
    koopa_prefix="$(_koopa_koopa_prefix)"
    local file
    for file in "${koopa_prefix}/etc/completion/"*'.sh'
    do
        [[ -f "$file" ]] && source "$file"
    done
    return 0
}
