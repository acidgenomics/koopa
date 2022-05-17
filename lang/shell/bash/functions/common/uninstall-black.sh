#!/usr/bin/env bash

koopa_uninstall_black() {
    koopa_uninstall_app \
        --name='black' \
        --unlink-in-bin='black' \
        "$@"
}
