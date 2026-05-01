#!/usr/bin/env bash

_koopa_macos_uninstall_system_microsoft_onedrive() {
    _koopa_uninstall_app \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}
