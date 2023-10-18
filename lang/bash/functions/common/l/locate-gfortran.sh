#!/usr/bin/env bash

koopa_locate_gfortran() {
    if koopa_is_macos
    then
        koopa_locate_app \
            '/opt/gfortran/bin/gfortran' \
            "$@"
    else
        koopa_locate_app \
            --app-name='gcc' \
            --bin-name='gfortran' \
            "$@"
    fi
}
