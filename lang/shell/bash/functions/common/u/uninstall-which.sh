#!/usr/bin/env bash

koopa_uninstall_which() {
    koopa_uninstall_app \
        --name='which' \
        --unlink-in-bin='which' \
        "$@"
}
