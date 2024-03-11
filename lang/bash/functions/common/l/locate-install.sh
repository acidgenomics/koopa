#!/usr/bin/env bash

koopa_locate_install() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ginstall' \
        "$@"
}
