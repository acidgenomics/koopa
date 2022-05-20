#!/usr/bin/env bash

koopa_uninstall_htop() {
    koopa_uninstall_app \
        --name='htop' \
        --unlink-in-bin='htop' \
        "$@"
}
