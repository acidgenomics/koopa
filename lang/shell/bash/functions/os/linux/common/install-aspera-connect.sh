#!/usr/bin/env bash

koopa_linux_install_aspera_connect() {
    koopa_install_app \
        --link-in-bin='ascp' \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
