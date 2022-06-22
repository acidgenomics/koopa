#!/usr/bin/env bash

koopa_uninstall_make() {
    koopa_uninstall_app \
        --name='make' \
        --unlink-in-bin='make' \
        "$@"
}
