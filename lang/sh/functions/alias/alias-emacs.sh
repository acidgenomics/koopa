#!/bin/sh

_koopa_alias_emacs() {
    # """
    # Emacs alias.
    # @note Updated 2025-05-10.
    # """
    __kvar_emacs="emacs"
    if _koopa_is_macos
    then
        __kvar_homebrew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"
        if [ -x "${__kvar_homebrew_prefix}/bin/emacs" ]
        then
            __kvar_emacs="${__kvar_homebrew_prefix}/bin/emacs"
        fi
    else
        __kvar_emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [ ! -x "$__kvar_emacs" ]
    then
        _koopa_print "Emacs not installed at '${__kvar_emacs}'."
        unset -v __kvar_emacs __kvar_homebrew_prefix
        return 1
    fi
    if [ -e "${HOME:?}/.terminfo/78/xterm-24bit" ] && _koopa_is_macos
    then
        TERM='xterm-24bit' "$__kvar_emacs" "$@" >/dev/null 2>&1
    else
        "$__kvar_emacs" "$@" >/dev/null 2>&1
    fi
    unset -v __kvar_emacs __kvar_homebrew_prefix
    return 0
}
