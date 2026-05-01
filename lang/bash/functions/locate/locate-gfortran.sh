#!/usr/bin/env bash

_koopa_locate_gfortran() {
    if _koopa_is_macos
    then
        _koopa_locate_app \
            '/opt/gfortran/bin/gfortran' \
            "$@"
    else
        _koopa_locate_app \
            --app-name='gcc' \
            --bin-name='gfortran' \
            "$@"
    fi
}
