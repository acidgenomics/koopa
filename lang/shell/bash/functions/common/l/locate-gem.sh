#!/usr/bin/env bash

koopa_locate_gem() {
    koopa_locate_app \
        --app-name='ruby' \
        --bin-name='gem' \
        "$@"
}
