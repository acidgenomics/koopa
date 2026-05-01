#!/usr/bin/env bash

_koopa_locate_tex() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tex')
    else
        args+=('/usr/bin/tex')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}
