#!/usr/bin/env bash

koopa_macos_uninstall_system_microsoft_onedrive() {
    koopa_uninstall_app \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}
