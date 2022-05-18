#!/usr/bin/env bash

koopa_uninstall_pyflakes() {
    koopa_uninstall_app \
        --name='pyflakes' \
        --unlink-in-bin='pyflakes' \
        "$@"
}
