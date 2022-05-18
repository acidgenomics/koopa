#!/usr/bin/env bash

koopa_uninstall_groff() {
    koopa_uninstall_app \
        --name='groff' \
        --unlink-in-bin='groff' \
        "$@"
}
