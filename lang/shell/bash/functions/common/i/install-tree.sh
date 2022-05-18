#!/usr/bin/env bash

koopa_install_tree() {
    koopa_install_app \
        --link-in-bin='bin/tree' \
        --name='tree' \
        "$@"
}
