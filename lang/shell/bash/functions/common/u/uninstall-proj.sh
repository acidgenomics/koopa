#!/usr/bin/env bash

koopa_uninstall_proj() {
    koopa_uninstall_app \
        --name-fancy='PROJ' \
        --name='proj' \
        "$@"
}
