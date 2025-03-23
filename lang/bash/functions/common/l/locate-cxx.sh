#!/usr/bin/env bash

koopa_locate_cxx() {
    local str
    if koopa_is_macos
    then
        str='/usr/bin/clang++'
    else
        str='/usr/bin/g++'
    fi
    koopa_locate_app "$str"
}
