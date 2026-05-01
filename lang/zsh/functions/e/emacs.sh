#!/usr/bin/env zsh

_koopa_emacs() {
    local emacs
    if _koopa_is_macos
    then
        emacs="$(_koopa_macos_emacs)"
    else
        emacs="$(_koopa_bin_prefix)/emacs"
    fi
    if [[ ! -e "$emacs" ]]
    then
        _koopa_print "Emacs not installed at '${emacs}'."
        return 1
    fi
    if [[ -e "${HOME:?}/.terminfo/78/xterm-24bit" ]] && _koopa_is_macos
    then
        TERM='xterm-24bit' "$emacs" "$@" >/dev/null 2>&1
    else
        "$emacs" "$@" >/dev/null 2>&1
    fi
    return 0
}
