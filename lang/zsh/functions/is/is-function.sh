#!/usr/bin/env zsh

_koopa_is_function() {
    local cmd string
    for cmd in "$@"
    do
        string="$(command -v "$cmd")"
        [[ "$string" == "$cmd" ]] && continue
        return 1
    done
    return 0
}
