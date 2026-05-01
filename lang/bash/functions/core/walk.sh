#!/usr/bin/env bash

_koopa_walk() {
    local walk
    walk="$(_koopa_bin_prefix)/walk"
    [[ -x "$walk" ]] || return 1
    cd "$("$walk" "$@")" || return 1
    return 0
}
