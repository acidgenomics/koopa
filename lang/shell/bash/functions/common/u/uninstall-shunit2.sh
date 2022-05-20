#!/usr/bin/env bash

koopa_uninstall_shunit2() {
    koopa_uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        --unlink-in-bin='shunit2' \
        "$@"
}
