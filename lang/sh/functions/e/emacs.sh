#!/bin/sh

_koopa_emacs() {
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2024-01-31.
    #
    # Check that configuration is correct with 'infocmp xterm-24bit'.
    #
    # Alternatively can set 'export COLORTERM=truecolor'.
    #
    # @seealso
    # - https://emacs.stackexchange.com/questions/51100/
    # - https://github.com/kovidgoyal/kitty/issues/1141
    # - https://chadaustin.me/2024/01/truecolor-terminal-emacs/
    # - https://news.ycombinator.com/item?id=39189881
    # """
    if _koopa_is_macos
    then
        __kvar_emacs="$(_koopa_macos_emacs)"
    else
        __kvar_emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [ ! -e "$__kvar_emacs" ]
    then
        _koopa_print "Emacs not installed at '${__kvar_emacs}'."
        unset -v __kvar_emacs
        return 1
    fi
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ] && _koopa_is_macos
    then
        TERM='xterm-24bit' "$__kvar_emacs" "$@" >/dev/null 2>&1
    else
        "$__kvar_emacs" "$@" >/dev/null 2>&1
    fi
    unset -v __kvar_emacs
    return 0
}
