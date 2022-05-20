#!/usr/bin/env bash

koopa_uninstall_jq() {
    koopa_uninstall_app \
        --name='jq' \
        --unlink-in-bin='jq' \
        "$@"
}
