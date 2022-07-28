#!/usr/bin/env bash

koopa_uninstall_yq() {
    koopa_uninstall_app \
        --name='yq' \
        --unlink-in-bin='yq' \
        "$@"
}
