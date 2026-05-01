#!/usr/bin/env zsh

_koopa_print() {
    if [[ "$#" -eq 0 ]]
    then
        printf '\n'
        return 0
    fi
    local string
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}
