#!/bin/sh

_koopa_emacs() {
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2023-01-06.
    #
    # Check that configuration is correct with 'infocmp xterm-24bit'.
    #
    # @seealso
    # - https://emacs.stackexchange.com/questions/51100/
    # - https://github.com/kovidgoyal/kitty/issues/1141
    # """
    local emacs prefix
    prefix="${HOME:?}/.emacs.d"
    if [ ! -L "$prefix" ]
    then
        _koopa_print "Chemacs is not linked at '${prefix}'."
        return 1
    fi
    if [ ! -f "${prefix}/chemacs.el" ]
    then
        _koopa_print "Chemacs is not configured at '${prefix}'."
        return 1
    fi
    if _koopa_is_macos
    then
        emacs="$(_koopa_macos_emacs)"
    else
        emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [ ! -e "$emacs" ]
    then
        _koopa_print "Emacs not installed at '${emacs}'."
        return 1
    fi
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ]
    then
        TERM='xterm-24bit' "$emacs" "$@" >/dev/null 2>&1
    else
        "$emacs" "$@" >/dev/null 2>&1
    fi
    return 0
}
