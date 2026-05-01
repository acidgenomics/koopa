#!/usr/bin/env bash

_koopa_is_kitty() {
    [[ -n "${KITTY_PID:-}" ]]
}
