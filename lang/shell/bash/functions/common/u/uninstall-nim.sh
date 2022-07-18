#!/usr/bin/env bash

koopa_uninstall_nim() {
    koopa_uninstall_app \
        --name='nim' \
        --unlink-in-bin='nim' \
        "$@"
}
