#!/usr/bin/env bash

koopa_locate_gfortran() {
    koopa_locate_app \
        --app-name='gcc' \
        --bin-name='gfortran' \
        "$@"
}
