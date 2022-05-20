#!/usr/bin/env bash

koopa_update_system() {
    koopa_update_app \
        --name='system' \
        --system \
        "$@"
}
