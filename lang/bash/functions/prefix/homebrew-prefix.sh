#!/usr/bin/env bash

_koopa_homebrew_prefix() {
    local string
    string="${HOMEBREW_PREFIX:-}"
    if [[ -z "$string" ]]
    then
        if _koopa_is_installed 'brew'
        then
            string="$(brew --prefix)"
        elif _koopa_is_macos
        then
            case "$(_koopa_arch)" in
                'arm'*)
                    string='/opt/homebrew'
                    ;;
                'x86'*)
                    string='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            string='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}
