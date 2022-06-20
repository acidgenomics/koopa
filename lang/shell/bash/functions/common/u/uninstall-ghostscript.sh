#!/usr/bin/env bash

koopa_uninstall_ghostscript() {
    koopa_uninstall_app \
        --name='ghostscript' \
        --unlink-in-bin='gs' \
        "$@"
}
