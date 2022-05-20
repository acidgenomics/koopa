#!/usr/bin/env bash

koopa_uninstall_go() {
    koopa_uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        --unlink-in-bin='go' \
        "$@"
}
