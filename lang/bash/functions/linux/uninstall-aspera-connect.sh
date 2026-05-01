#!/usr/bin/env bash

_koopa_linux_uninstall_aspera_connect() {
    _koopa_uninstall_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
