#!/usr/bin/env zsh

_koopa_is_kitty() {
    [[ -n "${KITTY_PID:-}" ]]
}
