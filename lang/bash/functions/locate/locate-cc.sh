#!/usr/bin/env bash

_koopa_locate_cc() {
    local str
    if _koopa_is_macos
    then
        str='/usr/bin/clang'
    else
        str='/usr/bin/gcc'
    fi
    _koopa_locate_app "$str"
}
