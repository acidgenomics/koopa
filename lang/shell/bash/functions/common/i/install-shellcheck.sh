#!/usr/bin/env bash

koopa_install_shellcheck() {
    koopa_install_app \
        --link-in-bin='shellcheck' \
        --name='shellcheck' \
        "$@"
}
