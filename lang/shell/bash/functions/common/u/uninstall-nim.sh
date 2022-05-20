#!/usr/bin/env bash

koopa_uninstall_nim() {
    koopa_uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        --unlink-in-bin='nim' \
        "$@"
}
