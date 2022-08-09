#!/usr/bin/env bash

koopa_linux_uninstall_pinentry() {
    koopa_uninstall_app \
        --name='pinentry' \
        --platform='linux' \
        "$@"
}
