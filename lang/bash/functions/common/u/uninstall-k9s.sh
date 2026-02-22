#!/usr/bin/env bash

koopa_uninstall_k9s() {
    koopa_uninstall_app \
        --name='k9s' \
        "$@"
}
