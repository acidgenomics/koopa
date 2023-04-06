#!/usr/bin/env bash

koopa_locate_tex() {
    local -a args
    args=()
    if koopa_is_macos
    then
        args+=('/Library/TeX/texbin/tex')
    else
        args+=('/usr/bin/tex')
    fi
    koopa_locate_app "${args[@]}" "$@"
}
