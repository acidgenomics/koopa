#!/usr/bin/env bash

koopa_uninstall_dog() {
    koopa_uninstall_app \
        --name='dog' \
        --unlink-in-bin='dog' \
        "$@"
}
