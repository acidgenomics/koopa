#!/usr/bin/env bash

koopa_uninstall_python() {
    koopa_uninstall_app \
        --name='python' \
        --unlink-in-bin='python3' \
        "$@"
}
