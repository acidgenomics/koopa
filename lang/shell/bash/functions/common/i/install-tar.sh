#!/usr/bin/env bash

koopa_install_tar() {
    koopa_install_app \
        --link-in-bin='tar' \
        --name='tar' \
        "$@"
}
