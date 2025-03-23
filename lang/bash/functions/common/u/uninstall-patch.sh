#!/usr/bin/env bash

koopa_uninstall_patch() {
    koopa_uninstall_app \
        --name='patch' \
        "$@"
}
