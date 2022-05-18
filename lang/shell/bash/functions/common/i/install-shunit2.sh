#!/usr/bin/env bash

koopa_install_shunit2() {
    koopa_install_app \
        --link-in-bin='bin/shunit2' \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}
