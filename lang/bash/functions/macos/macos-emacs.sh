#!/usr/bin/env bash

_koopa_macos_emacs() {
    local homebrew_prefix
    homebrew_prefix="$(_koopa_homebrew_prefix)"
    [[ -d "$homebrew_prefix" ]] || return 1
    local emacs
    emacs="${homebrew_prefix}/bin/emacs"
    [[ -x "$emacs" ]] || return 1
    _koopa_print "$emacs"
    return 0
}
