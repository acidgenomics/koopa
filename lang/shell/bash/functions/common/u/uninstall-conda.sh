#!/usr/bin/env bash

koopa_uninstall_conda() {
    koopa_uninstall_app \
        --name='conda' \
        --unlink-in-bin='conda' \
        "$@"
}
