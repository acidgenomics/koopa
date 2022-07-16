#!/usr/bin/env bash

koopa_install_jq() {
    koopa_install_app \
        --link-in-bin='jq' \
        --name='jq' \
        "$@"
}
