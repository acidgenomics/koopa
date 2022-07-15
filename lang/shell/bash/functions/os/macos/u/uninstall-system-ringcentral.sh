#!/usr/bin/env bash

koopa_macos_uninstall_ringcentral() {
    koopa_uninstall_app \
        --name-fancy='RingCentral' \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}
