#!/usr/bin/env bash

koopa_uninstall_colorls() {
    koopa_uninstall_app \
        --name='colorls' \
        --unlink-in-bin='colorls' \
        "$@"
}
