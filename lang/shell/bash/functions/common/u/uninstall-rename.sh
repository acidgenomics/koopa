#!/usr/bin/env bash

koopa_uninstall_rename() {
    koopa_uninstall_app \
        --name='rename' \
        --unlink-in-bin='rename' \
        "$@"
}
