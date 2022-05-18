#!/usr/bin/env bash

koopa_linux_uninstall_aspera_connect() {
    koopa_uninstall_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        --unlink-in-bin='ascp' \
        "$@"
}
