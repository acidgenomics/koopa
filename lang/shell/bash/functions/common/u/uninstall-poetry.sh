#!/usr/bin/env bash

koopa_uninstall_poetry() {
    koopa_uninstall_app \
        --name='poetry' \
        --unlink-in-bin='poetry' \
        "$@"
}
