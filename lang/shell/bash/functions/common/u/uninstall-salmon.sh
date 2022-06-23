#!/usr/bin/env bash

koopa_uninstall_salmon() {
    koopa_uninstall_app \
        --name='salmon' \
        --unlink-in-bin='salmon' \
        "$@"
}
