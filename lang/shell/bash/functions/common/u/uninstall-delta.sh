#!/usr/bin/env bash

koopa_uninstall_delta() {
    koopa_uninstall_app \
        --name='delta' \
        --unlink-in-bin='delta' \
        "$@"
}
