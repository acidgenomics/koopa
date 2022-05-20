#!/usr/bin/env bash

koopa_uninstall_pytaglib() {
    koopa_uninstall_app \
        --name='pyprinttags' \
        --unlink-in-bin
        "$@"
}
