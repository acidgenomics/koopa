#!/usr/bin/env bash

koopa_install_pytest() {
    koopa_install_app \
        --link-in-bin='pytest' \
        --name='pytest' \
        "$@"
}
