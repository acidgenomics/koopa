#!/bin/sh

_koopa_emacs() {
    # """
    # Emacs alias that provides 24-bit color support.
    # @note Updated 2023-03-22.
    #
    # Check that configuration is correct with 'infocmp xterm-24bit'.
    #
    # @seealso
    # - https://emacs.stackexchange.com/questions/51100/
    # - https://github.com/kovidgoyal/kitty/issues/1141
    # """
    __kvar_prefix="${HOME:?}/.emacs.d"
    if [ ! -L "$__kvar_prefix" ] || [ ! -f "${__kvar_prefix}/chemacs.el" ]
    then
        _koopa_print "Chemacs is not configured at '${__kvar_prefix}'."
        unset -v __kvar_prefix
        return 1
    fi
    if _koopa_is_macos
    then
        __kvar_emacs="$(_koopa_macos_emacs)"
    else
        __kvar_emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [ ! -e "$__kvar_emacs" ]
    then
        _koopa_print "Emacs not installed at '${__kvar_emacs}'."
        unset -v \
            __kvar_emacs \
            __kvar_prefix
        return 1
    fi
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ] && _koopa_is_macos
    then
        TERM='xterm-24bit' "$__kvar_emacs" "$@" >/dev/null 2>&1
    else
        "$__kvar_emacs" "$@" >/dev/null 2>&1
    fi
    unset -v \
        __kvar_emacs \
        __kvar_prefix
    return 0
}
