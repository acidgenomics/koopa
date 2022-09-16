#!/bin/sh

koopa_emacs() {
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2022-09-16.
    #
    # Check that configuration is correct with 'infocmp xterm-24bit'.
    #
    # @seealso
    # - https://emacs.stackexchange.com/questions/51100/
    # - https://github.com/kovidgoyal/kitty/issues/1141
    # """
    local emacs prefix
    prefix="${HOME:?}/.emacs.d"
    [ -f "${prefix}/chemacs.el" ] || return 1
    emacs='emacs'
    koopa_is_macos && emacs="$(koopa_macos_emacs)"
    [ -e "$emacs" ] || return 1
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ]
    then
        TERM='xterm-24bit' "$emacs" "$@" >/dev/null 2>&1
    else
        "$emacs" "$@" >/dev/null 2>&1
    fi
    return 0
}
