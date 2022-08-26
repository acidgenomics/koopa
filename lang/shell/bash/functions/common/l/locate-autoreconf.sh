#!/usr/bin/env bash

koopa_locate_autoreconf() {
    koopa_locate_app \
        --app-name='autoconf' \
        --bin-name='autoreconf' \
        "$@" \
}
