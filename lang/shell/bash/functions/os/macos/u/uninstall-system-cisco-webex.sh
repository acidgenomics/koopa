#!/usr/bin/env bash

koopa_macos_uninstall_system_cisco_webex() {
    koopa_uninstall_app \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}
