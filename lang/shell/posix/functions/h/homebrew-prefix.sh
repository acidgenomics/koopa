#!/bin/sh

_koopa_homebrew_prefix() {
    # """
    # Homebrew prefix.
    # @note Updated 2023-03-11.
    #
    # @seealso https://brew.sh/
    # """
    __kvar_string="${HOMEBREW_PREFIX:-}"
    if [ -z "$__kvar_string" ]
    then
        if _koopa_is_installed 'brew'
        then
            __kvar_string="$(brew --prefix)"
        elif _koopa_is_macos
        then
            case "$(_koopa_arch)" in
                'arm'*)
                    __kvar_string='/opt/homebrew'
                    ;;
                'x86'*)
                    __kvar_string='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            __kvar_string='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
