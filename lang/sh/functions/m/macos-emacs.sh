#!/bin/sh

_koopa_macos_emacs() {
    # """
    # macOS Emacs.app that supports full screen window mode.
    # @note Updated 2023-05-06.
    # """
    __kvar_homebrew_prefix="$(_koopa_homebrew_prefix)"
    [ -d "$__kvar_homebrew_prefix" ] || return 1
    __kvar_emacs="${__kvar_homebrew_prefix}/bin/emacs"
    [ -x "$__kvar_emacs" ] || return 1
    _koopa_print "$__kvar_emacs"
    unset -v __kvar_emacs __kvar_homebrew_prefix
    return 0
}
