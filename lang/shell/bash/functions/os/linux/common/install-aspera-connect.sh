#!/usr/bin/env bash

koopa_linux_install_aspera_connect() {
    koopa_install_app \
        --link-in-bin='bin/ascp' \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
