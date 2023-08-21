#!/usr/bin/env bash

koopa_locate_cc() {
    local str
    if koopa_is_macos
    then
        str='/usr/bin/clang'
    else
        str='/usr/bin/gcc'
    fi
    koopa_locate_app "$str"
}
