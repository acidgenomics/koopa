#!/usr/bin/env bash

_koopa_is_alacritty() {
    [[ -n "${ALACRITTY_SOCKET:-}" ]]
}
