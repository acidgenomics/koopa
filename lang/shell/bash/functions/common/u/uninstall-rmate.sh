#!/usr/bin/env bash

koopa_uninstall_rmate() {
    koopa_uninstall_app \
        --name='rmate' \
        --unlink-in-bin='rmate' \
        "$@"
}
