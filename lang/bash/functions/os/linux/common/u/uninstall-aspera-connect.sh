#!/usr/bin/env bash

koopa_linux_uninstall_aspera_connect() {
    koopa_uninstall_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
