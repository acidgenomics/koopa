#!/usr/bin/env bash

koopa_locate_tlmgr() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tlmgr')
    else
        args+=('/usr/bin/tlmgr')
    fi
    koopa_locate_app "${args[@]}" "$@"
}
