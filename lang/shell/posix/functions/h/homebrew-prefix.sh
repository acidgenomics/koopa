#!/bin/sh

_koopa_homebrew_prefix() {
    # """
    # Homebrew prefix.
    # @note Updated 2022-04-07.
    #
    # @seealso https://brew.sh/
    # """
    local arch x
    x="${HOMEBREW_PREFIX:-}"
    if [ -z "$x" ]
    then
        if _koopa_is_installed 'brew'
        then
            x="$(brew --prefix)"
        elif _koopa_is_macos
        then
            arch="$(_koopa_arch)"
            case "$arch" in
                'arm'*)
                    x='/opt/homebrew'
                    ;;
                'x86'*)
                    x='/usr/local'
                    ;;
            esac
        elif _koopa_is_linux
        then
            x='/home/linuxbrew/.linuxbrew'
        fi
    fi
    [ -d "$x" ] || return 1
    _koopa_print "$x"
    return 0
}
