#!/usr/bin/env bash

koopa_uninstall_aspell() {
    koopa_uninstall_app \
        --name='aspell' \
        --unlink-in-bin='aspell' \
        "$@"
}
