#!/usr/bin/env bash

koopa_uninstall_isort() {
    koopa_uninstall_app \
        --name='isort' \
        --unlink-in-bin='isort' \
        "$@"
}
