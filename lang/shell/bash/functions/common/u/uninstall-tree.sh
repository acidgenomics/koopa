#!/usr/bin/env bash

koopa_uninstall_tree() {
    koopa_uninstall_app \
        --name='tree' \
        --unlink-in-bin='tree' \
        "$@"
}
