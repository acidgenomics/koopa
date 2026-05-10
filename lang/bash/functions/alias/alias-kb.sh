#!/usr/bin/env bash

_koopa_alias_kb() {
    local bash_prefix
    bash_prefix="$(_koopa_koopa_prefix)/lang/bash"
    [[ -d "$bash_prefix" ]] || return 1
    cd "$bash_prefix" || return 1
    return 0
}
