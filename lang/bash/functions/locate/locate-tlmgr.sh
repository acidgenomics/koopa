#!/usr/bin/env bash

_koopa_locate_tlmgr() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tlmgr')
    else
        args+=('/usr/bin/tlmgr')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}
