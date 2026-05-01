#!/usr/bin/env bash

_koopa_macos_uninstall_ringcentral() {
    _koopa_uninstall_app \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}
