#!/usr/bin/env bash

koopa_install_shunit2() {
    koopa_install_app \
        --link-in-bin='shunit2' \
        --name='shunit2' \
        "$@"
}
