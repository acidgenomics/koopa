#!/usr/bin/env bash

koopa_linux_uninstall_elfutils() {
    koopa_uninstall_app \
        --name='elfutils' \
        --platform='linux' \
        "$@"
}
