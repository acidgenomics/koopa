#!/usr/bin/env bash

koopa_macos_uninstall_ringcentral() {
    koopa_uninstall_app \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}
