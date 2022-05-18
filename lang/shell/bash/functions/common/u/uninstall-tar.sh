#!/usr/bin/env bash

koopa_uninstall_tar() {
    koopa_uninstall_app \
        --name='tar' \
        --unlink-in-bin='tar' \
        "$@"
}
