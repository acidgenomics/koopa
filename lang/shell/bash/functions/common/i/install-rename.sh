#!/usr/bin/env bash

koopa_install_rename() {
    koopa_install_app \
        --link-in-bin='rename' \
        --name='rename' \
        "$@"
}
