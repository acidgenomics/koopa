#!/usr/bin/env bash

koopa_macos_uninstall_microsoft_onedrive() {
    koopa_uninstall_app \
        --name-fancy='Microsoft OneDrive' \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}
