#!/usr/bin/env zsh

_koopa_is_alacritty() {
    [[ -n "${ALACRITTY_SOCKET:-}" ]]
}
