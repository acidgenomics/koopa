#!/usr/bin/env bash

_koopa_export_manpager() {
    [[ -n "${MANPAGER:-}" ]] && return 0
    local nvim
    nvim="${KOOPA_PREFIX:?}/bin/nvim"
    if [[ -x "$nvim" ]]
    then
        export MANPAGER="${nvim} +Man!"
    fi
    return 0
}
