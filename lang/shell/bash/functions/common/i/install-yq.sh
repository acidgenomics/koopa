#!/usr/bin/env bash

koopa_install_yq() {
    koopa_install_app \
        --link-in-bin='yq' \
        --name='yq' \
        "$@"
}
