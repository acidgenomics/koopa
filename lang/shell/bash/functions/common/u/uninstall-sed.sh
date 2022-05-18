#!/usr/bin/env bash

koopa_uninstall_sed() {
    koopa_uninstall_app \
        --name='sed' \
        --unlink-in-bin='sed' \
        "$@"
}
