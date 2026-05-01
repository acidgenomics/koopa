#!/usr/bin/env bash

_koopa_is_installed() {
    local cmd string
    for cmd in "$@"
    do
        string="$(command -v "$cmd")"
        [[ -x "$string" ]] && continue
        return 1
    done
    return 0
}
