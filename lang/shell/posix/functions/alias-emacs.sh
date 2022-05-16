#!/bin/sh

koopa_alias_emacs() {
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2022-05-10.
    #
    # Check that configuration is correct with 'infocmp xterm-24bit'.
    #
    # @seealso
    # - https://emacs.stackexchange.com/questions/51100/
    # - https://github.com/kovidgoyal/kitty/issues/1141
    # """
    local prefix
    prefix="${HOME:?}/.emacs.d"
    [ -f "${prefix}/chemacs.el" ] || return 1
    if [ -f "${HOME:?}/.terminfo/78/xterm-24bit" ] && koopa_is_macos
    then
        TERM='xterm-24bit' emacs --no-window-system "$@"
    else
        emacs --no-window-system "$@"
    fi
}
