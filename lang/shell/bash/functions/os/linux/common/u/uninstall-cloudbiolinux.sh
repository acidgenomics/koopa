#!/usr/bin/env bash

koopa_linux_uninstall_cloudbiolinux() {
    koopa_uninstall_app \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}
